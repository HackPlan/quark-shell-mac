//
//  LDYAppDelegate.m
//  menubar-webkit
//
//  Created by Xhacker Liu on 3/25/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import "LDYAppDelegate.h"
#import <WebKit/WebKit.h>

static NSString * const kIndexPath = @"public/index.html";

@interface LDYAppDelegate ()

@property NSStatusItem *statusItem;
@property (weak) IBOutlet WebView *webView;

@end

@implementation LDYAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSStatusBar *bar = [NSStatusBar systemStatusBar];

    self.statusItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.title = @"Xhacker";
    self.statusItem.highlightMode = YES;
    [self.statusItem setAction:@selector(statusItemClicked)];

    self.window.level = NSStatusWindowLevel;

    NSString *url = [[NSURL URLWithString:kIndexPath relativeToURL:[[NSBundle mainBundle] resourceURL]] absoluteString];
    self.webView.mainFrameURL = url;
}

- (void)statusItemClicked
{
    self.window.isVisible = !self.window.isVisible;
}

@end
