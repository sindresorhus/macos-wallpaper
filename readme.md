# macos-wallpaper

> Manage the desktop wallpaper on macOS

This is both a command-line app and a Swift package.

It correctly handles getting the active wallpaper even when the wallpaper is set to a directory.

*Requires macOS 10.14.4 or later.*

## CLI

### Install

###### [Homebrew](https://brew.sh)

```
$ brew install wallpaper
```

###### Manually

[Download](https://github.com/sindresorhus/macos-wallpaper/releases/latest) the binary and put it in `/usr/local/bin`.

### Usage

By default, it sets and gets the wallpaper for all screens. Use the `--screen` flag to change this.

```
$ wallpaper help

Usage: wallpaper <command> [options]

Manage the desktop wallpaper

Commands:
  set               Set wallpaper image
  set-solid-color   Set solid color wallpaper background
  get               Get current wallpaper image
  screens           List screens
  help              Prints help information
  version           Prints the current version of this app
```

```
$ wallpaper get --help

Usage: wallpaper get [options]

Get current wallpaper image

Options:
  --screen <value>    Values: all, main, <index> [Default: all]
  -h, --help          Show help information
```

```
$ wallpaper set --help

Usage: wallpaper set <path> [options]

Set wallpaper image

Options:
  --scale <value>         Values: auto, fill, fit, stretch, center [Default: auto]
  --screen <value>        Values: all, main, <index> [Default: all]
  --fill-color <value>    Format: Hex color <RRGGBB> [Default: nil]
  -h, --help              Show help information
```

```
$ wallpaper set-solid-color --help

Usage: wallpaper set-solid-color <color> [options]

Set solid color wallpaper background

Options:
  --screen <value>        Values: all, main, <index> [Default: all]
  -h, --help              Show help information
```

##### Set

```
$ wallpaper set unicorn.jpg
```

##### Set solid color

```
$ wallpaper set-solid-color 0000ff
```

##### Get

```
$ wallpaper get
/Users/sindresorhus/unicorn.jpg
```

## API

### Install

Add the following to `Package.swift`:

```swift
.package(url: "https://github.com/sindresorhus/macos-wallpaper", from: "2.1.0")
```

[Or add the package in Xcode.](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)

### Usage

```swift
import Wallpaper

let imageURL = URL(fileURLWithPath: "<path>", isDirectory: false)
let solidColor = NSColor.blue

try! Wallpaper.set(imageURL, screen: .main, scale: .fill, fillColor: NSColor.blue)

try! Wallpaper.set(solidColor, screen: .main)

print(try! Wallpaper.get(screen: .main))
```

See the [source](Sources/wallpaper/Wallpaper.swift) for more.

## Dev

### Run

```
swift run wallpaper
```

### Build

```
swift build --configuration=release
```

## Related

- [wallpaper](https://github.com/sindresorhus/wallpaper) - Get or set the desktop wallpaper cross-platform *(Uses this binary)*
- [macos-trash](https://github.com/sindresorhus/macos-trash) - Move files and directories to the trash
- [do-not-disturb](https://github.com/sindresorhus/do-not-disturb) - Control the macOS `Do Not Disturb` feature
- [More…](https://github.com/search?q=user%3Asindresorhus+language%3Aswift)
