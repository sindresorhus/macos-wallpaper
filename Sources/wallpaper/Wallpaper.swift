import AppKit
import SQLite

public struct Wallpaper {
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

	public enum Scale {
		case auto
		case fill
		case fit
		case stretch
		case center
	}

	/// Works around macOS bug where it sometimes returns a directory instead of an image.
	/// https://openradar.appspot.com/radar?id=4959084113559552
	private static func getFromDirectory(_ url: URL) throws -> URL {
		let appSupportDirectory = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
		let dbURL = appSupportDirectory.appendingPathComponent("Dock/desktoppicture.db")

		let table = Table("data")
		let column = Expression<String>("value")
		let rowID = Expression<Int64>("rowid")

		let db = try Connection(dbURL.path)
		let maxID = try db.scalar(table.select(rowID.max))!
		let query = table.select(column).filter(rowID == maxID)
		let image = try db.pluck(query)!.get(column)

		return url.appendingPathComponent(image)
	}

	/// Get the current wallpapers.
	public static func get(screen: Screen = .all) throws -> [URL] {
		let wallpaperURLs = screen.nsScreens.compactMap { NSWorkspace.shared.desktopImageURL(for: $0) }
		return try wallpaperURLs.map { $0.isDirectory ? try getFromDirectory($0) : $0 }
	}

	/// Works around a macOS bug where if you set a wallpaper to the same path as the existing wallpaper but with different content, it doesn't update.
	/// https://openradar.appspot.com/radar?id=6095446787227648
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

	/// Set an image URL as wallpaper.
	public static func set(_ image: URL, screen: Screen = .all, scale: Scale = .auto, fill: NSColor? = nil) throws {
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

		options[.fillColor] = fill

		try forceRefreshIfNeeded(image, screen: screen)

		for nsScreen in screen.nsScreens {
			try NSWorkspace.shared.setDesktopImageURL(image, for: nsScreen, options: options)
		}
	}

	/// Names of available screens.
	public static var screenNames: [String] {
		NSScreen.screens.map { $0.name }
	}
}
