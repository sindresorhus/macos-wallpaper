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
			// List the version name
			if ([args[1] isEqualToString: @"--version"]) {
				puts("1.1.0");
				return 0;
			}

			// Print help prompt
			if ([args[1] isEqualToString: @"--help"]) {
				puts("Get or set the desktop wallpaper of a specific screen or all screens. If no\n"
					 "options are specified then OSX Wallpaper will return the path of the current\n"
					 "wallpaper on the main screen.\n\n"
					 
					 "Usage: wallpaper [options] | [[screenid] [file]]\n"
					 "   file               Absolute path to image file.\n"
					 "   screenid           ID of the screen to get or set the wallpaper on\n"
					 "                      if none specified then the wallpaper is returned or\n"
					 "                      set on all screens. Use --screeninfo to list screen IDs.\n\n"
					 
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
			
			NSString* wallpaperPath = nil;
			NSNumber* screenID      = nil;
			
			// Convert the first argument into an NSNumber
			NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
			f.numberStyle = NSNumberFormatterDecimalStyle;
			screenID = [f numberFromString:args[1]];
			
			// Get the screen using the screen ID
			if (screenID) {
				screen = [ScreenInfo getScreenFromDeviceID:screenID];
				
				// If the screen was not found, throw an error
				if (!screen) {
					fprintf(stderr, "No screen found\n");
					return 1;
				}
				
				// Get the wallpaper path from the second param if there is one
				if (args.count > 2)
					wallpaperPath = args[2];
			} else {
				wallpaperPath = args[1];
			}
			
			// If the user specified only the screen then we give the user the screen's wallpaper path
			if (screen && !wallpaperPath) {
				printf("%s\n", [sw desktopImageURLForScreen:screen].path.UTF8String);
				return 0;
			}
			
			// Prepare and set the wallpaper on the specified screen
			NSURL* imagePath = [NSURL fileURLWithPath:wallpaperPath];
			NSDictionary* opt = [sw desktopImageOptionsForScreen:screen];
			NSError *err;
			
			bool success = [sw setDesktopImageURL:imagePath forScreen:screen options:opt error:&err];

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
