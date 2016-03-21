//
//  wallpaper.m
//  wallpaper
//
//  Created by Sindre Sorhus on 27/03/15.
//  Copyright (c) 2015 Sindre Sorhus. All rights reserved.
//

@import AppKit;

int main() {
	@autoreleasepool {
		NSWorkspace *sw = [NSWorkspace sharedWorkspace];
		NSArray *args = [NSProcessInfo processInfo].arguments;
        NSArray<NSScreen *> *screens = [NSScreen screens];
        NSScreen *screen = screens[0];

		if (args.count > 1) {
			if ([args[1] isEqualToString: @"--version"]) {
				puts("1.1.0");
				return 0;
			}

			if ([args[1] isEqualToString: @"--help"]) {
				puts("\n  Get or set the desktop wallpaper\n\n  Usage: wallpaper [file]\n\n  Created by Sindre Sorhus");
				return 0;
			}

			NSError *err;

			bool success = [sw
				setDesktopImageURL:[NSURL fileURLWithPath:args[1]]
				forScreen:screen
				options:[sw desktopImageOptionsForScreen:screen]
				error:&err];

			if (!success) {
				fprintf(stderr, "%s\n", err.localizedDescription.UTF8String);
				return 1;
			}
		} else {
			printf("%s\n", [sw desktopImageURLForScreen:screen].path.UTF8String);
		}
	}

	return 0;
}
