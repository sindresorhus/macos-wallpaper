//
//  ScreenInfo.h
//  wallpaper
//
//  Created by Terence on 6/24/15.
//

@import AppKit;

@interface ScreenInfo : NSObject
+ (NSArray*) getScreens;
+ (NSString*) getScreenDeviceName:(NSScreen*)screen;
+ (NSNumber*) getScreenDeviceID:(NSScreen*)screen;
+ (NSScreen*) getScreenFromDeviceID:(NSNumber*)deviceID;
@end
