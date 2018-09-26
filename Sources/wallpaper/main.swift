
import AppKit
import SwiftCLI

class SetCommand: Command {
  let name = "set"
  let shortDescription = "Set wallpaper image. Usage: set <path> [-s <scale>]"
  let path = Parameter()
  let scale = Key<String>("-s", "--scale", description: "Image scale options [fill, fit, stretch, center]")

  func execute() throws {
    let scaleOption = scale.value ?? nil
    let screens = NSScreen.screens

    // Update all screens by default
    for screen in screens {
      setDesktopImage(screen: screen, imgPath: path.value, scale: scaleOption)
    }
  }
}

class GetCommand: Command {
  let name = "get"
  let shortDescription = "Get current wallpaper image path."
  func execute() throws {
    print(getDesktopImage())
  }
}

// --- Initialize CLI ---
let myCLI = CLI(name: "wallpaper", version: "1.4.0", description: "Get or set the desktop wallpaper on macOS")
myCLI.commands = [SetCommand(), GetCommand()]
let exitCode = myCLI.go()

if exitCode > 0 {
  print("Error with code", exitCode)
}
