//
//  main.m
//  wallpaper
//
//  Created by Sindre Sorhus on 27/03/15.
//  Copyright (c) 2015 Sindre Sorhus. All rights reserved.
//
//  Multiscreen support by Terence-Lee Davis on 24/06/15.
//

@import AppKit;

#import "ScreenInfo.h"

int main() {
	@autoreleasepool {
		NSWorkspace *sw  = [NSWorkspace sharedWorkspace];
		NSArray *args    = [NSProcessInfo processInfo].arguments;
		NSScreen *screen = [NSScreen mainScreen];

		if (args.count > 1) {
			if ([args[1] isEqualToString: @"--version"]) {
				puts("1.1.0");
				return 0;
			}

			if ([args[1] isEqualToString: @"--help"]) {
				puts("Get or set the desktop wallpaper of a specific screen or all screens.\n"
					 "Usage: wallpaper [options] [[screenid] [file]]\n"
					 "   file               Absolute path to image file.\n"
					 "   screenid           ID of the screen to get or set the wallpaper on\n"
					 "                      if none specified then the wallpaper is returned or\n"
					 "                      set on all screens.\n\n"
					 "   --version          Displays version number.\n"
					 "   --help             Shows this help prompt.\n"
					 "   --screeninfo       Displays all screen information.\n\n"
					 "Created by Sindre Sorhus\n"
					 "Multiscreen support by Terence-Lee Davis");
				return 0;
			}
			
			// List the available screens attached to the computer
			if ([args[1] isEqualToString: @"--screeninfo"]) {
				NSArray* screens = [ScreenInfo getScreens];
				for (id screen in screens) {
					NSString* screenName = [ScreenInfo getScreenDeviceName:screen];
					NSNumber* screenID   = [ScreenInfo getScreenDeviceID:screen];
					
					NSString* screenInfo = [NSString stringWithFormat:@"%@:%@", screenID, screenName];
					puts(screenInfo.UTF8String);
				}
				
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
