// swift-tools-version:5.11
import PackageDescription

let package = Package(
	name: "Wallpaper",
	platforms: [
		.macOS(.v10_13)
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
		.package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
		.package(url: "https://github.com/stephencelis/SQLite.swift", from: "0.15.3")
	],
	targets: [
		.executableTarget(
			name: "WallpaperCLI",
			dependencies: [
				"Wallpaper",
				.product(
					name: "ArgumentParser",
					package: "swift-argument-parser"
				)
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
