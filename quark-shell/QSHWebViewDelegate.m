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
#import <MASPreferences/MASPreferences.h>
#import <Sparkle/Sparkle.h>
#import <ISO8601DateFormatter.h>
#import <StartAtLoginController.h>
#import "WKWebViewJavascriptBridge.h"
#import <GCDWebServer/GCDWebServer.h>

static const NSInteger kPreferencesDefaultHeight = 192;

@interface QSHWebViewDelegate () <NSUserNotificationCenterDelegate, WebPolicyDelegate> {
    NSString *appVersion;
    NSString *appBundleVersion;
    NSString *platform;

    BOOL debug;
}

@property (nonatomic) MASPreferencesWindowController *preferencesWindowController;
@property (nonatomic) NSMutableArray *windows;

@end

@implementation QSHWebViewDelegate

+ (void)initialize
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WebKitDeveloperExtras"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSURL *)getRootURL
{
    NSURL *folderURL = [[NSUserDefaults standardUserDefaults] URLForKey:@"folder"];
    if (folderURL){
        return [folderURL absoluteURL];
    }
    return [[NSBundle mainBundle] resourceURL];
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
    
//    NSURL *top = [NSURL URLWithString:[[url absoluteString] stringByDeletingLastPathComponent]];
//    NSURL *newUrl = [NSURL URLWithString:[url absoluteString]];
//    NSLog(@"toload: %@", newUrl);
//    [webview loadFileURL:newUrl allowingReadAccessToURL:top];
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
        selector == @selector(setShowDockIcon:) ||
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
        selector == @selector(closeWindowById:) ||
        selector == @selector(setPin:) ||
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

- (void)setShowDockIcon:(NSArray *)args
{
    bool showDockIcon = [args[0] boolValue];
    [self.appDelegate showDockIcon:showDockIcon];
}

- (void)setLaunchAtLogin:(NSArray *)args
{
    BOOL launchAtLogin;
    if ([args[0]  isEqual: @"true"]){
        launchAtLogin = true;
    }else{
        launchAtLogin = false;
    }
    
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

    NSString *callbackId = [shortcutObj valueForKey:@"id"];
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:keycode modifierFlags:flags];
    // FIXME: value my not be the shortcut object
    [userPreferences setObject:shortcut forKey:[@"values.shortcut_" stringByAppendingString:callbackId]];
    [userPreferences synchronize];
}

- (void)clearKeyboardShortcut
{
    [[MASShortcutMonitor sharedMonitor] unregisterAllShortcuts];
}

- (void)setupPreferences:(NSArray *)args
{
    NSArray *preferencesArray = args[0];
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

    NSString *title = NSLocalizedString(@"Preferences", @"Common title for Preferences window");
    self.preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:viewControllers title:title];
    [self.preferencesWindowController selectControllerAtIndex:0];
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
    [self.webView.bridge callHandler:@"onQuarkWindowClose" data:windowController.windowId];
    [self.windows removeObject:windowController];
}

- (void)newWindow:(NSArray *)args
{
    NSDictionary *options = args[0];
    NSString *urlString = options[@"url"];
    NSString *windowId = options[@"id"];
    CGFloat width = [options[@"width"] doubleValue];
    CGFloat height = [options[@"height"] doubleValue];
    bool bringWindowToFrontInsteadOfCloseIt = options[@"toFront"];
    
    QSHWebViewWindowController *webViewWindowController;
    webViewWindowController = [[QSHWebViewWindowController alloc] initWithURLString:urlString width:width height:height webDelegate:self windowId:windowId];
    
    // if window with same key exist, close it before open a new one
    if (windowId){
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"windowId == %@", windowId];
        NSArray *existedWindows = [self.windows filteredArrayUsingPredicate:predicate];
        
        if ([existedWindows count] > 0){
            for (QSHWebViewWindowController *window in existedWindows) {
                if (bringWindowToFrontInsteadOfCloseIt){
                    return [window.window makeKeyAndOrderFront:nil];
                } else{
                    [window close];
                }
            }
        }
    }
    
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
    
    if (options[@"minWidth"] && options[@"minHeight"]){
        NSSize minSize = NSMakeSize([options[@"minWidth"] doubleValue], [options[@"minHeight"] doubleValue]);
        [webViewWindowController.window setMinSize:minSize];
    }
    
    
    if (options[@"resizable"] && [options[@"resizable"] boolValue] == NO) {
        [webViewWindowController.window setStyleMask:[webViewWindowController.window styleMask] & ~NSResizableWindowMask];
    }
    
    if (options[@"transparentTitle"] && [options[@"transparentTitle"] boolValue] == YES) {
        webViewWindowController.window.styleMask = webViewWindowController.window.styleMask | NSWindowStyleMaskFullSizeContentView;
        webViewWindowController.window.titleVisibility = NSWindowTitleHidden;
            webViewWindowController.window.titlebarAppearsTransparent = YES;
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
    
    if ([options[@"titleBarStyle"] isEqual: @"hidden-inset"]){
        [webViewWindowController.window setTitleVisibility:NSWindowTitleHidden];
        NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"titlebarStylingToolbar"];
        toolbar.showsBaselineSeparator = NO;
        [webViewWindowController.window setToolbar:toolbar];
    }

}

- (void)closeWindowById:(NSArray *)args
{
    NSDictionary *options = args[0];
    NSString *windowId = options[@"id"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"windowId == %@", windowId];
    NSArray *existedWindows = [self.windows filteredArrayUsingPredicate:predicate];
    
    if ([existedWindows count] > 0){
        for (QSHWebViewWindowController *window in existedWindows) {
            [window close];
        }
    }
}

- (void)closeWindow:(NSWindowController *)window
{
    [window close];
}

- (void)setPin:(NSArray *)args
{
    bool pinned = [args[0] boolValue];
    [[NSUserDefaults standardUserDefaults] setBool:pinned forKey:@"pinned"];
    self.appDelegate.pinned = pinned;
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

- (void)webView:(WKWebView *)webView addMessageToConsole:(NSDictionary *)message
{
	if (![message isKindOfClass:[NSDictionary class]]) {
		return;
	}

	NSLog(@"JavaScript console: %@:%@: %@",
		  [message[@"sourceURL"] lastPathComponent],
		  message[@"lineNumber"],
		  message[@"message"]);
}

- (void)webView:(QSHWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    alert.messageText = message;
    alert.alertStyle = NSWarningAlertStyle;
    
    [alert runModal];
    completionHandler();
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler;

{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    alert.messageText = message;
    alert.alertStyle = NSWarningAlertStyle;

    if ([alert runModal] == NSAlertFirstButtonReturn) {
        completionHandler(YES);
    }
    else {
        completionHandler(NO);
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)message defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler
{
    NSArray *components = [message componentsSeparatedByString: @"::"];
    message = (NSString*) [components objectAtIndex:0];
    NSString *okText = nil;
    NSString *cancelText = nil;
    if ([components count] > 1) {
        okText = (NSString*) [components objectAtIndex:1];
        @try{
            cancelText = (NSString*) [components objectAtIndex:2];
        } @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
        }
    }
    if (okText.length < 1) {
        okText = NSLocalizedString(@"OK", @"");
    }
    
    NSAlert *alert = [[NSAlert alloc] init];
    
    [alert addButtonWithTitle: okText];
    [alert addButtonWithTitle: cancelText];
    [alert setMessageText:message];
    NSTextField* input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 300, 24)];
    [input setStringValue:defaultText];
    [alert setAccessoryView:input];
    
    NSInteger button = [alert runModal];
    if (button == NSAlertFirstButtonReturn) {
        [input validateEditing];
        return completionHandler([input stringValue]);
    }
    
    completionHandler(nil);

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
