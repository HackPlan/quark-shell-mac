//
//  QSHAppDelegate.m
//  quark-shell
//
//  Created by Xhacker Liu on 3/25/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "QSHAppDelegate.h"
#import "QSHWebView.h"
#import "QSHWebViewDelegate.h"
#import "QSHStatusItemView.h"
#import "NSWindow+Fade.h"
#import "WKWebViewJavascriptBridge.h"

@interface QSHAppDelegate () <NSWindowDelegate>

@property (nonatomic) NSStatusItem *statusItem;
@property (nonatomic) QSHStatusItemView *statusItemView;
@property (nonatomic) QSHWebViewDelegate *webViewDelegate;

@end

@implementation QSHAppDelegate {
    QSHWebView *_webView;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // TODO: bundle identifier should be generated from manifest.json
    NSString *bundleIdentifier = [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
    NSString *applicationSupportFile = [@"~/Library/Application Support/" stringByExpandingTildeInPath];
    NSString *savePath = [NSString pathWithComponents:@[applicationSupportFile, bundleIdentifier, @"LocalStorage"]];
    
    self.webViewDelegate = [[QSHWebViewDelegate alloc] init];
    
    [self setupStatusItemAndWindow];
    [self setupWebView];
    
    self.webViewDelegate.appDelegate = self;
    self.webViewDelegate.statusItem = self.statusItem;
    self.webViewDelegate.statusItemView = self.statusItemView;
    self.webViewDelegate.webView = _webView;
//    _webView.navigationDelegate = self.webViewDelegate;
    _webView.UIDelegate = self.webViewDelegate;
}

- (void)setupStatusItemAndWindow
{
    NSStatusBar *bar = [NSStatusBar systemStatusBar];

    self.statusItem = [bar statusItemWithLength:NSSquareStatusItemLength];

    NSImage *statusIcon = [NSImage imageNamed:@"StatusIcon"];
    [statusIcon setTemplate:YES];
    self.statusItem.button.image = statusIcon;

    self.statusItem.button.target = self;
    self.statusItem.button.action = @selector(statusItemClicked);
    [self.statusItem.button sendActionOn:(NSLeftMouseDownMask | NSRightMouseDownMask)];

    self.window.level = NSFloatingWindowLevel;
    self.window.delegate = self;
    [self.window setOpaque:NO];
    [self.window setBackgroundColor:[NSColor clearColor]];
}

- (void)_createViews {
    NSView* contentView = _window.contentView;
    
    // WKWebView
    _webView = [[QSHWebView alloc] initWithFrame:contentView.frame];
    [_webView setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];
    _webView.configuration.preferences._developerExtrasEnabled = YES;
    [contentView addSubview:_webView];
}

- (void)setupWebView
{
    [self _createViews];
    NSURL *URL = [NSURL URLWithString:kIndexPath relativeToURL:[[NSBundle mainBundle] resourceURL]];
    [QSHWebViewDelegate initWebviewWithBridge:_webView url:URL webDelegate:self.webViewDelegate isMain:YES];
}

- (void)windowDidResignKey:(NSNotification *)notification
{
    if (!self.pinned) {
        [self hideWindow];
    }
}

- (void)showWindow
{
    self.shouldBeVisible = true;
    [self refreshStyle];

    [self.window makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)hideWindow
{
    self.shouldBeVisible = false;
    [self refreshStyle];

    [self.window fadeOut];
}

- (void)toggleWindow
{
    if (self.window.visible) {
        [self hideWindow];
    }
    else {
        [self showWindow];
    }
}


- (void)resizeWindow:(CGSize)size
{
    [self.window setFrame:CGRectMake(0, 0, size.width, size.height) display:NO];
    [self refreshStyle];
}

- (void)statusItemClicked
{
    const NSUInteger buttonMask = [NSEvent pressedMouseButtons];
    BOOL primaryDown = ((buttonMask & (1 << 0)) != 0);
    BOOL secondaryDown = ((buttonMask & (1 << 1)) != 0);
    if (primaryDown) {
        if (self.clickCallback) {
            self.clickCallback();
        }
    }
    if (secondaryDown) {
        if (self.secondaryClickCallback) {
            self.secondaryClickCallback();
        }
    }
    
    [self toggleWindow];
}

- (void)refreshStyle
{
    NSRect itemFrame;
    itemFrame = self.statusItem.button.window.frame;

    NSRect windowFrame = self.window.frame;
    windowFrame.origin.x = NSMidX(itemFrame) - NSWidth(windowFrame) / 2.0;
    windowFrame.origin.y = NSMinY(itemFrame) - NSHeight(windowFrame);
    [self.window setFrame:windowFrame display:NO];
}

@end
