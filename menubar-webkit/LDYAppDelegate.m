//
//  LDYAppDelegate.m
//  menubar-webkit
//
//  Created by Xhacker Liu on 3/25/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import "LDYAppDelegate.h"

@interface LDYAppDelegate ()

@property NSStatusItem *statusItem;

@end

@implementation LDYAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSStatusBar *bar = [NSStatusBar systemStatusBar];

    self.statusItem = [bar statusItemWithLength:NSVariableStatusItemLength];

    self.statusItem.title = @"Xhacker";
    self.statusItem.highlightMode = YES;
}

@end
