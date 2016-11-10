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
#import "QSCConfigureWindow.h"
#import "QSHWebViewDelegate.h"
#import "QSHStatusItemView.h"
#import "NSWindow+Fade.h"
#import "WKWebViewJavascriptBridge.h"
#import <GCDWebServer/GCDWebServer.h>

static const CGFloat kMinimumSpaceBetweenWindowAndScreenEdge = 10;

@interface QSHAppDelegate () <NSWindowDelegate>

@property (nonatomic) NSStatusItem *statusItem;
@property (nonatomic) QSHStatusItemView *statusItemView;
@property (nonatomic) QSHWebViewDelegate *webViewDelegate;
@property (nonatomic) QSCConfigureWindow *configureWindow;

@end

@implementation QSHAppDelegate {
    QSHWebView *_webView;
    GCDWebServer* _webServer;
    NSMutableDictionary* _webServerOptions;
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

    _webView.UIDelegate = self.webViewDelegate;
    
    NSMenu *menu = [[[[NSApplication sharedApplication] mainMenu] itemAtIndex:0] submenu];
    NSMenuItem *configureMenuItem = [menu itemAtIndex:0];
    if (configureMenuItem)
    {
        [configureMenuItem setTarget:self];
        [configureMenuItem setAction:@selector(openConfigure:)];
    }
}

- (void)openConfigure:(id)sender {
    _configureWindow = [[QSCConfigureWindow alloc] init];
    _configureWindow.appDelegate = self;
    [_configureWindow showWindow:nil];
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

- (void)setupWebserver
{
    _webServer = [[GCDWebServer alloc] init];
    _webServerOptions = [NSMutableDictionary dictionary];
    
    NSString *directoryPath = [[QSHWebViewDelegate getRootURL] path];
    
    NSLog(@"Start webserver at: %@", directoryPath);
    // Add GET handler for local "www/" directory
    [_webServer addGETHandlerForBasePath:@"/"
                           directoryPath:directoryPath
                           indexFilename:nil
                                cacheAge:0
                      allowRangeRequests:YES];
    
    // Initialize Server startup
    [self startServer];
    NSLog(@"Visit %@ in your web browser", _webServer.serverURL);
}

- (void)startServer
{
    NSError *error = nil;
    
    // Enable this option to force the Server also to run when suspended
    //[_webServerOptions setObject:[NSNumber numberWithBool:NO] forKey:GCDWebServerOption_AutomaticallySuspendInBackground];
    
    [_webServerOptions setObject:[NSNumber numberWithBool:YES]
                          forKey:GCDWebServerOption_BindToLocalhost];
    
    // Initialize Server listening port, initially trying 12344 for backwards compatibility
    int httpPort = 12311;
    
    // Start Server
    do {
        [_webServerOptions setObject:[NSNumber numberWithInteger:httpPort++]
                              forKey:GCDWebServerOption_Port];
    } while(![_webServer startWithOptions:_webServerOptions error:&error]);
    
    if (error) {
        NSLog(@"Error starting http daemon: %@", error);
    } else {
        NSLog(@"Started http daemon: %@ ", _webServer.serverURL);
    }
}

- (void)setupWebView
{
    [self setupWebserver];
    NSURL *rootUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:%lu", (unsigned long)_webServer.port]];
    
    // parse manifest
    NSURL *manifestFilePath = [NSURL URLWithString:@"quark-manifest.json" relativeToURL:[QSHWebViewDelegate getFolderURL]];
    NSString *manifestContents = [NSString stringWithContentsOfFile:[manifestFilePath path] encoding:NSUTF8StringEncoding error:nil];
    if (manifestContents == nil) {
        NSLog(@"Error reading manifest file");
    }
    NSDictionary *manifest = [NSJSONSerialization JSONObjectWithData:[manifestContents dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    if (manifest.count > 0){
        if (manifest[@"popup"]){
            CGRect frameRect = self.window.frame;
            frameRect.size.width = [manifest[@"popup"][@"width"] doubleValue];
            frameRect.size.height = [manifest[@"popup"][@"height"] doubleValue];
            [self.window setFrame:frameRect display:NO];
        }
        if (manifest[@"status_icon"] != nil){
            NSURL *iconFilePath = [NSURL URLWithString:manifest[@"status_icon"] relativeToURL:[QSHWebViewDelegate getRootURL]];
            NSImage *iconImage = [[NSImage alloc] initWithContentsOfFile:[iconFilePath path]];
            self.statusItem.button.image = iconImage;
        }
        if (manifest[@"index"] != nil){
            [[NSUserDefaults standardUserDefaults] setURL:[NSURL URLWithString:manifest[@"index"]] forKey:@"indexPath"];
        }
    }

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
    
    bool showDockIcon = [[NSUserDefaults standardUserDefaults] boolForKey:@"showDockIcon"];
//    if (showDockIcon != NO){
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
//    }
    
    NSURL *URL = [QSHWebViewDelegate getIndexURL];
    [QSHWebViewDelegate initWebviewWithBridge:_webView url:URL webDelegate:self.webViewDelegate isMain:YES];
}

- (void)reloadWebview
{
    [self hideWindow];
    [self setupWebView];
}

- (void)showDockIcon:(bool)showDockIcon {
    NSWindow *currentWindow = [NSApp keyWindow];
    [[NSUserDefaults standardUserDefaults] setBool:showDockIcon forKey:@"showDockIcon"];
    if (showDockIcon){
        [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    } else {
        [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
        [currentWindow performSelector:NSSelectorFromString(@"makeKeyAndOrderFront:") withObject:nil afterDelay:0.1];
    }
    
}

- (void)applicationWillBecomeActive:(NSNotification *)notification
{
    [self showWindow];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    if (!flag) {
        [self showWindow];
    }
    return true;
}

- (void)windowDidResignKey:(NSNotification *)notification
{
    self.pinned = [[NSUserDefaults standardUserDefaults] boolForKey:@"pinned"];
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
