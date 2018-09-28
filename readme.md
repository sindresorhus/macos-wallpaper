# macos-wallpaper

> Manage the desktop wallpaper on macOS

This is both a command-line app and a Swift package.

It correctly handles getting the active wallapaper even when the wallpaper is set to a directory.

*Requires macOS 10.12 or later.*

<a href="https://www.patreon.com/sindresorhus">
	<img src="https://c5.patreon.com/external/logo/become_a_patron_button@2x.png" width="160">
</a>


## CLI

### Install

###### [Homebrew](https://brew.sh)

```
$ brew install wallpaper
```

###### Manually

[Download](https://github.com/sindresorhus/macos-wallpaper/releases/latest) the binary and put it in `/usr/local/bin`.


### Usage

```
Usage: wallpaper <command> [options]

Manage the desktop wallpaper

Commands:
  set             Set wallpaper image. Usage: set <path>
  get             Get current wallpaper image
  screens         List screens
  help            Prints help information
  version         Prints the current version of this app
```

By default, it sets and gets the wallpaper for all screens. Use the `--screen` flag to change this.

##### Set

```
$ wallpaper set unicorn.jpg
```

##### Get

```
$ wallpaper get
/Users/sindresorhus/unicorn.jpg
```


## API

### Install

With Swift Package Manager:

```swift
.package(url: "https://github.com/sindresorhus/macos-wallpaper", from: "1.3.0")
```

### Usage

```swift
import Wallpaper

let imageURL = URL(fileURLWithPath: "<path>")

try! Wallpaper.set(imageURL, screen: .main, scale: .fill)

print(try! Wallpaper.get(screen: .main))
```

See the [source](Sources/Wallpaper/Wallpaper.swift) for more.


## Dev

### Run

```
swift run wallpaper
```

### Build

```
swift build --configuration=release -Xswiftc -static-stdlib
```

### Generate Xcode project

```
swift package generate-xcodeproj --xcconfig-overrides=Config.xcconfig
```


## Related

- [wallpaper](https://github.com/sindresorhus/wallpaper) - Get or set the desktop wallpaper cross-platform *(Uses this binary)*


## License

MIT © [Sindre Sorhus](https://sindresorhus.com)
