//
//  MainViewController.m
//  Quill
//
//  Created by Shintaro Morikawa on 2013/11/20.
//  Copyright (c) 2013年 Shintaro Morikawa. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import "Quill-Swift.h"

@interface MainViewController () <NSWindowDelegate> {
    TrieTreeManager *trieTree_;
    NSTextView *textView_;
    NSTableView *tableView_;
    __weak NSView *emptyView_;
    __weak NSButton *saveButton_;
    __weak NSButton *deleteButton_;
    id eventMonitor;
    BOOL shouldSuppressConfirm;
    BOOL isConfirmShown;
}

@end

@implementation MainViewController

@synthesize tableView = tableView_, textView = textView_, emptyView = emptyView_, saveButton = saveButton_, deleteButton = deleteButton_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        trieTree_ = [TrieTreeManager shared];
        shouldSuppressConfirm = NO;
        isConfirmShown = NO;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    [textView_ setAutomaticQuoteSubstitutionEnabled:NO];
    [tableView_ setAllowsMultipleSelection:NO];
    [tableView_ setDoubleAction:@selector(tableViewCellDidDoubleClick:)];
    NSMenu *menu = [NSMenu new];
    [menu addItemWithTitle:@"Add" action:@selector(addItem) keyEquivalent:@""];
    [menu addItemWithTitle:@"Delete" action:@selector(deleteClickedItem) keyEquivalent:@""];
    tableView_.menu = menu;
}

- (void)viewWillAppear {
    [super viewWillAppear];
    self.view.window.delegate = self;
    eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^(NSEvent *theEvent) {
        if ([theEvent modifierFlags] & NSEventModifierFlagCommand && [theEvent keyCode] == 1) {
            // ⌘S
            [self saveCurrentSnippet];
            return (NSEvent *)nil;
        } else if ([theEvent modifierFlags] & NSEventModifierFlagCommand && [theEvent keyCode] == 13) {
            // ⌘W
            [self.view.window performClose:nil];
            return (NSEvent *)nil;
        }
//        } else if ([theEvent keyCode] == 51){
//            if (self.view.window.firstResponder == self.tableView) {
//                [self deleteSelectedItem];
//            }
//        }
        return theEvent;
    }];
    [tableView_ reloadData];
    [self updateButtonsState];
}

- (void)viewDidDisappear {
    [super viewDidDisappear];
    [NSEvent removeMonitor:eventMonitor];
}

- (void)saveCurrentSnippet {
    if (tableView_.selectedRow < 0 || tableView_.selectedRow >= trieTree_.snippets.count) {
        return;
    }

    NSError *saveError = nil;
    [trieTree_ addSnippetWith:trieTree_.snippets[tableView_.selectedRow][0] value:[NSString stringWithString:textView_.string] error:&saveError];
    if (saveError != nil) {
        [self showFailedToSaveAlert];
    }

    [self updateButtonsState];
}

- (void)deleteSelectedItem {
    [self deleteItem:tableView_.selectedRow];
}

- (void)deleteClickedItem {
    [self deleteItem:tableView_.clickedRow];
}

- (void)showFailedToSaveAlert {
    NSAlert *alert = [NSAlert new];
    alert.messageText = @"Failed to save snippets.";
    [alert addButtonWithTitle:@"Close"];
    [alert runModal];
}

- (void)showPurchaseAlert {
    NSAlert *alert = [NSAlert new];
    alert.messageText = @"You need purchase license to add an item.";
    [alert addButtonWithTitle:@"Purchase License"];
    [alert addButtonWithTitle:@"Cancel"];
    NSModalResponse returnCode = [alert runModal];
    if (returnCode == NSAlertFirstButtonReturn) {
        AppDelegate *appDelegate = (AppDelegate *)NSApp.delegate;
        [appDelegate openLicenseWindow];
    }
}

- (void)deleteItem:(NSInteger)index {
    if (index < 0 || index >= trieTree_.snippets.count) {
        return;
    }
    NSAlert *alert = [NSAlert new];
    alert.messageText = @"Are you sure you want to delete?";
    [alert addButtonWithTitle:@"Delete"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            NSError *saveError = nil;
            [self->trieTree_ removeSnippetWith:self->trieTree_.snippets[index][0] error:&saveError];
            if (saveError != nil) {
                [self showFailedToSaveAlert];
                [self updateButtonsState];
                return;
            }

            [self->tableView_ deselectAll:self];
            [self->tableView_ reloadData];
            [self updateButtonsState];
        }
    }];
}

- (void)addItem {
    if (![LicenseManagerForObjC isActivated]) {
        [self showPurchaseAlert];
        return;
    }

    NSString *new_abbreviation;

    NSAlert *alert = [NSAlert new];
    alert.messageText = @"Input an abbreviation of a new snippet.";
    [alert addButtonWithTitle:@"Add"];
    [alert addButtonWithTitle:@"Cancel"];

    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 250, 24)];
    [input setPlaceholderString:@"`img"];
    [alert setAccessoryView:input];
    [[alert window] setInitialFirstResponder:input];

    NSInteger button = [alert runModal];

    if (button == NSAlertFirstButtonReturn) {
        [input validateEditing];
        new_abbreviation = [input stringValue];
    } else {
        new_abbreviation = nil;
    }

    if (new_abbreviation) {
        NSError *saveError = nil;
        [trieTree_ addSnippetWith:new_abbreviation value:@"" error:&saveError];
        if (saveError != nil) {
            [self showFailedToSaveAlert];
        }
        [tableView_ reloadData];
        [tableView_ selectRowIndexes:[NSIndexSet indexSetWithIndex:trieTree_.snippets.count-1] byExtendingSelection:NO];
        [textView_.window makeFirstResponder:textView_];
    }
}

#pragma mark - IBActions

- (IBAction)pressAdd:(id)sender {
    [self addItem];
}

- (IBAction)pressSave:(id)sender {
    [self saveCurrentSnippet];
}

- (IBAction)pressDelete:(id)sender {
    [self deleteSelectedItem];
}

- (void)tableViewCellDidDoubleClick:(NSTableView *)tableView {
    [tableView editColumn:0 row:tableView.clickedRow withEvent:nil select:YES];
}

#pragma mark - NSTableView Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (LicenseManagerForObjC.isActivated) {
        return trieTree_.snippets.count;
    } else {
        return 1;
    }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([[tableColumn identifier] isEqualToString:@"name"]) {
        return trieTree_.snippets[row][0];
    }
    return nil;
}

- (NSIndexSet *)tableView:(NSTableView *)tableView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes {
    if (shouldSuppressConfirm) {
        shouldSuppressConfirm = NO;
        return proposedSelectionIndexes;
    }
    if (![self doesSelectedItemHaveUnsavedChanges]) {
        return proposedSelectionIndexes;
    }
    [self confirmDiscardChangesIfNeeded:self.view.window completion:^(BOOL discard) {
        [tableView selectRowIndexes:proposedSelectionIndexes byExtendingSelection:NO];
    }];
    return tableView.selectedRowIndexes;
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
        NSError *saveError = nil;
        [trieTree_ addSnippetWith:trieTree_.snippets[row][0] value:(NSString *)object error:&saveError];
        if (saveError != nil) {
            [self showFailedToSaveAlert];
        }
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

- (void)confirmDiscardChangesIfNeeded:(NSWindow *)window completion:(nullable void (^)(BOOL discard))completion {
    if (isConfirmShown) { return; }
    if ([self doesSelectedItemHaveUnsavedChanges]) {
        NSAlert *alert = [NSAlert new];
        alert.messageText = @"Do you want to save the changes?";
        [alert addButtonWithTitle:@"Save"];
        [alert addButtonWithTitle:@"Don't Save"];
        [alert beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == NSAlertFirstButtonReturn) {
                [self saveCurrentSnippet];
                if (completion != nil) {
                    completion(NO);
                }
            } else {
                if (completion != nil) {
                    completion(YES);
                }
            }
            [window.attachedSheet close];
            self->isConfirmShown = NO;
        }];
        isConfirmShown = YES;
    }
}

- (BOOL)textView:(NSTextView *)aTextView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertTab:)) {
        [aTextView insertText:@"    " replacementRange:NSMakeRange(-1, 0)];
        return YES;
    }
    return NO;
}

#pragma mark - NSWindowDelegate

- (BOOL)windowShouldClose:(NSWindow *)sender {
    if (![self doesSelectedItemHaveUnsavedChanges]) {
        return YES;
    }
    [self confirmDiscardChangesIfNeeded:sender completion:^(BOOL discard) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self->shouldSuppressConfirm = YES;
            [self.tableView deselectAll:nil];
            [sender close];
        });
    }];
    return NO;
}

@end
