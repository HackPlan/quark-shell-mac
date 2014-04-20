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
@property NSButton *buttonItem;
@property (weak) IBOutlet WebView *webView;
@property LDYWebViewDelegate *webViewDelegate;

@end

@implementation LDYAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSStatusBar *bar = [NSStatusBar systemStatusBar];

    self.statusItem = [bar statusItemWithLength:NSSquareStatusItemLength];
    self.statusItem.highlightMode = YES;
    [self.statusItem setAction:@selector(statusItemClicked)];

    // TODO: need custom view
    self.buttonItem = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
    self.buttonItem.target = self;
    self.buttonItem.action = @selector(statusItemClicked);
    self.statusItem.view = self.buttonItem;

    self.window.level = NSStatusWindowLevel;
    [self.window setOpaque:NO];
    [self.window setBackgroundColor:[NSColor clearColor]];

    [self.webView setDrawsBackground:NO];

    NSString *url = [[NSURL URLWithString:kIndexPath relativeToURL:[[NSBundle mainBundle] resourceURL]] absoluteString];
    self.webView.mainFrameURL = url;

    self.webViewDelegate = [[LDYWebViewDelegate alloc] init];
    self.webView.frameLoadDelegate = self.webViewDelegate;
    self.webView.UIDelegate = self.webViewDelegate;
}

- (void)statusItemClicked
{
    self.window.isVisible = !self.window.isVisible;

    NSRect itemFrame = self.statusItem.view.window.frame;
    NSRect windowFrame = self.window.frame;
    windowFrame.origin.x = NSMidX(itemFrame) - NSWidth(windowFrame) / 2.0;
    windowFrame.origin.y = NSMinY(itemFrame) - NSHeight(windowFrame);
    [self.window setFrame:windowFrame display:NO];
}

@end
