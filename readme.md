# macos-wallpaper

> Manage the desktop wallpaper on macOS

This is both a command-line app and a Swift package.

It correctly handles getting the active wallpaper even when the wallpaper is set to a directory.

## CLI

*Requires macOS 10.14.4 or later.*

### Install

###### [Homebrew](https://brew.sh)

```sh
brew install wallpaper
```

###### Manually

[Download](https://github.com/sindresorhus/macos-wallpaper/releases/latest) the binary and put it in `/usr/local/bin`.

### Usage

By default, it sets and gets the wallpaper for all screens. Use the `--screen` flag to change this.

```
$ wallpaper

USAGE: wallpaper <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  get                     Get current wallpaper images.
  set                     Set image as wallpaper.
  set-solid-color         Set solid color as wallpaper.
  screens                 Get a list of available screens.
```

```
$ wallpaper get --help

OVERVIEW: Get current wallpaper images.

USAGE: wallpaper get [--screen <screen>]

OPTIONS:
  --screen <screen>       Values: all, main, <index> (default: all)
```

```
$ wallpaper set --help

OVERVIEW: Set image as wallpaper.

USAGE: wallpaper set <path> [--screen <screen>] [--scale <scale>] [--fill-color <fill-color>]

ARGUMENTS:
  <path>                  The path to the image to use as wallpaper.

OPTIONS:
  --screen <screen>       Values: all, main, <index> (default: all)
  --scale <scale>         Values: auto, fill, fit, stretch, center (default: auto)
  --fill-color <fill-color>
                          Format: Hex color <RRGGBB>
```

```
$ wallpaper set-solid-color --help

OVERVIEW: Set solid color as wallpaper.

USAGE: wallpaper set-solid-color <color> [--screen <screen>]

ARGUMENTS:
  <color>                 The color to use as wallpaper.

OPTIONS:
  --screen <screen>       Values: all, main, <index> (default: all)
```

##### Set

```sh
wallpaper set unicorn.jpg
```

##### Set solid color

```sh
wallpaper set-solid-color 0000ff
```

##### Get

```sh
wallpaper get
/Users/sindresorhus/unicorn.jpg
```

## API

*Building this requires the latest Xcode and macOS version. The package supports macOS 10.14.4 or later.*

### Install

Add the following to `Package.swift`:

```swift
.package(url: "https://github.com/sindresorhus/macos-wallpaper", from: "2.3.1")
```

[Or add the package in Xcode.](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)

### Usage

```swift
import Wallpaper

let imageURL = URL(fileURLWithPath: "<path>", isDirectory: false)
try! Wallpaper.set(imageURL, screen: .main, scale: .fill)

let solidColor = NSColor.blue
try! Wallpaper.set(solidColor, screen: .main)

print(try! Wallpaper.get(screen: .main))
```

See the [source](Sources/wallpaper/Wallpaper.swift) for more.

## Dev

### Run

```sh
swift run wallpaper
```

### Build

```sh
swift build --configuration=release --arch arm64 --arch x86_64 && mv .build/apple/Products/Release/wallpaper .
```

## Related

- [wallpaper](https://github.com/sindresorhus/wallpaper) - Get or set the desktop wallpaper cross-platform *(Uses this binary)*
- [macos-trash](https://github.com/sindresorhus/macos-trash) - Move files and directories to the trash
- [do-not-disturb](https://github.com/sindresorhus/do-not-disturb) - Control the macOS `Do Not Disturb` feature
- [More…](https://github.com/search?q=user%3Asindresorhus+language%3Aswift)
