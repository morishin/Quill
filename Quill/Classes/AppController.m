//
//  AppController.m
//  Quill
//
//  Created by Shintaro Morikawa on 2013/11/14.
//  Copyright (c) 2013年 Shintaro Morikawa. All rights reserved.
//

#import "AppController.h"

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
        if (accept!=NULL) {
            NSString *data = [NSString stringWithUTF8String:accept->data];
            unsigned int depth = accept->depth;
            
            /*
            // The following code loses non-string data in clipborad...
            NSString *script = [NSString stringWithFormat:@"tell application \"System Events\"\n repeat %d times\n key code 51\n end repeat\n set buffer to the clipboard\n set the clipboard to \"%@\"\n delay 0.01\n keystroke \"v\" using command down\n delay 0.01\n set the clipboard to buffer\n end tell\n", depth-1, data];
            NSAppleScript *key = [[NSAppleScript alloc] initWithSource:script];
            [key executeAndReturnError:nil];
            */
            
            // The following code save existing clipboard data PROBABLY...
            NSPasteboard *pboard = [NSPasteboard generalPasteboard];
            NSMutableArray *dataBuffer = [[NSMutableArray alloc] init];
            NSMutableArray *typeBuffer = [[NSMutableArray alloc] init];
            NSString *type;
            for (NSPasteboardItem *item in [pboard pasteboardItems]) {
                type = [item types][0];
                [dataBuffer addObject:[item dataForType:type]];
                [typeBuffer addObject:type];
            }
            [pboard clearContents];
            [pboard setString:data forType:NSPasteboardTypeString];
            
            [self postDeleteAndPasteEvent:depth-1];

            // must wait for cotion of paste (it looks bad solution...)
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
            
            NSPasteboardItem *item;
            NSMutableArray *items = [[NSMutableArray alloc] init];
            for (int i=0; i<dataBuffer.count; i++) {
                item = [[NSPasteboardItem alloc] init];
                [item setData:dataBuffer[i] forType:typeBuffer[i]];
                [items addObject:item];
            }
            [pboard clearContents];
            [pboard writeObjects:items];
        }
    }
}


@end
