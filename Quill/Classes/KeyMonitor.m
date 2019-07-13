//
//  KeyMonitor.m
//  Quill
//
//  Created by Shintaro Morikawa on 2013/11/14.
//  Copyright (c) 2013年 Shintaro Morikawa. All rights reserved.
//

#import "KeyMonitor.h"

@interface KeyMonitor () {
    id eventMonitor;
}
@end

@implementation KeyMonitor
- (id)init
{
    self = [super init];
    if (self) {
        eventMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskKeyUp
                                                              handler:^(NSEvent *event) {
            if (event.characters.length>0) {
                unichar c = [event.characters characterAtIndex:0];
                if ([self.delegte respondsToSelector:@selector(keyUp:)]) {
                    [self.delegte keyUp:c];
                }
            }
        }];
    }
    return self;
}

- (void)dealloc
{
    [NSEvent removeMonitor:eventMonitor];
}

@end
