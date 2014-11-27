//
//  QSHWebViewDelegate.m
//  quark-shell
//
//  Created by Xhacker Liu on 3/31/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import "QSHWebViewDelegate.h"
#import "QSHPreferencesViewController.h"
#import "QSHWebScriptObjectConverter.h"
#import "QSHWebViewWindowController.h"
#import <MASShortcut+Monitoring.h>
#import <RHPreferences.h>
#import <Sparkle/Sparkle.h>
#import <ISO8601DateFormatter.h>

static NSString * const kWebScriptNamespace = @"quark";
static const NSInteger kPreferencesDefaultHeight = 192;

@interface QSHWebViewDelegate () <NSUserNotificationCenterDelegate> {
    NSString *appVersion;
    NSString *appBundleVersion;
    NSString *platform;
    BOOL debug;
}

@property (nonatomic) NSWindowController *preferencesWindowController;
@property (nonatomic) QSHWebViewWindowController *webViewWindowController;
@property (nonatomic) NSMutableDictionary *messageSubscribers;

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
        _messageSubscribers = [NSMutableDictionary dictionary];

        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        appBundleVersion = [infoDictionary objectForKey:@"CFBundleVersion"];

        platform = @"mac";
    }
    return self;
}

- (void)webView:(WebView *)webView didClearWindowObject:(WebScriptObject *)windowScriptObject forFrame:(WebFrame *)frame
{
    [windowScriptObject setValue:self forKey:kWebScriptNamespace];
}

#pragma mark WebScripting Protocol

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector
{
    if (selector == @selector(openPopup) ||
        selector == @selector(closePopup) ||
        selector == @selector(quit) ||
        selector == @selector(openURL:) ||
        selector == @selector(changeIcon:) ||
        selector == @selector(changeHighlightedIcon:) ||
        selector == @selector(resetMenubarIcon) ||
        selector == @selector(notify:) ||
        selector == @selector(removeAllScheduledNotifications) ||
        selector == @selector(removeAllDeliveredNotifications) ||
        selector == @selector(addKeyboardShortcut:) ||
        selector == @selector(clearKeyboardShortcut) ||
        selector == @selector(setupPreferenes:) ||
        selector == @selector(openPreferences) ||
        selector == @selector(closePreferences) ||
        selector == @selector(newWindow:) ||
        selector == @selector(closeWindow) ||
        selector == @selector(pin) ||
        selector == @selector(unpin) ||
        selector == @selector(checkUpdate:) ||
        selector == @selector(checkUpdateInBackground:) ||
        selector == @selector(emitMessage:withPayload:) ||
        selector == @selector(subscribeMessage:withCallback:) ||
        selector == @selector(showMenu:)) {
        return NO;
    }

    return YES;
}

+ (NSString *)webScriptNameForSelector:(SEL)selector
{
    id result = nil;

    if (selector == @selector(notify:)) {
        result = @"notify";
    }
    else if (selector == @selector(changeIcon:)) {
        result = @"setMenubarIcon";
    }
    else if (selector == @selector(changeHighlightedIcon:)) {
        result = @"setMenubarHighlightedIcon";
    }
    else if (selector == @selector(openURL:)) {
        result = @"openURL";
    }
    else if (selector == @selector(addKeyboardShortcut:)) {
        result = @"addKeyboardShortcut";
    }
    else if (selector == @selector(setupPreferenes:)) {
        result = @"setupPreferences";
    }
    else if (selector == @selector(newWindow:)) {
        result = @"newWindow";
    }
    else if (selector == @selector(checkUpdate:)) {
        result = @"checkUpdate";
    }
    else if (selector == @selector(checkUpdateInBackground:)) {
        result = @"checkUpdateInBackground";
    }
    else if (selector == @selector(emitMessage:withPayload:)) {
        result = @"emit";
    }
    else if (selector == @selector(subscribeMessage:withCallback:)) {
        result = @"on";
    }
    else if (selector == @selector(showMenu:)) {
        result = @"showMenu";
    }

    return result;
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

- (void)quit
{
    [NSApp terminate:nil];
}

- (void)openURL:(NSString *)url
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

- (void)changeIcon:(NSString *)base64
{
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:base64]];
    NSImage *icon = [[NSImage alloc] initWithData:data];
    icon.size = NSMakeSize(20, 20);

    if (IS_PERIOR_TO_10_9) {
        self.statusItemView.icon = icon;
    }
    else {
        [icon setTemplate:YES];
        self.statusItem.button.image = icon;
    }
}

- (void)changeHighlightedIcon:(NSString *)base64
{
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:base64]];
    NSImage *icon = [[NSImage alloc] initWithData:data];
    self.statusItemView.highlightedIcon = icon;
}

- (void)resetMenubarIcon
{
    if (IS_PERIOR_TO_10_9) {
        self.statusItemView.icon = [NSImage imageNamed:@"StatusIcon"];
        self.statusItemView.highlightedIcon = [NSImage imageNamed:@"StatusIconWhite"];
    }
    else {
        NSImage *icon = [NSImage imageNamed:@"StatusIcon"];
        [icon setTemplate:YES];
        self.statusItem.button.image = icon;
    }
}

- (void)notify:(WebScriptObject *)obj
{
    QSHWebScriptObjectConverter *converter = [[QSHWebScriptObjectConverter alloc] initWithWebView:self.webView];
    NSDictionary *message = [converter dictionaryFromWebScriptObject:obj];

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
    notificationCenter.scheduledNotifications = nil;
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

- (void)addKeyboardShortcut:(WebScriptObject *)shortcutObj
{
    NSUInteger keycode = [[shortcutObj valueForKey:@"keycode"] integerValue];
    NSUInteger flags = [[shortcutObj valueForKey:@"modifierFlags"] integerValue];

    if (keycode == 0 && flags == 0) {
        // the shortcut recorder returns 0 0 for no shortcut
        // however, 0 0 is a single 'a', in this case, shouldn't be fired
        return;
    }

    WebScriptObject *callback = [shortcutObj valueForKey:@"callback"];
    MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:keycode modifierFlags:flags];
    [MASShortcut removeGlobalHotkeyMonitor:shortcut.description];
    [MASShortcut addGlobalHotkeyMonitorWithShortcut:shortcut handler:^{
        QSHWebScriptObjectConverter *converter = [[QSHWebScriptObjectConverter alloc] initWithWebView:self.webView];
        [converter callFunction:callback];
    }];
}

- (void)clearKeyboardShortcut
{
    [MASShortcut clearGlobalHotkeyMonitor];
}

- (void)setupPreferenes:(WebScriptObject *)scriptObj
{
    QSHWebScriptObjectConverter *converter = [[QSHWebScriptObjectConverter alloc] initWithWebView:self.webView];
    NSArray *preferencesArray = [converter arrayFromWebScriptObject:scriptObj];
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

- (void)newWindow:(WebScriptObject *)scriptObj
{
    QSHWebScriptObjectConverter *converter = [[QSHWebScriptObjectConverter alloc] initWithWebView:self.webView];
    NSDictionary *options = [converter dictionaryFromWebScriptObject:scriptObj];
    NSString *urlString = options[@"url"];
    CGFloat width = [options[@"width"] doubleValue];
    CGFloat height = [options[@"height"] doubleValue];

    self.webViewWindowController = [[QSHWebViewWindowController alloc] initWithURLString:urlString width:width height:height];

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

        [self.webViewWindowController.window setFrameOrigin:NSMakePoint(x, yFlipped)];
    }

    if (options[@"border"] && [options[@"border"] boolValue] == NO) {
        self.webViewWindowController.window.styleMask = NSBorderlessWindowMask;
    }

    if (options[@"shadow"] && [options[@"shadow"] boolValue] == NO) {
        self.webViewWindowController.window.hasShadow = NO;
    }

    if ([options[@"alwaysOnTop"] boolValue]) {
        self.webViewWindowController.window.level = NSScreenSaverWindowLevel;
    }

    if (options[@"alpha"]) {
        self.webViewWindowController.window.alphaValue = [options[@"alpha"] doubleValue];
    }

    self.webViewWindowController.webView.frameLoadDelegate = self;
    self.webViewWindowController.webView.UIDelegate = self;
    self.webViewWindowController.webView.policyDelegate = self;
    [self.webViewWindowController showWindow:nil];
}

- (void)closeWindow
{
    [self.webViewWindowController close];
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

- (void)emitMessage:(NSString *)name withPayload:(WebScriptObject *)payload
{
    for (WebScriptObject *callback in self.messageSubscribers[name]) {
        QSHWebScriptObjectConverter *converter = [[QSHWebScriptObjectConverter alloc] initWithWebView:self.webView];
        [converter callFunction:callback withArgs:@[payload]];
    }
}

- (void)subscribeMessage:(NSString *)name withCallback:(WebScriptObject *)callback
{
    if (self.messageSubscribers[name]) {
        [self.messageSubscribers[name] addObject:callback];
    }
    else {
        self.messageSubscribers[name] = @[callback];
    }
}

- (void)showMenu:(WebScriptObject *)scriptObj
{
    QSHWebScriptObjectConverter *converter = [[QSHWebScriptObjectConverter alloc] initWithWebView:self.webView];
    NSDictionary *options = [converter dictionaryFromWebScriptObject:scriptObj];
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
                [converter callFunction:item[@"click"]];
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

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    if (sender == self.webViewWindowController.webView) {
        self.webViewWindowController.window.title = title;
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
