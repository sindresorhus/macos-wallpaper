# macos-wallpaper

> Get or set the desktop wallpaper on macOS

Should work on >=10.6, but only tested on >=10.9.


## Install

###### [Homebrew](http://brew.sh)

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

* `-s, -scale <option>` Set image scaling option

```
$ wallpaper set unicorn.jpg -scale fill
```

###### Get

```
$ wallpaper get
/Users/sindresorhus/unicorn.jpg
```

## Build (Dev)
```
swift build
```
###### Run
```
swift run wallpaper
```

## Build (Release)

```
swift build -c release
```
###### Run
```
.build/<build_target>/release/wallpaper
```
## Related

- [wallpaper](https://github.com/sindresorhus/wallpaper) - Get or set the desktop wallpaper cross-platform *(Uses this binary)*


## License

MIT © [Sindre Sorhus](https://sindresorhus.com)
