// swift-tools-version:5.2
import PackageDescription

let package = Package(
	name: "Wallpaper",
	platforms: [
		.macOS(.v10_12)
	],
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
		.package(url: "https://github.com/jakeheis/SwiftCLI", from: "5.3.2"),
		.package(url: "https://github.com/stephencelis/SQLite.swift", from: "0.12.2")
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
				.product(
					name: "SQLite",
					package: "SQLite.swift"
				)
			]
		)
	]
)
