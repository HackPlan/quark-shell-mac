//
//  LDYAppDelegate.m
//  menubar-webkit
//
//  Created by Xhacker Liu on 3/25/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import "LDYAppDelegate.h"
#import "LDYWebViewDelegate.h"

static NSString * const kIndexPath = @"public/index.html";

@interface LDYAppDelegate ()

@property NSStatusItem *statusItem;
@property (weak) IBOutlet WebView *webView;
@property LDYWebViewDelegate *webViewDelegate;

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

    self.webViewDelegate = [[LDYWebViewDelegate alloc] init];
    self.webView.frameLoadDelegate = self.webViewDelegate;
    self.webView.UIDelegate = self.webViewDelegate;
}

- (void)statusItemClicked
{
    self.window.isVisible = !self.window.isVisible;
}

@end
