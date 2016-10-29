//
//  QSHWebViewDelegate.m
//  quark-shell
//
//  Created by Xhacker Liu on 3/31/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import "QSHWebViewDelegate.h"
#import "QSHPreferencesViewController.h"
#import "QSHWebViewWindowController.h"
#import <MASShortcut+Monitoring.h>
#import <RHPreferences.h>
#import <Sparkle/Sparkle.h>
#import <ISO8601DateFormatter.h>
#import <StartAtLoginController.h>
#import "WKWebViewJavascriptBridge.h"

static const NSInteger kPreferencesDefaultHeight = 192;

@interface QSHWebViewDelegate () <NSUserNotificationCenterDelegate, WebPolicyDelegate> {
    NSString *appVersion;
    NSString *appBundleVersion;
    NSString *platform;
    BOOL debug;
}

@property (nonatomic) NSWindowController *preferencesWindowController;
@property (nonatomic) NSMutableArray *windows;

@end

@implementation QSHWebViewDelegate

+ (void)initialize
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WebKitDeveloperExtras"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.windows = [[NSMutableArray alloc] init];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        appBundleVersion = [infoDictionary objectForKey:@"CFBundleVersion"];

        platform = @"mac";
    }
    return self;
}

+ (void)initWebviewWithBridge:(QSHWebView*)webview url:(NSURL*)url webDelegate:(QSHWebViewDelegate*)webDelegate isMain:(BOOL)isMain
{
    // Create Bridge
    WKWebViewJavascriptBridge* _WKBridge = [WKWebViewJavascriptBridge bridgeForWebView:webview];
    webview.bridge = _WKBridge;
    if (isMain){
        webDelegate.mainBridge = _WKBridge;
    }

    [_WKBridge registerHandler:@"quark" handler:^(id data, WVJBResponseCallback responseCallback) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSLog(@"Trigger method: %@ from JS", data[@"method"]);
            NSArray *args = data[@"args"];
            SEL method = NSSelectorFromString(data[@"method"]);
            if ([args count] > 0) {
                method = NSSelectorFromString([data[@"method"] stringByAppendingString:@":"]);
            }
            if (![QSHWebViewDelegate isSelectorExcludedFromWebScript: method]) {
                if (method == NSSelectorFromString(@"closeWindow:") ){
                    [webDelegate performSelector:method withObject: webview.parentWindow];
                } else {
                    [webDelegate performSelector:method withObject: args];
                }
            }
        }
        responseCallback(@"Response from testObjcCallback");
    }];
    
    // Load Page
    [webview loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark WebScripting Protocol

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector
{
    if (selector == @selector(openPopup) ||
        selector == @selector(closePopup) ||
        selector == @selector(togglePopup) ||
        selector == @selector(resizePopup:) ||
        selector == @selector(quit) ||
        selector == @selector(openURL:) ||
        selector == @selector(changeIcon:) ||
        selector == @selector(changeHighlightedIcon:) ||
        selector == @selector(changeClickAction:) ||
        selector == @selector(changeSecondaryClickAction:) ||
        selector == @selector(changeLabel:) ||
        selector == @selector(resetMenubarIcon) ||
        selector == @selector(setLaunchAtLogin:) ||
        selector == @selector(notify:) ||
        selector == @selector(removeAllScheduledNotifications) ||
        selector == @selector(removeAllDeliveredNotifications) ||
        selector == @selector(addKeyboardShortcut:) ||
        selector == @selector(clearKeyboardShortcut) ||
        selector == @selector(setupPreferences:) ||
        selector == @selector(openPreferences) ||
        selector == @selector(closePreferences) ||
        selector == @selector(newWindow:) ||
        selector == @selector(closeWindow:) ||
        selector == @selector(pin) ||
        selector == @selector(unpin) ||
        selector == @selector(checkUpdate:) ||
        selector == @selector(checkUpdateInBackground:) ||
        selector == @selector(emitMessage:) ||
        selector == @selector(showMenu:)) {
        return NO;
    }

    return YES;
}

+ (BOOL)isKeyExcludedFromWebScript:(const char *)name
{
    if (strncmp(name, "appVersion", 10) == 0 ||
        strncmp(name, "appBundleVersion", 16) == 0 ||
        strncmp(name, "platform", 8) == 0 ||
        strncmp(name, "debug", 5) == 0) {
        return NO;
    }
	return YES;
}

#pragma mark - Methods for JavaScript

- (void)openPopup
{
    [self.appDelegate showWindow];
}

- (void)closePopup
{
    [self.appDelegate hideWindow];
}

- (void)togglePopup
{
    [self.appDelegate toggleWindow];
}

- (void)resizePopup:(NSArray *)args
{
    NSDictionary *options = args[0];
    CGFloat width = [options[@"width"] doubleValue];
    CGFloat height = [options[@"height"] doubleValue];
    
    if (options[@"width"] && options[@"height"]) {
        [self.appDelegate resizeWindow:CGSizeMake(width, height)];
    }
}

- (void)quit
{
    [NSApp terminate:nil];
}

- (void)openURL:(NSArray *)args
{
    NSString *url = args[0];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

- (void)changeIcon:(NSArray *)args
{
    NSString *base64 = args[0];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:base64]];
    NSImage *icon = [[NSImage alloc] initWithData:data];
    icon.size = NSMakeSize(20, 20);

    [icon setTemplate:YES];
    self.statusItem.button.image = icon;
}

- (void)changeHighlightedIcon:(NSArray *)args
{
    NSString *base64 = args[0];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:base64]];
    NSImage *icon = [[NSImage alloc] initWithData:data];
    self.statusItemView.highlightedIcon = icon;
}

- (void)changeClickAction:(NSArray *)args
{
    self.appDelegate.clickCallback = ^{
    };
}

- (void)changeSecondaryClickAction:(NSArray *)args
{
    self.appDelegate.secondaryClickCallback = ^{
    };
}

- (void)resetMenubarIcon
{
    if (IS_PRIOR_TO_10_9) {
        self.statusItemView.icon = [NSImage imageNamed:@"StatusIcon"];
        self.statusItemView.highlightedIcon = [NSImage imageNamed:@"StatusIconWhite"];
    }
    else {
        NSImage *icon = [NSImage imageNamed:@"StatusIcon"];
        [icon setTemplate:YES];
        self.statusItem.button.image = icon;
    }
}

- (void)changeLabel:(NSArray *)args
{
    NSString *label = args[0];
    NSDictionary *barTextAttributes;
    self.statusItem.title = label;
    if (!IS_PRIOR_TO_10_10) {
        self.statusItem.button.font = MENUBAR_FONT_10_11;
    }
    barTextAttributes = @{NSFontAttributeName: self.statusItem.button.font};

    // 20 is image width, 10 is extra margin
    self.statusItem.length = 20 + [label sizeWithAttributes:barTextAttributes].width + 10;
}

- (void)setLaunchAtLogin:(NSArray *)args
{
    BOOL launchAtLogin = args[0];
    
    StartAtLoginController *loginController = [[StartAtLoginController alloc] initWithIdentifier:@"com.hackplan.quark-shell-helper"];
    loginController.startAtLogin = launchAtLogin;
}

- (void)notify:(NSArray *)args
{
    NSDictionary *message = args[0];

    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = message[@"title"];
    notification.informativeText = message[@"content"];
    notification.deliveryDate = [NSDate date];
    notification.soundName = NSUserNotificationDefaultSoundName;
    notification.userInfo = @{@"popupOnClick": message[@"popupOnClick"]};

    if (message[@"time"]) {
        static ISO8601DateFormatter *formatter;
        if (!formatter) {
            formatter = [[ISO8601DateFormatter alloc] init];
        }
        notification.deliveryDate = [formatter dateFromString:message[@"time"]];
    }

    NSUserNotificationCenter *notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    notificationCenter.delegate = self;
    [notificationCenter scheduleNotification:notification];
}

- (void)removeAllScheduledNotifications
{
    NSUserNotificationCenter *notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    notificationCenter.scheduledNotifications = @[];
}

- (void)removeAllDeliveredNotifications
{
    NSUserNotificationCenter *notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    [notificationCenter removeAllDeliveredNotifications];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    if (notification.userInfo[@"popupOnClick"]) {
        [self.appDelegate showWindow];
    }
    [[NSUserNotificationCenter defaultUserNotificationCenter] removeDeliveredNotification:notification];
}

- (void)addKeyboardShortcut:(NSArray *)args
{
    NSDictionary* shortcutObj = args[0];
    NSUInteger keycode = [[shortcutObj valueForKey:@"keycode"] integerValue];
    NSUInteger flags = [[shortcutObj valueForKey:@"modifierFlags"] integerValue];

    if (keycode == 0 && flags == 0) {
        // the shortcut recorder returns 0 0 for no shortcut
        // however, 0 0 is a single 'a', in this case, shouldn't be fired
        return;
    }

    NSString *callbackId = [shortcutObj valueForKey:@"callback"];
    MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:keycode modifierFlags:flags];
    [MASShortcut removeGlobalHotkeyMonitor:shortcut.description];
    [MASShortcut addGlobalHotkeyMonitorWithShortcut:shortcut handler:^{
        [self.mainBridge callHandler:@"onQuarkShortcut" data:callbackId];
    }];
}

- (void)clearKeyboardShortcut
{
    [MASShortcut clearGlobalHotkeyMonitor];
}

- (void)setupPreferences:(NSArray *)preferencesArray
{
    NSMutableArray *viewControllers = [NSMutableArray array];
	for (NSDictionary *preferences in preferencesArray) {
        NSInteger height = preferences[@"height"] ? [preferences[@"height"] integerValue]: kPreferencesDefaultHeight;
        QSHPreferencesViewController *vc = [[QSHPreferencesViewController alloc]
                                            initWithIdentifier:preferences[@"identifier"]
                                            toolbarImage:[NSImage imageNamed:preferences[@"icon"]]
                                            toolbarLabel:preferences[@"label"]
                                            height:height
                                            delegate:self];

        for (NSDictionary *component in preferences[@"nativeComponents"]) {
            [vc addNativeComponent:component];
        }

        [viewControllers addObject:vc];
	}

    NSString *title = @"Preferences";
    self.preferencesWindowController = [[RHPreferencesWindowController alloc] initWithViewControllers:viewControllers andTitle:title];
}

- (void)openPreferences
{
    [self.preferencesWindowController showWindow:nil];
}

- (void)closePreferences
{
    [self.preferencesWindowController close];
}

- (void)removeWindowFromWindows:(QSHWebViewWindowController *)windowController
{
    [self.windows removeObject:windowController];
}

- (void)newWindow:(NSArray *)args
{
    NSDictionary *options = args[0];
    NSString *urlString = options[@"url"];
    CGFloat width = [options[@"width"] doubleValue];
    CGFloat height = [options[@"height"] doubleValue];
    
    QSHWebViewWindowController *webViewWindowController;
    webViewWindowController = [[QSHWebViewWindowController alloc] initWithURLString:urlString width:width height:height webDelegate:self];
    [self.windows addObject:webViewWindowController];

    if (options[@"x"] && options[@"y"]) {
        CGFloat screenWidth = [[NSScreen mainScreen] frame].size.width;
        CGFloat screenHeight = [[NSScreen mainScreen] frame].size.height;

        CGFloat x = [options[@"x"] doubleValue];
        if ([options[@"x"] isEqual:@"center"]) {
            x = (screenWidth - width) / 2;
        }
        CGFloat yFlipped = screenHeight - [options[@"y"] doubleValue] - height;
        if ([options[@"y"] isEqual:@"center"]) {
            yFlipped = (screenHeight - height) / 2;
        }

        [webViewWindowController.window setFrameOrigin:NSMakePoint(x, yFlipped)];
    }

    if (options[@"border"] && [options[@"border"] boolValue] == NO) {
        webViewWindowController.window.styleMask = NSBorderlessWindowMask;
    }

    if (options[@"shadow"] && [options[@"shadow"] boolValue] == NO) {
        webViewWindowController.window.hasShadow = NO;
    }

    if ([options[@"alwaysOnTop"] boolValue]) {
        webViewWindowController.window.level = NSScreenSaverWindowLevel;
    }

    if (options[@"alpha"]) {
        webViewWindowController.window.alphaValue = [options[@"alpha"] doubleValue];
    }

    [webViewWindowController showWindow:nil];
}

- (void)closeWindow:(NSWindowController *)window
{
    [window close];
}

- (void)pin
{
    self.appDelegate.pinned = YES;
}

- (void)unpin
{
    self.appDelegate.pinned = NO;
}

- (void)checkUpdate:(NSString *)url
{
    SUUpdater *updater = [[SUUpdater alloc] init];
    updater.feedURL = [NSURL URLWithString:url];
    [updater checkForUpdates:nil];
}

- (void)checkUpdateInBackground:(NSString *)url
{
    SUUpdater *updater = [[SUUpdater alloc] init];
    updater.feedURL = [NSURL URLWithString:url];
    [updater checkForUpdatesInBackground];
}

- (void)emitMessage:(NSArray *)arg
{
    NSMutableArray *bridges = [[NSMutableArray alloc] init];
    for (QSHWebViewWindowController *window in self.windows) {
        [bridges addObject:window.webView.bridge];
    }
    [bridges addObject:self.mainBridge];
    
    for (WKWebViewJavascriptBridge *b in bridges) {
        [b callHandler:@"onQuarkMessage" data:arg[0]];
    }
}

- (void)showMenu:(NSArray *)args
{
    NSDictionary *options = args[0];
    NSMenu *menu = [[NSMenu alloc] init];
    menu.autoenablesItems = NO;
	for (NSDictionary *item in options[@"items"]) {
        if ([item[@"type"] isEqualToString:@"separator"]) {
            [menu addItem:[NSMenuItem separatorItem]];
        }
        else {
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:item[@"label"] action:@selector(menuItemClicked:) keyEquivalent:@""];
            menuItem.target = self;
            menuItem.representedObject = ^{
            };
            [menuItem setEnabled:YES];
            [menu addItem:menuItem];
        }
	}

    CGFloat x = [options[@"x"] doubleValue];
    CGFloat yFlipped = self.webView.frame.size.height - [options[@"y"] doubleValue];
    [menu popUpMenuPositioningItem:nil atLocation:NSMakePoint(x, yFlipped) inView:self.webView];
}

- (void)menuItemClicked:(NSMenuItem *)sender
{
    void(^clickHandler)(void) = sender.representedObject;
    clickHandler();
}

#pragma mark - Delegate methods

- (void)webView:(WebView *)webView addMessageToConsole:(NSDictionary *)message
{
	if (![message isKindOfClass:[NSDictionary class]]) {
		return;
	}

	NSLog(@"JavaScript console: %@:%@: %@",
		  [message[@"sourceURL"] lastPathComponent],
		  message[@"lineNumber"],
		  message[@"message"]);
}

- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    alert.messageText = message;
    alert.alertStyle = NSWarningAlertStyle;

    [alert runModal];
}

- (BOOL)webView:(WebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    alert.messageText = message;
    alert.alertStyle = NSWarningAlertStyle;

    if ([alert runModal] == NSAlertFirstButtonReturn) {
        return YES;
    }
    else {
        return NO;
    }
}

// Enable <input type="file">
- (void)webView:(WebView *)sender runOpenPanelForFileButtonWithResultListener:(id < WebOpenPanelResultListener >)resultListener
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseFiles = YES;
    openPanel.canChooseDirectories = NO;
    
    [openPanel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *fileURL = openPanel.URL;
            [resultListener chooseFilename:fileURL.relativePath];
        }
    }];
}

// Enable WebSQL: http://stackoverflow.com/questions/353808/implementing-a-webview-database-quota-delegate
- (void)webView:(WebView *)sender frame:(WebFrame *)frame exceededDatabaseQuotaForSecurityOrigin:(id)origin database:(NSString *)databaseIdentifier
{
    static const unsigned long long defaultQuota = 5 * 1024 * 1024;
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([origin respondsToSelector:@selector(setQuota:)]) {
        [origin performSelector:@selector(setQuota:) withObject:@(defaultQuota)];
    }
    #pragma clang diagnostic pop
    else {
        NSLog(@"Could not increase quota for %lld", defaultQuota);
    }
}

#pragma mark WebPolicyDelegate

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
    NSString *scheme = request.URL.scheme;
    if ([scheme isEqualToString:@"file"]) {
        [listener use];
    }
    else {
        [listener ignore];
        [[NSWorkspace sharedWorkspace] openURL:request.URL];
    }
}

#pragma mark - WebUIDelegate

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
{
    if (debug) {
        return defaultMenuItems;
    }
    return nil;
}

@end
