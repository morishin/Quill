//
//  NSPasteboard+NSPasteboard_Stash.h
//  Quill
//
//  Created by shintaro-morikawa on 2019/07/18.
//  Copyright © 2019 Shintaro Morikawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSPasteboard (NSPasteboard_Stash)

- (NSArray *)save;
- (void)restore:(NSArray *)archive;

@end

NS_ASSUME_NONNULL_END
