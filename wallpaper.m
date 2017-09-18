//
//  wallpaper.m
//  wallpaper
//
//  Copyright © Sindre Sorhus
//

@import AppKit;
#import <sqlite3.h>

int main() {
	@autoreleasepool {
		NSWorkspace *sw = [NSWorkspace sharedWorkspace];
		NSArray *args = [NSProcessInfo processInfo].arguments;
		NSScreen *screen = [NSScreen screens].firstObject;
		NSMutableDictionary *so = [[sw desktopImageOptionsForScreen:screen] mutableCopy];

		if (args.count > 1) {
			if ([args[1] isEqualToString: @"--version"]) {
				puts("1.3.0");
				return 0;
			}

			if ([args[1] isEqualToString: @"--help"]) {
				puts("\n  Get or set the desktop wallpaper\n\n  Usage: wallpaper [file] [scale]\n\n  `scale` can be either: fill fit stretch center\n  If not specified, it will use your current setting\n\n  Created by Sindre Sorhus");
				return 0;
			}

			if (args.count > 2) {
				if ([args[2] isEqualToString: @"fill"]) {
					[so setObject:[NSNumber numberWithInt:NSImageScaleProportionallyUpOrDown] forKey:NSWorkspaceDesktopImageScalingKey];
					[so setObject:[NSNumber numberWithBool:YES] forKey:NSWorkspaceDesktopImageAllowClippingKey];
				}

				if ([args[2] isEqualToString: @"fit"]) {
					[so setObject:[NSNumber numberWithInt:NSImageScaleProportionallyUpOrDown] forKey:NSWorkspaceDesktopImageScalingKey];
					[so setObject:[NSNumber numberWithBool:NO] forKey:NSWorkspaceDesktopImageAllowClippingKey];
				}

				if ([args[2] isEqualToString: @"stretch"]) {
					[so setObject:[NSNumber numberWithInt:NSImageScaleAxesIndependently] forKey:NSWorkspaceDesktopImageScalingKey];
					[so setObject:[NSNumber numberWithBool:YES] forKey:NSWorkspaceDesktopImageAllowClippingKey];
				}

				if ([args[2] isEqualToString: @"center"]) {
					[so setObject:[NSNumber numberWithInt:NSImageScaleNone] forKey:NSWorkspaceDesktopImageScalingKey];
					[so setObject:[NSNumber numberWithBool:NO] forKey:NSWorkspaceDesktopImageAllowClippingKey];
				}
			}

			NSError *err;

			bool success = [sw
				setDesktopImageURL:[NSURL fileURLWithPath:args[1]]
				forScreen:screen
				options:so
				error:&err];

			if (!success) {
				fprintf(stderr, "%s\n", err.localizedDescription.UTF8String);
				return 1;
			}
		} else {
			NSString *path = [sw desktopImageURLForScreen:screen].path;
			BOOL isDir;
			NSFileManager *fm = [NSFileManager defaultManager];

			// Check if file is a directory
			[fm fileExistsAtPath:path isDirectory:&isDir];

			// If directory, check database
			if (isDir) {
				NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
				NSString *dbPath = [dirs[0] stringByAppendingPathComponent:@"Dock/desktoppicture.db"];
				sqlite3 *db;

				if (sqlite3_open(dbPath.UTF8String, &db) == SQLITE_OK) {
					sqlite3_stmt *statement;
					const char *sql = "SELECT * FROM data";

					if (sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK) {
						NSString *file;
						while (sqlite3_step(statement) == SQLITE_ROW) {
							file = @((char *)sqlite3_column_text(statement, 0));
						}

						printf("%s/%s\n", path.UTF8String, file.UTF8String);
						sqlite3_finalize(statement);
					}

					sqlite3_close(db);
				}
			} else {
				printf("%s\n", path.UTF8String);
			}
		}
	}

	return 0;
}
