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

###### Set

```
$ wallpaper unicorn.jpg
```

###### Get

```
$ wallpaper
/Users/sindresorhus/unicorn.jpg
```

###### Set scaling method

```
$ wallpaper unicorn.jpg fill
```

You can specify the scaling method as the second parameter, which can be either `fill`, `fit`, `stretch`, or `center`.

If you don't specify a scaling method, it will use your current setting.


## Build

```
$ ./build
```


## Related

- [wallpaper](https://github.com/sindresorhus/wallpaper) - Get or set the desktop wallpaper cross-platform *(Uses this binary)*


## License

MIT © [Sindre Sorhus](https://sindresorhus.com)
