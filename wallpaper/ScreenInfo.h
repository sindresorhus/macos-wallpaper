//
//  ScreenInfo.h
//  wallpaper
//
//  Created by Terence on 6/24/15.
//  Copyright (c) 2015 Sindre Sorhus. All rights reserved.
//

@import AppKit;

@interface ScreenInfo : NSObject
+ (NSArray*) getScreens;

+ (NSString*) getScreenDeviceName:(NSScreen*)screen;
+ (NSNumber*) getScreenDeviceID:(NSScreen*)screen;
@end
