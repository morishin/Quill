//
//  MainViewController.m
//  Quill
//
//  Created by Shintaro Morikawa on 2013/11/20.
//  Copyright (c) 2013年 Shintaro Morikawa. All rights reserved.
//

#import "MainViewController.h"
#import "TrieTree.h"

@interface MainViewController () {
    TrieTree *trieTree_;
    NSTextView *textView_;
    NSTableView *tableView_;
    __weak NSView *emptyView_;
    __weak NSButton *saveButton_;
    __weak NSButton *deleteButton_;
}

@end

@implementation MainViewController

@synthesize tableView = tableView_, textView = textView_, emptyView = emptyView_, saveButton = saveButton_, deleteButton = deleteButton_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        trieTree_ = [TrieTree sharedTrieTree];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    [textView_ setAutomaticQuoteSubstitutionEnabled:NO];
    [self updateButtonsState];
}

#pragma mark - IBActions

- (IBAction)pressAdd:(id)sender {
    NSString *new_abbreviation;
    
    NSAlert *alert = [NSAlert alertWithMessageText:@"Input an abbreviation of a new snippet."
                                     defaultButton:@"Add"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];

    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 250, 24)];
    [alert setAccessoryView:input];
    
    NSInteger button = [alert runModal];

    if (button == NSAlertDefaultReturn) {
        [input validateEditing];
        new_abbreviation = [input stringValue];
    } else {
        new_abbreviation = nil;
    }
    
    if (new_abbreviation) {
        [trieTree_ addSnippetWithKey:new_abbreviation andValue:@""];
        [tableView_ reloadData];
        [tableView_ selectRowIndexes:[NSIndexSet indexSetWithIndex:trieTree_.snippets.count-1] byExtendingSelection:NO];
        [textView_.window makeFirstResponder:textView_];
    }
}

- (IBAction)pressSave:(id)sender {
    [trieTree_ addSnippetWithKey:trieTree_.snippets[tableView_.selectedRow][0] andValue:[NSString stringWithString:textView_.string]];
    [self updateButtonsState];
}

- (IBAction)pressDelete:(id)sender {
    NSAlert *alert = [NSAlert alertWithMessageText:@"Are you sure you want to delete?"
                                     defaultButton:@"Delete"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertDefaultReturn) {
            [trieTree_ removeSnippetWithKey:trieTree_.snippets[tableView_.selectedRow][0]];
            [tableView_ deselectAll:self];
            [tableView_ reloadData];
            [self updateButtonsState];
        }
    }];
}

#pragma mark - NSTableView Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return trieTree_.snippets.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([[tableColumn identifier] isEqualToString:@"name"]) {
        return trieTree_.snippets[row][0];
    }
    return nil;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView *tableView = notification.object;
    NSInteger row = [tableView selectedRow];
    
    if (row == -1) {
        [textView_ setString:@""];
        [textView_ setEditable:NO];
        [emptyView_ setHidden:NO];
        [deleteButton_ setEnabled:NO];
    } else {
        [textView_ setString:trieTree_.snippets[row][1]];
        [textView_ setEditable:YES];
        [emptyView_ setHidden:YES];
        [deleteButton_ setEnabled:YES];
    }

    [self updateButtonsState];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (![object isEqualToString:@""]) {
        [trieTree_ updateSnippetKeyFrom:trieTree_.snippets[row][0] To:(NSString *)object];
        [tableView reloadData];
    }
}

#pragma mark - NSTextViewDelegate

- (void)textDidChange:(NSNotification *)notification {
    [self updateButtonsState];
}

- (BOOL)doesSelectedItemHaveUnsavedChanges {
    return tableView_.selectedRow < trieTree_.snippets.count && ![textView_.string isEqualToString:trieTree_.snippets[tableView_.selectedRow][1]];
}

- (void)updateButtonsState {
    if (self.doesSelectedItemHaveUnsavedChanges) {
        [saveButton_ setTitle:@"Save *"];
        [saveButton_ setEnabled:YES];
    } else {
        [saveButton_ setTitle:@"Save"];
        [saveButton_ setEnabled:NO];
    }
}

@end
