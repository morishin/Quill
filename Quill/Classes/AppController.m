//
//  AppController.m
//  Quill
//
//  Created by Shintaro Morikawa on 2013/11/14.
//  Copyright (c) 2013年 Shintaro Morikawa. All rights reserved.
//

#import "AppController.h"
#import "NSPasteboard+NSPasteboard_Stash.h"

@interface AppController () {
    TrieTree *trieTree_;
    KeyMonitor *keyMonitor_;
    __weak NSWindow * _mainWindow;
}
@end

@implementation AppController
- (id)init
{
    self = [super init];
    if (self) {
        trieTree_ = [TrieTree sharedTrieTree];
        keyMonitor_ = [[KeyMonitor alloc] init];
        keyMonitor_.delegte = self;
        _mainWindow = nil;
    }
    return self;
}

- (void)postDeleteAndPasteEvent:(int)nDeletes {
    CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateCombinedSessionState);
    
    CGEventRef deleteDown = CGEventCreateKeyboardEvent(source, kVK_Delete, true);
    CGEventRef deleteUp = CGEventCreateKeyboardEvent(source, kVK_Delete, false);
    CGEventRef pasteCommandDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_V, YES);
    CGEventRef pasteCommandUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_V, NO);
    CGEventSetFlags(pasteCommandDown, kCGEventFlagMaskCommand);
    
    CGEventTapLocation loc = kCGSessionEventTap;
    
    for (int i=0; i<nDeletes; i++) {
        CGEventPost(loc, deleteDown);
        CGEventPost(loc, deleteUp);
    }
    CGEventPost(loc, pasteCommandDown);
    CGEventPost(loc, pasteCommandUp);
    
    CFRelease(deleteDown);
    CFRelease(deleteUp);
    CFRelease(pasteCommandUp);
    CFRelease(pasteCommandDown);
    CFRelease(source);
}

#pragma mark
- (void)openMainWindow {
    if (_mainWindow == nil) {
        mainViewController_ = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
        _mainWindow = [self createWindowWithContentView:mainViewController_.view];
        [_mainWindow setTitle:@"Quill"];
        mainWindowController_ = [[NSWindowController alloc] initWithWindow:_mainWindow];
    }
    [mainWindowController_ showWindow:self];
    [NSApp activateIgnoringOtherApps:YES];
}

- (NSWindow *)createWindowWithContentView:(NSView *)view {
    NSRect frame = NSMakeRect(0, 0, view.frame.size.width, view.frame.size.height+22);
    NSUInteger styleMask = (NSWindowStyleMaskTitled
                            | NSWindowStyleMaskClosable
                            | NSWindowStyleMaskMiniaturizable
                            /*| NSResizableWindowMask*/);
    NSRect rect = [NSWindow contentRectForFrameRect:frame styleMask:styleMask];
    NSWindow *window = [[NSWindow alloc] initWithContentRect:rect
                                                   styleMask:styleMask
                                                     backing:NSBackingStoreBuffered
                                                       defer:false];
    [window center];
    [window setContentView:view];
    return window;
}

#pragma mark - KeyMonitorDelegate method
- (void)keyUp:(unichar)character {
    if (0<=character && character<256) {
        TrieNode *accept = [trieTree_ stateTransit:character];
        if (accept != NULL) {
            NSString *data = [NSString stringWithUTF8String:accept->data];
            unsigned int depth = accept->depth;

            // Save current pasteboard state
            NSPasteboard *pboard = [NSPasteboard generalPasteboard];
            NSArray *savedPasteboardItems = [pboard save];

            // Paste snippet
            [pboard clearContents];
            [pboard setString:data forType:NSPasteboardTypeString];
            [self postDeleteAndPasteEvent:depth-1];

            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

            // Restore current pasteboard state
            [pboard restore:savedPasteboardItems];
        }
    }
}


@end
