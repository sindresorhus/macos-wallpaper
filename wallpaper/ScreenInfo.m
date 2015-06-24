//
//  ScreenInfo.m
//  wallpaper
//
//  Created by Terence on 6/24/15.
//  Copyright (c) 2015 Sindre Sorhus. All rights reserved.
//

#import "ScreenInfo.h"

@implementation ScreenInfo

+ (NSArray*) getScreens
{
	return [NSScreen screens];
}

+ (NSString*) getScreenDeviceName:(NSScreen*)screen
{
	NSString *screenName = nil;
	
	// Get the screen's ID
	NSNumber* screenID = [ScreenInfo getScreenDeviceID:screen];
	CGDirectDisplayID aID = [screenID unsignedIntValue];
	
	// Get the screen service ID and its name
	NSDictionary *deviceInfo = (__bridge NSDictionary *)IODisplayCreateInfoDictionary(CGDisplayIOServicePort(aID), kIODisplayOnlyPreferredName);
	NSDictionary *localizedNames = [deviceInfo objectForKey:[NSString stringWithUTF8String:kDisplayProductName]];
	
	if ([localizedNames count] > 0) {
		screenName = [localizedNames objectForKey:[[localizedNames allKeys] objectAtIndex:0]];
	}
	
    return screenName;
}

+ (NSNumber*) getScreenDeviceID:(NSScreen*)screen
{
	NSDictionary* deviceInfo = [screen deviceDescription];
	NSNumber* screenID = [deviceInfo objectForKey:@"NSScreenNumber"];
	
	return screenID;
}

@end
