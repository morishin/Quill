//
//  AppDelegate.m
//  Quill
//
//  Created by Shintaro Morikawa on 2013/10/28.
//  Copyright (c) 2013年 Shintaro Morikawa. All rights reserved.
//

#import "AppDelegate.h"
#import "AppController.h"
#import "NSApplication+SelfRelaunch.h"

#define MENU_ITEM_OPEN @"Open"
#define MENU_ITEM_PREFERENCES @"Preferences"
#define MENU_ITEM_QUIT @"Quit"

@interface AppDelegate () {
    NSStatusItem *statusItem_;
    AppController *appController_;
}
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setupStatusItem];
    
    appController_ = [[AppController alloc] init];

    NSDictionary *options = @{(__bridge id) kAXTrustedCheckOptionPrompt : @YES};
    BOOL accessibilityEnabled = AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef) options);
    if (!accessibilityEnabled) {
        NSAlert *alert = [NSAlert new];
        alert.messageText = @"Add Quill.app to the list in Accessibility preference pane.";
        [alert addButtonWithTitle:@"Restart Quill"];
        [alert addButtonWithTitle:@"Quit"];
        alert.informativeText = @"(System Preferences > Security & Privacy > Privacy > Accessibility)\n\nAnd you need to restart this app.";
        NSModalResponse response = [alert runModal];
        if (response == NSAlertFirstButtonReturn) {
            [NSApp relaunchAfterDelay:0.5];
        } else if (response == NSAlertSecondButtonReturn) {
            [NSApp terminate:nil];
        }
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self openMenuWindow];
}

- (void)setupStatusItem {
    NSMenu *statusMenu_ = [[NSMenu alloc] init];
    NSStatusBar *systemStatusBar = [NSStatusBar systemStatusBar];
    statusItem_ = [systemStatusBar statusItemWithLength:NSSquareStatusItemLength];
    [statusItem_ setHighlightMode:YES];
    NSImage *image = [NSImage imageNamed:@"menu_icon"];
    [image setTemplate:YES];
    [statusItem_ setImage:image];
    [statusItem_ setMenu:statusMenu_];
    [statusMenu_ addItemWithTitle:MENU_ITEM_OPEN action:@selector(openMenuWindow) keyEquivalent:@""];
    [statusMenu_ addItemWithTitle:MENU_ITEM_QUIT action:@selector(terminate:) keyEquivalent:@""];
}

- (void)openMenuWindow {
    if ([appController_ respondsToSelector:@selector(openMainWindow)]) {
        [appController_ openMainWindow];
    }
}

@end
