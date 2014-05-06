//
//  KeyMonitor.h
//  Quill
//
//  Created by Shintaro Morikawa on 2013/11/14.
//  Copyright (c) 2013年 Shintaro Morikawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KeyMonitorDelegate <NSObject>
@required
- (void)keyUp:(unichar)character;
@end

@interface KeyMonitor : NSObject

@property (nonatomic, weak) id<KeyMonitorDelegate> delegte;

@end
