// swift-tools-version:4.2
import PackageDescription

let package = Package(
	name: "Wallpaper",
	products: [
		.executable(
			name: "wallpaper",
			targets: [
				"WallpaperCLI"
			]
		),
		.library(
			name: "Wallpaper",
			targets: [
				"Wallpaper"
			]
		),
	],
	dependencies: [
		.package(url: "https://github.com/jakeheis/SwiftCLI", from: "5.2.0"),
		.package(url: "https://github.com/stephencelis/SQLite.swift", from: "0.11.5")
	],
	targets: [
		.target(
			name: "WallpaperCLI",
			dependencies: [
				"Wallpaper",
				"SwiftCLI"
			]
		),
		.target(
			name: "Wallpaper",
			dependencies: [
				"SQLite"
			]
		)
	]
)
