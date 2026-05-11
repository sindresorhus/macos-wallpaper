import AppKit
import SQLite

// https://github.com/stephencelis/SQLite.swift/issues/1277
typealias Expression = SQLite.Expression

public enum Wallpaper {
	public enum Screen {
		case all
		case main
		case index(Int)
		case nsScreens([NSScreen])

		fileprivate var nsScreens: [NSScreen] {
			switch self {
			case .all:
				return NSScreen.screens
			case .main:
				guard let mainScreen = NSScreen.main else {
					return []
				}

				return [mainScreen]
			case .index(let index):
				guard let screen = NSScreen.screens[safe: index] else {
					return []
				}

				return [screen]
			case .nsScreens(let nsScreens):
				return nsScreens
			}
		}
	}

	public enum Scale: String, CaseIterable {
		case auto
		case fill
		case fit
		case stretch
		case center
	}

	/**
	Works around macOS bug where it sometimes returns a directory instead of an image.

	https://openradar.appspot.com/radar?id=4959084113559552

	Note: This workaround is only needed on macOS versions prior to macOS 26. On macOS 26+, the database schema may have changed or may not exist, and NSWorkspace.shared.desktopImageURL appears to return proper file paths.
	*/
	private static func imageURL(fromDatabaseValue value: String, in directory: URL) -> URL {
		if value.hasPrefix("/") {
			return URL(fileURLWithPath: value, isDirectory: false)
		}

		return directory.appendingPathComponent(value, isDirectory: false)
	}

	private static func getDisplaySpecificImage(from db: Connection, directory: URL, screen: NSScreen) throws -> URL? {
		guard let displayUUID = screen.displayUUID else {
			return nil
		}

		let data = Table("data")
		let preferences = Table("preferences")
		let pictures = Table("pictures")
		let displays = Table("displays")

		let rowID = Expression<Int64>("rowid")
		let value = Expression<String>("value")
		let key = Expression<Int64>("key")
		let dataID = Expression<Int64>("data_id")
		let pictureID = Expression<Int64>("picture_id")
		let displayID = Expression<Int64>("display_id")
		let displayUUIDColumn = Expression<String>("display_uuid")

		let query = preferences
			.join(data, on: preferences[dataID] == data[rowID])
			.join(pictures, on: preferences[pictureID] == pictures[rowID])
			.join(displays, on: pictures[displayID] == displays[rowID])
			.select(data[value])
			.filter(displays[displayUUIDColumn] == displayUUID && preferences[key] == 16)
			.order(preferences[rowID].desc)

		guard let image = try db.pluck(query)?.get(data[value]) else {
			return nil
		}

		return imageURL(fromDatabaseValue: image, in: directory)
	}

	private static func getMostRecentImage(from db: Connection, directory: URL) throws -> URL {
		let data = Table("data")
		let value = Expression<String>("value")
		let rowID = Expression<Int64>("rowid")

		let maxID = try db.scalar(data.select(rowID.max))!
		let query = data.select(value).filter(rowID == maxID)
		let image = try db.pluck(query)!.get(value)

		return imageURL(fromDatabaseValue: image, in: directory)
	}

	private static func getFromDirectory(_ url: URL, screen: NSScreen) throws -> URL {
		// On macOS 26+, skip the database workaround as it may not be available
		// and the underlying bug appears to be fixed
		if #available(macOS 26, *) {
			return url
		}

		let appSupportDirectory = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
		let dbURL = appSupportDirectory.appendingPathComponent("Dock/desktoppicture.db", isDirectory: false)
		let db = try Connection(dbURL.path)

		if let image = try getDisplaySpecificImage(from: db, directory: url, screen: screen) {
			return image
		}

		return try getMostRecentImage(from: db, directory: url)
	}

	/**
	Get the current wallpapers.
	*/
	public static func get(screen: Screen = .all) throws -> [URL] {
		screen.nsScreens.compactMap { nsScreen in
			guard let url = NSWorkspace.shared.desktopImageURL(for: nsScreen) else {
				return nil
			}

			if url.isDirectory {
				// Try to get specific image from directory, fall back to directory if it fails (e.g., in sandbox)
				return (try? getFromDirectory(url, screen: nsScreen)) ?? url
			}

			return url
		}
	}

	/**
	Validates that a file or directory exists and is accessible.
	*/
	private static func validateFile(_ url: URL) throws {
		var isDirectory: ObjCBool = false

		guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
			throw NSError(
				domain: "WallpaperError",
				code: 1,
				userInfo: [NSLocalizedDescriptionKey: "The file doesn't exist."]
			)
		}

		// For files, ensure they're actually accessible
		if !isDirectory.boolValue {
			guard (try? url.checkResourceIsReachable()) == true else {
				throw NSError(
					domain: "WallpaperError",
					code: 1,
					userInfo: [NSLocalizedDescriptionKey: "The file exists but is not accessible."]
				)
			}
		}
	}

	/**
	Works around a macOS bug where if you set a wallpaper to the same path as the existing wallpaper but with different content, it doesn't update.

	https://openradar.appspot.com/radar?id=6095446787227648
	*/
	private static func forceRefreshIfNeeded(_ image: URL, screen: Screen) throws {
		var shouldSleep = false
		let currentImages = try get(screen: screen)

		for (index, nsScreen) in screen.nsScreens.enumerated() {
			if image == currentImages[index] {
				shouldSleep = true
				try NSWorkspace.shared.setDesktopImageURL(URL(fileURLWithPath: ""), for: nsScreen, options: [:])
			}
		}

		if shouldSleep {
			// We need to sleep for a little bit, otherwise it doesn't take effect.
			// It works with 0.3, but not with 0.2, so we're using 0.4 just to be sure.
			sleep(for: 0.4)
		}
	}

	/**
	Set an image URL as wallpaper.
	*/
	public static func set(
		_ image: URL,
		screen: Screen = .all,
		scale: Scale = .auto,
		fillColor: NSColor? = nil
	) throws {
		// Validate that the file or directory exists and is accessible
		try validateFile(image)

		var options = [NSWorkspace.DesktopImageOptionKey: Any]()

		switch scale {
		case .auto:
			break
		case .fill:
			options[.imageScaling] = NSImageScaling.scaleProportionallyUpOrDown.rawValue
			options[.allowClipping] = true
		case .fit:
			options[.imageScaling] = NSImageScaling.scaleProportionallyUpOrDown.rawValue
			options[.allowClipping] = false
		case .stretch:
			options[.imageScaling] = NSImageScaling.scaleAxesIndependently.rawValue
			options[.allowClipping] = true
		case .center:
			options[.imageScaling] = NSImageScaling.scaleNone.rawValue
			options[.allowClipping] = false
		}

		options[.fillColor] = fillColor

		try forceRefreshIfNeeded(image, screen: screen)

		for nsScreen in screen.nsScreens {
			try NSWorkspace.shared.setDesktopImageURL(image, for: nsScreen, options: options)
		}
	}

	/**
	Set a solid color as wallpaper.
	*/
	public static func set(_ solidColor: NSColor, screen: Screen = .all) throws {
		let transparentImage = URL(fileURLWithPath: "/System/Library/PreferencePanes/DesktopScreenEffectsPref.prefPane/Contents/Resources/DesktopPictures.prefPane/Contents/Resources/Transparent.tiff")

		try set(transparentImage, screen: screen, scale: .fit, fillColor: solidColor)
	}

	/**
	Names of available screens.
	*/
	public static var screenNames: [String] {
		NSScreen.screens.map(\.name)
	}
}
