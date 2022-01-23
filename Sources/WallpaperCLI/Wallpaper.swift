import AppKit
import ArgumentParser
import Wallpaper

@main
struct Main: ParsableCommand {
	static var configuration = CommandConfiguration(
		commandName: "wallpaper", // TODO: Remove this when https://github.com/apple/swift-argument-parser/issues/295 is fixed.
		abstract: "Manage the desktop wallpaper",
		version: "2.3.0",
		subcommands: [
			Get.self,
			Set.self,
			SetSolidColor.self,
			Screens.self
		]
	)
}

extension Main {
	struct Get: ParsableCommand {
		static var configuration = CommandConfiguration(
			abstract: "Get current wallpaper images."
		)

		@Option(help: "Values: all, main, <index>")
		var screen = Wallpaper.Screen.all

		mutating func run() throws {
			let wallpaperURLs = try Wallpaper.get(screen: screen)
			print(wallpaperURLs.map(\.path).joined(separator: "\n"))
		}
	}

	struct Set: ParsableCommand {
		static var configuration = CommandConfiguration(
			abstract: "Set image as wallpaper."
		)

		@Argument(
			help: "The path to the image to use as wallpaper.",
			completion: .file(extensions: ["png", "jpg", "jpeg"])
		)
		var path: URL

		@Option(help: "Values: all, main, <index>")
		var screen = Wallpaper.Screen.all

		// TODO: The values should be shown automatically: https://github.com/apple/swift-argument-parser/issues/151
		@Option(help: "Values: auto, fill, fit, stretch, center")
		var scale = Wallpaper.Scale.auto

		@Option(
			help: "Format: Hex color <RRGGBB>",
			transform: {
				guard let color = NSColor(hexString: $0) else {
					throw ValidationError("The color should be in Hex format.")
				}

				return color
			}
		)
		var fillColor: NSColor?

		mutating func run() throws {
			try Wallpaper.set(
				path,
				screen: screen,
				scale: scale,
				fillColor: fillColor
			)
		}
	}

	struct SetSolidColor: ParsableCommand {
		static var configuration = CommandConfiguration(
			abstract: "Set solid color as wallpaper."
		)

		@Argument(
			help: "The color to use as wallpaper.",
			transform: {
				guard let color = NSColor(hexString: $0) else {
					throw ValidationError("The color should be in Hex format.")
				}

				return color
			}
		)
		var color: NSColor

		@Option(help: "Values: all, main, <index>")
		var screen = Wallpaper.Screen.all

		mutating func run() throws {
			try Wallpaper.set(
				color,
				screen: screen
			)
		}
	}

	struct Screens: ParsableCommand {
		static var configuration = CommandConfiguration(
			abstract: "Get a list of available screens."
		)

		mutating func run() throws {
			let output = Wallpaper.screenNames.enumerated().map { "\($0) - \($1)" }.joined(separator: "\n")
			print(output)
		}
	}
}

extension URL: ExpressibleByArgument {
	public init?(argument: String) {
		self = URL(fileURLWithPath: argument, isDirectory: false)
	}
}

extension Wallpaper.Screen: ExpressibleByArgument {
	public init?(argument: String) {
		switch argument {
		case "all":
			self = .all
		case "main":
			self = .main
		default:
			guard
				let index = Int(argument),
				index < NSScreen.screens.count
			else {
				return nil
			}

			self = .index(index)
		}
	}
}

extension Wallpaper.Scale: ExpressibleByArgument {
	public init?(argument: String) {
		switch argument {
		case "auto":
			self = .auto
		case "fill":
			self = .fill
		case "fit":
			self = .fit
		case "stretch":
			self = .stretch
		case "center":
			self = .center
		default:
			return nil
		}
	}
}
