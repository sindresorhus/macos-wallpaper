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
	private static func getFromDirectory(_ url: URL) throws -> URL {
		// On macOS 26+, skip the database workaround as it may not be available
		// and the underlying bug appears to be fixed
		if #available(macOS 26, *) {
			return url
		}

		let appSupportDirectory = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
		let dbURL = appSupportDirectory.appendingPathComponent("Dock/desktoppicture.db", isDirectory: false)

		let table = Table("data")
		let column = Expression<String>("value")
		let rowID = Expression<Int64>("rowid")

		let db = try Connection(dbURL.path)
		let maxID = try db.scalar(table.select(rowID.max))!
		let query = table.select(column).filter(rowID == maxID)
		let image = try db.pluck(query)!.get(column)

		return url.appendingPathComponent(image, isDirectory: false)
	}

	/**
	Get the current wallpapers.
	*/
	public static func get(screen: Screen = .all) throws -> [URL] {
		let wallpaperURLs = screen.nsScreens.compactMap { NSWorkspace.shared.desktopImageURL(for: $0) }
		return wallpaperURLs.map { url in
			if url.isDirectory {
				// Try to get specific image from directory, fall back to directory if it fails (e.g., in sandbox)
				return (try? getFromDirectory(url)) ?? url
			} else {
				return url
			}
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
	private static func makeTemporaryImageCopy(_ image: URL) throws -> URL? {
		if image.isDirectory {
			return nil
		}

		let directory = FileManager.default.temporaryDirectory.appendingPathComponent("macos-wallpaper", isDirectory: true)
		try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

		let pathExtension = image.pathExtension
		let filename = pathExtension.isEmpty ? UUID().uuidString : "\(UUID().uuidString).\(pathExtension)"
		let temporaryImage = directory.appendingPathComponent(filename, isDirectory: false)
		try FileManager.default.copyItem(at: image, to: temporaryImage)

		return temporaryImage
	}

	private static func forceRefreshIfNeeded(
		_ image: URL,
		screen: Screen,
		options: [NSWorkspace.DesktopImageOptionKey: Any]
	) throws {
		let currentImages = try get(screen: screen)
		let matchingScreens = screen.nsScreens.enumerated().compactMap { index, nsScreen -> NSScreen? in
			guard currentImages[safe: index] == image else {
				return nil
			}

			return nsScreen
		}

		if matchingScreens.isEmpty {
			return
		}

		let refreshImage = (try? makeTemporaryImageCopy(image)) ?? URL(fileURLWithPath: "")
		defer {
			if refreshImage.path.hasPrefix(FileManager.default.temporaryDirectory.path) {
				try? FileManager.default.removeItem(at: refreshImage)
			}
		}

		for nsScreen in matchingScreens {
			try NSWorkspace.shared.setDesktopImageURL(refreshImage, for: nsScreen, options: options)
		}

		// We need to sleep for a little bit, otherwise it doesn't take effect.
		// It works with 0.3, but not with 0.2, so we're using 0.4 just to be sure.
		sleep(for: 0.4)
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

		try forceRefreshIfNeeded(image, screen: screen, options: options)

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
