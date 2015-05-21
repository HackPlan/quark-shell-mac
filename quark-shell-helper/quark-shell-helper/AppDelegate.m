//
//  AppDelegate.m
//  quark-shell-helper
//
//  Created by Dongyuan Liu on 2015-05-20.
//  Copyright (c) 2015 Hackplan. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString *appPath = [[NSBundle mainBundle] bundlePath].stringByDeletingLastPathComponent.stringByDeletingLastPathComponent.stringByDeletingLastPathComponent.stringByDeletingLastPathComponent;
    // get to the waaay top. Goes through LoginItems, Library, Contents, Applications
    [[NSWorkspace sharedWorkspace] launchApplication:appPath];
    [NSApp terminate:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
