//
//  MainViewController.h
//  Quill
//
//  Created by Shintaro Morikawa on 2013/11/20.
//  Copyright (c) 2013年 Shintaro Morikawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate, NSTextViewDelegate>

@property (strong) IBOutlet NSTableView *snippetTableView;
@property (strong, nonatomic) NSMutableDictionary *snippets;
@property (strong) IBOutlet NSTextView *textView;
@property (strong) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSView *emptyView;
@property (weak) IBOutlet NSButton *saveButton;
@property (weak) IBOutlet NSButton *deleteButton;

@end
