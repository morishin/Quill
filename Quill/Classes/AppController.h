//
//  AppController.h
//  Quill
//
//  Created by Shintaro Morikawa on 2013/11/14.
//  Copyright (c) 2013年 Shintaro Morikawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>
#import "TrieTree.h"
#import "KeyMonitor.h"
#import "MainViewController.h"

@interface AppController : NSObject<KeyMonitorDelegate> {
    NSWindowController *mainWindowController_;
    MainViewController *mainViewController_;
}
- (void)openMainWindow;
- (void)keyUp:(unichar)character;

@end
