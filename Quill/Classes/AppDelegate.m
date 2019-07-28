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
#import "Quill-Swift.h"

#define MENU_ITEM_OPEN @"Open"
#define MENU_ITEM_LICENSE @"Purchase License"
#define MENU_ITEM_QUIT @"Quit"

@interface AppDelegate () {
    NSStatusItem *statusItem_;
    AppController *appController_;
    BOOL accessibilityEnabled;
}
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setupStatusItem];
    
    appController_ = [[AppController alloc] init];

    NSDictionary *options = @{(__bridge id) kAXTrustedCheckOptionPrompt : @YES};
    accessibilityEnabled = AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef) options);

    if (!accessibilityEnabled) {
        [self showAccessibilityAlert];
    } else {
        [self openMenuWindow];
    }
}

- (void)showAccessibilityAlert {
    NSAlert *alert = [NSAlert new];
    alert.messageText = @"Add Quill.app to the list in Accessibility preference pane.";
    [alert addButtonWithTitle:@"Restart Quill"];
    NSButton *preferenceButton = [alert addButtonWithTitle:@"Open System Preferences"];
    [preferenceButton setTarget:self];
    [preferenceButton setAction:@selector(openPreference)];
    [alert addButtonWithTitle:@"Quit"];
    alert.informativeText = @"Go to System Preferences > Security & Privacy > Privacy > Accessibility\nDrag & Drop Quill.app into the list and you need restart this app.";

    NSModalResponse response = [alert runModal];
    if (response == NSAlertFirstButtonReturn) {
        [NSApp relaunchAfterDelay:0.5];
    } else if (response == NSAlertThirdButtonReturn) {
        [NSApp terminate:nil];
    }
}

- (void)openPreference {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"]];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (!accessibilityEnabled) { return; }
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
    [statusMenu_ addItemWithTitle:MENU_ITEM_LICENSE action:@selector(openLicenseWindow) keyEquivalent:@""];
    [statusMenu_ addItemWithTitle:MENU_ITEM_QUIT action:@selector(terminate:) keyEquivalent:@""];
}

- (void)openMenuWindow {
    if ([appController_ respondsToSelector:@selector(openMainWindow)]) {
        [appController_ openMainWindow];
    }
}

- (void)openLicenseWindow {
    if (LicenseManagerForObjC.isActivated) {
        NSAlert *alert = [NSAlert new];
        alert.messageText = @"You have already purchased! ❤️";
        alert.informativeText = [NSString stringWithFormat:@"Email: %@\nLicense Key: %@", LicenseManagerForObjC.email, LicenseManagerForObjC.licenseKey];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
        return;
    }
    if ([appController_ respondsToSelector:@selector(openLicenseWindow)]) {
        [appController_ openLicenseWindow];
    }
}

@end
