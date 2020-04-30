import AppKit
import SwiftCLI
import Wallpaper

func convertStringToScreen(_ screen: String?) -> Wallpaper.Screen {
	switch screen {
	case "all":
		return .all
	case "main":
		return .main
	default:
		guard let screen = screen else {
			return .all
		}

		if let index = Int(screen) {
			guard index < NSScreen.screens.count else {
				print("No screen with index \(index)", to: .standardError)
				exit(1)
			}

			return .index(index)
		}

		print("Invalid `--screen` value", to: .standardError)
		exit(1)
	}
}

func convertStringToScale(_ scale: String?) -> Wallpaper.Scale {
	switch scale {
	case "auto", .none:
		return .auto
	case "fill":
		return .fill
	case "fit":
		return .fit
	case "stretch":
		return .stretch
	case "center":
		return .center
	default:
		print("Invalid `--scale` value", to: .standardError)
		exit(1)
	}
}

func convertStringToFillColor(_ colorString: String?) -> NSColor? {
	guard let colorString = colorString else {
		return nil
	}

	guard let color = NSColor(hexString: colorString) else {
		print("Invalid `--fill-color` value", to: .standardError)
		exit(1)
	}

	return color
}

final class SetCommand: Command {
	let name = "set"
	let shortDescription = "Set wallpaper image"
	let path = Parameter()
	let screen = Key<String>("--screen", description: "Values: all, main, <index> [Default: all]")
	let scale = Key<String>("--scale", description: "Values: auto, fill, fit, stretch, center [Default: auto]")
	let fillColor = Key<String>("--fill-color", description: "Format: Hex color <RRGGBB> [Default: nil]")

	func execute() throws {
		try Wallpaper.set(
			URL(fileURLWithPath: path.value),
			screen: convertStringToScreen(screen.value),
			scale: convertStringToScale(scale.value),
			fillColor: convertStringToFillColor(fillColor.value)
		)
	}
}

final class SetSolidColorCommand: Command {
	let name = "set-solid-color"
	let shortDescription = "Set solid color wallpaper background"
	let solidColor = Parameter()
	let screen = Key<String>("--screen", description: "Values: all, main, <index> [Default: all]")

	func execute() throws {
		guard let color = NSColor(hexString: solidColor.value) else {
			print("Invalid `solidColor` value", to: .standardError)
			exit(1)
		}

		try Wallpaper.set(
			color,
			screen: convertStringToScreen(screen.value)
		)
	}
}

final class GetCommand: Command {
	let name = "get"
	let shortDescription = "Get current wallpaper image"
	let screen = Key<String>("--screen", description: "Values: all, main, <index> [Default: all]")

	func execute() throws {
		let wallpaperURLs = try Wallpaper.get(screen: convertStringToScreen(screen.value))
		print(wallpaperURLs.map(\.path).joined(separator: "\n"))
	}
}

final class ScreensCommand: Command {
	let name = "screens"
	let shortDescription = "List screens"

	func execute() throws {
		let output = Wallpaper.screenNames.enumerated().map { "\($0) - \($1)" } .joined(separator: "\n")
		print(output)
	}
}

let cli = CLI(
	name: "wallpaper",
	version: "2.0.0",
	description: "Manage the desktop wallpaper"
)

cli.commands = [
	SetCommand(),
	SetSolidColorCommand(),
	GetCommand(),
	ScreensCommand()
]

cli.goAndExit()
