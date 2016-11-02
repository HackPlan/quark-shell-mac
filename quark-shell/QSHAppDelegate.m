//
//  QSHAppDelegate.m
//  quark-shell
//
//  Created by Xhacker Liu on 3/25/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import <WebKit/WebKit.h>
#import <AppKit/AppKit.h>
#import "QSHAppDelegate.h"
#import "QSHWindowBorderView.h"
#import "QSHWebView.h"
#import "QSHWebViewDelegate.h"
#import "QSHStatusItemView.h"
#import "NSWindow+Fade.h"
#import "WKWebViewJavascriptBridge.h"

static const CGFloat kMinimumSpaceBetweenWindowAndScreenEdge = 10;

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

- (void)setupWebView
{
    QSHWindowBorderView *contentView = _window.contentView;
    _webView = [[QSHWebView alloc] initWithFrame:contentView.innerFrame];
    [_webView setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];
    _webView.configuration.preferences._developerExtrasEnabled = YES;
    
    [contentView addSubview:_webView];
    
    contentView.wantsLayer = YES;
    contentView.layer.cornerRadius = 5.0;
    contentView.layer.masksToBounds = YES;
    
    _webView.wantsLayer = YES;
    _webView.layer.cornerRadius = 5.0;
    _webView.layer.masksToBounds = YES;
    
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    
    NSURL *URL = [NSURL URLWithString:kIndexPath relativeToURL:[[NSBundle mainBundle] resourceURL]];
    [QSHWebViewDelegate initWebviewWithBridge:_webView url:URL webDelegate:self.webViewDelegate isMain:YES];
}

- (void)applicationWillBecomeActive:(NSNotification *)notification
{
    [self showWindow];
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
    NSRect itemFrame, screenFrame;
    
    if (IS_PRIOR_TO_10_9) {
        self.statusItemView.itemHighlighted = self.shouldBeVisible;
        itemFrame = self.statusItem.view.window.frame;
    }
    else {
        itemFrame = self.statusItem.button.window.frame;
    }
    
    NSRect windowFrame = self.window.frame;
    
    screenFrame = [[NSScreen mainScreen] frame];
    
    // Calculate window's top left point.
    // First, center window under status item.
    CGFloat w = NSWidth(windowFrame);
    CGFloat x = NSMidX(itemFrame) - NSWidth(windowFrame) / 2.0;
    CGFloat y = NSMinY(itemFrame) - NSHeight(windowFrame);
    
    windowFrame.origin.y = y;
    
    // If the calculated x position puts the window too
    // far to the right, shift the window left.
    CGFloat screenMaxX = NSMaxX(screenFrame);
    if (x + w + kMinimumSpaceBetweenWindowAndScreenEdge > screenMaxX) {
        x = screenMaxX - w - kMinimumSpaceBetweenWindowAndScreenEdge;
    }
    
    windowFrame.origin.x = x;
    
    QSHWindowBorderView *contentView = [[self window] contentView];
    
    contentView.arrowMidX = NSMidX(itemFrame) - x;
    [contentView setNeedsDisplay:YES];
    
    [self.window setFrame:windowFrame display:NO];
}

@end
