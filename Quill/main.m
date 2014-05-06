//
//  main.m
//  Quill
//
//  Created by Shintaro Morikawa on 2013/10/28.
//  Copyright (c) 2013年 Shintaro Morikawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    // make sure the application singleton has been instantiated
    NSApplication *application = [NSApplication sharedApplication];
    
    // instantiate our application delegate
    AppDelegate *applicationDelegate = [[AppDelegate alloc] init];
    
    // assign our delegate to the NSApplication
    [application setDelegate:applicationDelegate];
    
    // call the run method of our application
    [application run];
    
    // execution never gets here ..
    return 0;
}