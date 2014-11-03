//
//  LDYAppDelegate.m
//  menubar-webkit
//
//  Created by Xhacker Liu on 3/25/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import "LDYAppDelegate.h"
#import "LDYWebViewDelegate.h"
#import "LDYStatusItemView.h"

@interface WebPreferences (WebPreferencesPrivate)

- (void)_setLocalStorageDatabasePath:(NSString *)path;
- (void)setLocalStorageEnabled:(BOOL)localStorageEnabled;

@end


@interface LDYAppDelegate () <NSWindowDelegate>

@property (nonatomic) NSStatusItem *statusItem;
@property (nonatomic) LDYStatusItemView *statusItemView;
@property (nonatomic, weak) IBOutlet WebView *webView;
@property (nonatomic) LDYWebViewDelegate *webViewDelegate;

@end

@implementation LDYAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // TODO: bundle identifier should be generated from manifest.json
    WebPreferences *webPrefs = [WebPreferences standardPreferences];
    NSString *bundleIdentifier = [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
    NSString *applicationSupportFile = [@"~/Library/Application Support/" stringByExpandingTildeInPath];
    NSString *savePath = [NSString pathWithComponents:@[applicationSupportFile, bundleIdentifier, @"LocalStorage"]];
    [webPrefs _setLocalStorageDatabasePath:savePath];
    [webPrefs setLocalStorageEnabled:YES];

    NSStatusBar *bar = [NSStatusBar systemStatusBar];

    self.statusItem = [bar statusItemWithLength:NSSquareStatusItemLength];
    if (IS_PERIOR_TO_10_9) {
        self.statusItemView = [[LDYStatusItemView alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
        self.statusItemView.target = self;
        self.statusItemView.action = @selector(statusItemClicked);
        self.statusItem.view = self.statusItemView;
        self.statusItemView.statusItem = self.statusItem;
    }
    else {
        NSImage *statusIcon = [NSImage imageNamed:@"StatusIcon"];
        [statusIcon setTemplate:YES];
        self.statusItem.button.image = statusIcon;

        self.statusItem.button.target = self;
        self.statusItem.button.action = @selector(statusItemClicked);
    }


    self.window.level = NSFloatingWindowLevel;
    self.window.delegate = self;
    [self.window setOpaque:NO];
    [self.window setBackgroundColor:[NSColor clearColor]];

    self.webView.wantsLayer = YES;
    self.webView.layer.cornerRadius = 5;
    self.webView.layer.masksToBounds = YES;
    [self.webView setDrawsBackground:NO];

    NSString *url = [[NSURL URLWithString:kIndexPath relativeToURL:[[NSBundle mainBundle] resourceURL]] absoluteString];
    self.webView.mainFrameURL = url;

    self.webViewDelegate = [[LDYWebViewDelegate alloc] init];
    self.webViewDelegate.appDelegate = self;
    self.webViewDelegate.statusItem = self.statusItem;
    self.webViewDelegate.statusItemView = self.statusItemView;
    self.webViewDelegate.webView = self.webView;
    self.webView.frameLoadDelegate = self.webViewDelegate;
    self.webView.UIDelegate = self.webViewDelegate;
}

- (void)windowDidResignKey:(NSNotification *)notification
{
    if (!self.pinned) {
        self.window.isVisible = NO;
        [self refreshStyle];
    }
}

- (void)showWindow
{
    self.window.isVisible = YES;
    [self refreshStyle];
}

- (void)hideWindow
{
    self.window.isVisible = NO;
    [self refreshStyle];
}

- (void)statusItemClicked
{
    self.window.isVisible = !self.window.isVisible;
    [self refreshStyle];
}

- (void)refreshStyle
{
    NSRect itemFrame;

    if (IS_PERIOR_TO_10_9) {
        self.statusItemView.itemHighlighted = self.window.isVisible;
        itemFrame = self.statusItem.view.window.frame;
    }
    else {
        itemFrame = self.statusItem.button.window.frame;
    }

    NSRect windowFrame = self.window.frame;
    windowFrame.origin.x = NSMidX(itemFrame) - NSWidth(windowFrame) / 2.0;
    windowFrame.origin.y = NSMinY(itemFrame) - NSHeight(windowFrame);
    [self.window setFrame:windowFrame display:NO];

    if (self.window.isVisible) {
        [self.window makeKeyAndOrderFront:nil];
        [NSApp activateIgnoringOtherApps:YES];
    }
}

@end
