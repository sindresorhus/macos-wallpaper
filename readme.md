# macos-wallpaper

> Get or set the desktop wallpaper on macOS

*Requires macOS 10.10 or later.*


## Install

###### [Homebrew](https://brew.sh)

```
$ brew install wallpaper
```

###### Manually

[Download](https://github.com/sindresorhus/macos-wallpaper/releases/latest) the binary and put it in `/usr/local/bin`.


## Usage

```
Usage: wallpaper <command> [options]

Manage your desktop background image.

Commands:
  set             Set wallpaper image. Usage set <path>
  get             Get current wallpaper image path.
  help            Prints this help information
  version         Prints the current version of this app
```

###### Set

```
$ wallpaper set unicorn.jpg
```

###### Scaling options

You can specify the scaling method with one of these scale options: `fill`, `fit`, `stretch`, or `center`.

If you don't specify a scaling method, it will use your current setting.

- `-s, -scale <option>` Set image scaling option

```
$ wallpaper set unicorn.jpg -scale fill
```

###### Get

```
$ wallpaper get
/Users/sindresorhus/unicorn.jpg
```


## Build

### Dev

```
swift build
```

###### Run

```
swift run wallpaper
```

### Release

```
swift build --configuration release
```

###### Run

```
.build/release/wallpaper
```


## Related

- [wallpaper](https://github.com/sindresorhus/wallpaper) - Get or set the desktop wallpaper cross-platform *(Uses this binary)*


## License

MIT © [Sindre Sorhus](https://sindresorhus.com)
