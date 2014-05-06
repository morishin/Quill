//
//  CustomTextField.h
//  Quill
//
//  Created by Shintaro Morikawa on 2013/12/01.
//  Copyright (c) 2013年 Shintaro Morikawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTextField (Command)

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent;

@end
