//
//  NSPasteboard+NSPasteboard_Stash.m
//  Quill
//
//  Created by shintaro-morikawa on 2019/07/18.
//  Copyright © 2019 Shintaro Morikawa. All rights reserved.
//

#import "NSPasteboard+NSPasteboard_Stash.h"

@implementation NSPasteboard (NSPasteboard_Stash)

// save current contents as an array of pasteboard items
- (NSArray *)save
{
    NSMutableArray *archive=[NSMutableArray array];
    for (NSPasteboardItem *item in [self pasteboardItems])
    {
        NSPasteboardItem *archivedItem=[[NSPasteboardItem alloc] init];
        for (NSString *type in [item types])
        {
            /* The mutableCopy performs a deep copy of the data. This avoids
             memory leak issues (bug in Cocoa?), which you might run into if
             you don't copy the data. */
            NSData *data=[[item dataForType:type] mutableCopy];
            if (data) { // nil safety check
                [archivedItem setData:data forType:type];
            }
        }
        [archive addObject:archivedItem];
    }
    return archive;
}

// restore previously saved data
- (void)restore:(NSArray *)archive
{
    [self clearContents];
    [self writeObjects:archive];
}

@end
