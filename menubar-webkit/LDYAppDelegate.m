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

static NSString * const kIndexPath = @"public/index.html";

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
    // TODO: bundle name from manifest?
    WebPreferences *webPrefs = [WebPreferences standardPreferences];
    NSString *bundleName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    NSString *applicationSupportFile = [@"~/Library/Application Support/" stringByExpandingTildeInPath];
    NSString *savePath = [NSString pathWithComponents:@[applicationSupportFile, bundleName, @"LocalStorage"]];
    [webPrefs _setLocalStorageDatabasePath:savePath];
    [webPrefs setLocalStorageEnabled:YES];

    NSStatusBar *bar = [NSStatusBar systemStatusBar];

    self.statusItem = [bar statusItemWithLength:NSSquareStatusItemLength];
    self.statusItemView = [[LDYStatusItemView alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
    self.statusItemView.target = self;
    self.statusItemView.action = @selector(statusItemClicked);
    self.statusItem.view = self.statusItemView;
    self.statusItemView.statusItem = self.statusItem;

    self.window.level = NSPopUpMenuWindowLevel;
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
    self.webViewDelegate.statusItemView = self.statusItemView;
    self.webViewDelegate.webView = self.webView;
    self.webView.frameLoadDelegate = self.webViewDelegate;
    self.webView.UIDelegate = self.webViewDelegate;
}

- (void)windowDidResignKey:(NSNotification *)notification
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
    self.statusItemView.highlighted = self.window.isVisible;

    NSRect itemFrame = self.statusItem.view.window.frame;
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
