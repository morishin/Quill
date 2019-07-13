//
//  CustomTextView.m
//  Quill
//
//  Created by Shintaro Morikawa on 2013/12/01.
//  Copyright (c) 2013年 Shintaro Morikawa. All rights reserved.
//

#import "NSTextView+Command.h"

@implementation NSTextView (Command)

//cf. http://sunbruce.wordpress.com/2008/05/19/how-to-enable-keyboard-copycutpaste-shortcuts-in-nstextfield/
- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
    if (([theEvent type] == NSEventTypeKeyDown) && ([theEvent modifierFlags] & NSEventModifierFlagCommand))
    {
        NSResponder * responder = [self.window firstResponder];
        
        if ((responder != nil) && [responder isKindOfClass:[NSTextView class]])
        {
            NSTextView * textView = (NSTextView *)responder;
            NSRange range = [textView selectedRange];
            bool bHasSelectedTexts = (range.length > 0);
            
            unsigned short keyCode = [theEvent keyCode];
            
            bool bHandled = false;
            
            //0 A, 6 Z, 7 X, 8 C, 9 V
            if (keyCode == 0) {
                [textView selectAll:nil];
                bHandled = true;
            }
            else if (keyCode == 6)
            {
                if ([[textView undoManager] canUndo])
                {
                    [[textView undoManager] undo];
                    bHandled = true;
                }
            }
            else if (keyCode == 7 && bHasSelectedTexts)
            {
                [textView cut:self];
                bHandled = true;
            }
            else if (keyCode== 8 && bHasSelectedTexts)
            {
                [textView copy:self];
                bHandled = true;
            }
            else if (keyCode == 9)
            {
                [textView paste:self];
                bHandled = true;
            }
            
            if (bHandled)
                return YES;
        }
    }
    
    return NO;
}

@end
