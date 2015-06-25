# osx-wallpaper

> Get or set the desktop wallpaper on OS X. Version 1.1.0 supports multiscreen now.

Should work on >=10.6, but only tested on 10.10.


## Install

### [npm](https://github.com/sindresorhus/node-osx-wallpaper#cli)

```
$ npm install --global osx-wallpaper
```

### Manually

[Download the binary](https://github.com/sindresorhus/osx-wallpaper/releases/latest) and put it in `/usr/local/bin`.


## Binary usage

```sh
# Set wallpaper on main screen
wallpaper unicorn.jpg

# List connected screens (screen ID:screen name)
wallpaper --screeninfo
> 69732482:Color LCD
> 188845747:SM2333T

# Set wallpaper on specific screen (replace screenid with your screen ID)
wallpaper screenid unicorn2.jpg

# Get wallpaper on main screen
wallpaper
> /Users/sindresorhus/unicorn.jpg

# Get wallpaper on specific screen (replace screenid with your screen ID)
wallpaper screenid
> /Users/sindresorhus/unicorn2.jpg
```


## Related

- [`node-osx-wallpaper`](https://github.com/sindresorhus/node-osx-wallpaper) - Node wrapper.
- [`wallpaper`](https://github.com/sindresorhus/wallpaper) - Get or set the desktop wallpaper.


## License

MIT © [Sindre Sorhus](http://sindresorhus.com)
