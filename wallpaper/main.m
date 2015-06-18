//
//  main.m
//  wallpaper
//
//  Created by Sindre Sorhus on 27/03/15.
//  Copyright (c) 2015 Sindre Sorhus. All rights reserved.
//

@import AppKit;

int main() {
	@autoreleasepool {
		NSArray *args = [NSProcessInfo processInfo].arguments;

		if (args.count > 1) {
			if ([args[1] isEqualToString: @"--version"]) {
				puts("1.0.0");
				return 0;
			}

			if ([args[1] isEqualToString: @"--help"]) {
				puts("\n  Get or set the desktop wallpaper\n\n  Usage: wallpaper [file]\n\n  Created by Sindre Sorhus");
				return 0;
			}

			[[NSWorkspace sharedWorkspace] setDesktopImageURL:[NSURL fileURLWithPath:args[1]] forScreen:[NSScreen mainScreen] options:nil error:nil];
		} else {
			printf("%s\n", [[NSWorkspace sharedWorkspace] desktopImageURLForScreen:[NSScreen mainScreen]].path.UTF8String);
		}
	}

	return 0;
}
