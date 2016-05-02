//
//  wallpaper.m
//  wallpaper
//
//  Created by Sindre Sorhus on 27/03/15.
//  Copyright (c) 2015 Sindre Sorhus. All rights reserved.
//

@import AppKit;
#import <sqlite3.h>

int main() {
	@autoreleasepool {
		NSWorkspace *sw = [NSWorkspace sharedWorkspace];
		NSArray *args = [NSProcessInfo processInfo].arguments;
		NSScreen *screen = [NSScreen screens].firstObject;

		if (args.count > 1) {
			if ([args[1] isEqualToString: @"--version"]) {
				puts("1.1.1");
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
			NSString *url = [sw desktopImageURLForScreen:screen].path;
			BOOL isDir;
			NSFileManager *fm = [NSFileManager defaultManager];

			// check if file is a directory
			[fm fileExistsAtPath:url isDirectory:&isDir];

			// if directory, check db
			if (isDir) {
				NSArray *dirs = [fm URLsForDirectory:NSApplicationSupportDirectory
																	 inDomains:NSUserDomainMask];
				if ([dirs count] > 0) {
					NSURL *dbLoc = [[dirs objectAtIndex:0] URLByAppendingPathComponent:@"Dock/desktoppicture.db"];
					const char *dbPath = [[dbLoc path] UTF8String];
					sqlite3 *db = nil;

					if (sqlite3_open(dbPath, &db) == SQLITE_OK) {
						sqlite3_stmt *statement;
						const char *sql = "SELECT * FROM data";

						if (sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK) {
							NSString *file;
							while (sqlite3_step(statement) == SQLITE_ROW) {
								file = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
							}

							printf("%s/%s\n", url.UTF8String, file.UTF8String);
							sqlite3_finalize(statement);
						}
						sqlite3_close(db);
					}
				}
			} else {
				printf("%s\n", url.UTF8String);
			}
		}
	}

	return 0;
}
