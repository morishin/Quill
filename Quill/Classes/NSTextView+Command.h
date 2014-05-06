//
//  CustomTextView.h
//  Quill
//
//  Created by Shintaro Morikawa on 2013/12/01.
//  Copyright (c) 2013年 Shintaro Morikawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTextView (Command)

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent;

@end
