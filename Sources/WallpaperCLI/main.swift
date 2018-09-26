import AppKit
import SwiftCLI
import Wallpaper

func stringToScale(_ scale: String?) -> Wallpaper.Scale {
	switch scale {
	case "fill":
		return .fill
	case "fit":
		return .fit
	case "stretch":
		return .stretch
	case "center":
		return .center
	default:
		return .auto
	}
}

final class SetCommand: Command {
	let name = "set"
	let shortDescription = "Set wallpaper image. Usage: set <path> [--scale <scale>]"
	let path = Parameter()
	let scale = Key<String>("-s", "--scale", description: "Image scale options [fill, fit, stretch, center]")

	func execute() throws {
		try Wallpaper.set(
			URL(fileURLWithPath: path.value),
			screens: .all,
			scale: stringToScale(scale.value)
		)
	}
}

final class GetCommand: Command {
	let name = "get"
	let shortDescription = "Get current wallpaper image path"

	func execute() throws {
		print(try Wallpaper.get().path)
	}
}

let cli = CLI(
	name: "wallpaper",
	version: "1.4.0",
	description: "Manage the desktop wallpaper"
)

cli.commands = [
	SetCommand(),
	GetCommand()
]

cli.goAndExit()
