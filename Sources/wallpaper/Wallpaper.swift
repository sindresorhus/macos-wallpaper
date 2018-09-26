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

	/// Gets the current wallpaper
	public static func get(screen: NSScreen? = .main) throws -> URL {
		let wallpaperURL = NSWorkspace.shared.desktopImageURL(for: screen!)!

		if wallpaperURL.isDirectory {
			let appSupportDirectory = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
			let dbURL = appSupportDirectory.appendingPathComponent("Dock/desktoppicture.db")

			let table = Table("data")
			let column = Expression<String>("value")
			let rowID = Expression<Int64>("rowid")

			let db = try Connection(dbURL.path)
			let maxID = try db.scalar(table.select(rowID.max))!
			let query = table.select(column).filter(rowID == maxID)
			let image = try db.pluck(query)!.get(column)

			return wallpaperURL.appendingPathComponent(image)
		}

		return wallpaperURL
	}

	/// Sets the wallpaper for a specific screen
	public static func set(_ image: URL, screens: Screen = .all, scale: Scale = .auto) throws {
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

		for nsScreen in screens.nsScreens {
			try NSWorkspace.shared.setDesktopImageURL(image, for: nsScreen, options: options)
		}
	}
}
