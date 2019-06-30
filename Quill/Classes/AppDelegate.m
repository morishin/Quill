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
        NSAlert *alert = [NSAlert alertWithMessageText:@"Add Quill.app to the list in Accessibility preference pane." defaultButton:@"Restart Quill" alternateButton:@"Quit" otherButton:nil informativeTextWithFormat:@"(System Preferences > Security & Privacy > Privacy > Accessibility)\n\nAnd you need to restart this app."];
        NSModalResponse response = [alert runModal];
        if (response == NSAlertDefaultReturn) {
            [NSApp relaunchAfterDelay:0.5];
        } else if (response == NSAlertAlternateReturn) {
            [NSApp terminate:nil];
        }
    }
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
    [statusMenu_ addItemWithTitle:MENU_ITEM_OPEN action:@selector(openWindow:) keyEquivalent:@""];
    [statusMenu_ addItemWithTitle:MENU_ITEM_QUIT action:@selector(terminate:) keyEquivalent:@""];
}

- (void)openWindow:(id)sender {
    NSString *itemName = ((NSMenuItem *)sender).title;
    if ([itemName isEqualToString:MENU_ITEM_OPEN]
        && [appController_ respondsToSelector:@selector(openMainWindow)]) {
        [appController_ openMainWindow];
//    } else if ([itemName isEqualToString:MENU_ITEM_PREFERENCES]
//                && [appController_ respondsToSelector:@selector(openPreferenceWindow)]) {
//        [appController_ openPreferenceWindow];
    } else {
        ALog(@"invalid menu item");
    }
}

@end
