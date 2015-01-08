//
//  QSHAppDelegate.m
//  quark-shell
//
//  Created by Xhacker Liu on 3/25/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import "QSHAppDelegate.h"
#import "QSHStatusItemView.h"
#import "NSWindow+Fade.h"

@interface WKPreferences (WKPrivate)

@property (nonatomic, setter=_setDeveloperExtrasEnabled:) BOOL _developerExtrasEnabled;

@end

@interface QSHAppDelegate () <NSWindowDelegate>

@property (nonatomic) NSStatusItem *statusItem;
@property (nonatomic) QSHStatusItemView *statusItemView;
@property (nonatomic) WKWebView *webView;

@end

@implementation QSHAppDelegate

#pragma mark - Initialize

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self setupStatusItemAndWindow];
    [self setupWebView];
}

- (void)setupStatusItemAndWindow
{
    NSStatusBar *bar = [NSStatusBar systemStatusBar];

    self.statusItem = [bar statusItemWithLength:NSSquareStatusItemLength];
    if (IS_PERIOR_TO_10_9) {
        self.statusItemView = [[QSHStatusItemView alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
        self.statusItemView.target = self;
        self.statusItemView.action = @selector(statusItemClicked);
        [self.statusItemView sendActionOn:(NSLeftMouseDownMask | NSRightMouseDownMask)];
        self.statusItem.view = self.statusItemView;
        self.statusItemView.statusItem = self.statusItem;
    }
    else {
        NSImage *statusIcon = [NSImage imageNamed:@"StatusIcon"];
        [statusIcon setTemplate:YES];
        self.statusItem.button.image = statusIcon;

        self.statusItem.button.target = self;
        self.statusItem.button.action = @selector(statusItemClicked);
        [self.statusItem.button sendActionOn:(NSLeftMouseDownMask | NSRightMouseDownMask)];
    }

    self.window.level = NSFloatingWindowLevel;
    self.window.delegate = self;
    [self.window setOpaque:NO];
    [self.window setBackgroundColor:[NSColor clearColor]];
}

- (void)setupWebView
{
    self.webView = [[WKWebView alloc] initWithFrame:NSMakeRect(0, 5, 320, 260)];
    self.webView.configuration.preferences._developerExtrasEnabled = YES;
    [self.window.contentView addSubview:self.webView];

    NSURL *URL = [NSURL URLWithString:kIndexPath relativeToURL:[[NSBundle mainBundle] resourceURL]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:URL]];
}

#pragma mark -

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
    
    if (self.window.visible) {
        [self hideWindow];
    }
    else {
        [self showWindow];
    }
}

- (void)refreshStyle
{
    NSRect itemFrame;

    if (IS_PERIOR_TO_10_9) {
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
