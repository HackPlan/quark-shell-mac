//
//  QSHAppDelegate.m
//  quark-shell
//
//  Created by Xhacker Liu on 3/25/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import "QSHAppDelegate.h"
#import "QSHWebViewDelegate.h"
#import "QSHStatusItemView.h"
#import "NSWindow+Fade.h"
#import "WKWebViewJavascriptBridge.h"

@interface WebPreferences (WebPreferencesPrivate)

- (void)_setLocalStorageDatabasePath:(NSString *)path;
- (void)setLocalStorageEnabled:(BOOL)localStorageEnabled;

@end


@interface QSHAppDelegate () <NSWindowDelegate>

@property (nonatomic) NSStatusItem *statusItem;
@property (nonatomic) QSHStatusItemView *statusItemView;
@property (nonatomic, weak) IBOutlet WebView *webView;
@property (nonatomic) QSHWebViewDelegate *webViewDelegate;

@end

@implementation QSHAppDelegate {
    WKWebView *_WKWebView;
    WKWebViewJavascriptBridge* _WKBridge;
    NSView* _WKWebViewWrapper;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // TODO: bundle identifier should be generated from manifest.json
    NSString *bundleIdentifier = [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
    NSString *applicationSupportFile = [@"~/Library/Application Support/" stringByExpandingTildeInPath];
    NSString *savePath = [NSString pathWithComponents:@[applicationSupportFile, bundleIdentifier, @"LocalStorage"]];
    
    [self setupStatusItemAndWindow];
    [self setupWebView];
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
    _WKWebView = [[WKWebView alloc] initWithFrame:contentView.frame];
    [_WKWebView setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];
    
    [contentView addSubview:_WKWebView];
}
    
- (void)_configureWKWebview {
    // Create Bridge
    _WKBridge = [WKWebViewJavascriptBridge bridgeForWebView:_WKWebView];
    
    [_WKBridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called: %@", data);
        responseCallback(@"Response from testObjcCallback");
    }];
    
    [_WKBridge callHandler:@"testJavascriptHandler" data:@{ @"foo":@"before ready" }];
    
    // Create Buttons
    NSButton *callbackButton = [[NSButton alloc] initWithFrame:NSMakeRect(5, 0, 120, 40)];
    [callbackButton setTitle:@"Call handler"];
    [callbackButton setBezelStyle:NSRoundedBezelStyle];
    [callbackButton setTarget:self];
    [callbackButton setAction:@selector(_WKCallHandler)];
    [_WKWebView addSubview:callbackButton];
    
    // Load Page
    NSURL *URL = [NSURL URLWithString:kIndexPath relativeToURL:[[NSBundle mainBundle] resourceURL]];
    [_WKWebView loadRequest:[NSURLRequest requestWithURL:URL]];
}
    
- (void)setupWebView
{
    [self _createViews];
    [self _configureWKWebview];
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

    if (IS_PRIOR_TO_10_9) {
        self.statusItemView.itemHighlighted = self.shouldBeVisible;
        itemFrame = self.statusItem.view.window.frame;
    }
    else {
        itemFrame = self.statusItem.button.window.frame;
    }

    NSRect windowFrame = self.window.frame;
    windowFrame.origin.x = NSMidX(itemFrame) - NSWidth(windowFrame) / 2.0;
    windowFrame.origin.y = NSMinY(itemFrame) - NSHeight(windowFrame);
    [self.window setFrame:windowFrame display:NO];
}

@end
