//
//  LDYWebViewDelegate.m
//  menubar-webkit
//
//  Created by Xhacker Liu on 3/31/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import "LDYWebViewDelegate.h"
#import "LDYPreferencesViewController.h"
#import "LDYWebScriptObjectConverter.h"
#import <MASShortcut+Monitoring.h>
#import <RHPreferences.h>

static NSString * const kWebScriptNamespace = @"mw";

@interface LDYWebViewDelegate ()

@property (nonatomic) NSWindowController *preferencesWindowController;

@end

@implementation LDYWebViewDelegate

+ (void)initialize
{
	[[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"WebKitDeveloperExtras"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)webView:(WebView *)webView didClearWindowObject:(WebScriptObject *)windowScriptObject forFrame:(WebFrame *)frame
{
    [windowScriptObject setValue:self forKey:kWebScriptNamespace];
}

#pragma mark WebScripting Protocol

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector
{
    if (selector == @selector(quit) ||
        selector == @selector(openURL:) ||
        selector == @selector(changeIcon:) ||
        selector == @selector(changeHighlightedIcon:) ||
        selector == @selector(notify:) ||
        selector == @selector(addKeyboardShortcut:) ||
        selector == @selector(setupPreferenes:) ||
        selector == @selector(openPreferences)) {
        return NO;
    }

    return YES;
}

+ (NSString*)webScriptNameForSelector:(SEL)selector
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

	return result;
}

+ (BOOL)isKeyExcludedFromWebScript:(const char *)name
{
	return YES;
}

#pragma mark - Methods for JavaScript

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
    self.statusItemView.icon = icon;
}

- (void)changeHighlightedIcon:(NSString *)base64
{
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:base64]];
    NSImage *icon = [[NSImage alloc] initWithData:data];
    self.statusItemView.highlightedIcon = icon;
}

- (void)notify:(WebScriptObject *)message
{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = [message valueForKey:@"title"];
    notification.informativeText = [message valueForKey:@"content"];
    notification.deliveryDate = [NSDate date];
    notification.soundName = NSUserNotificationDefaultSoundName;
    [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notification];
}

- (void)addKeyboardShortcut:(WebScriptObject *)shortcutObj
{
    NSUInteger keycode = [[shortcutObj valueForKey:@"keycode"] integerValue];
    NSUInteger flags = [[shortcutObj valueForKey:@"modifierFlags"] integerValue];
    WebScriptObject *callback = [shortcutObj valueForKey:@"callback"];
    MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:keycode modifierFlags:flags];
    [MASShortcut addGlobalHotkeyMonitorWithShortcut:shortcut handler:^{
        LDYWebScriptObjectConverter *converter = [[LDYWebScriptObjectConverter alloc] initWithWebView:self.webView];
        [converter callFunction:callback];
    }];
}

- (void)setupPreferenes:(WebScriptObject *)scriptObj
{
    LDYWebScriptObjectConverter *converter = [[LDYWebScriptObjectConverter alloc] initWithWebView:self.webView];
    NSArray *preferencesArray = [converter arrayFromWebScriptObject:scriptObj];
    NSMutableArray *viewControllers = [NSMutableArray array];
	for (NSDictionary *preferences in preferencesArray) {
        NSViewController *vc = [[LDYPreferencesViewController alloc]
                                initWithIdentifier:preferences[@"identifier"]
                                toolbarImage:[NSImage imageNamed:preferences[@"icon"]]
                                toolbarLabel:preferences[@"label"]];
        [viewControllers addObject:vc];
	}

    NSString *title = @"Preferences";
    self.preferencesWindowController = [[RHPreferencesWindowController alloc] initWithViewControllers:viewControllers andTitle:title];
}

- (void)openPreferences
{
    [self.preferencesWindowController showWindow:nil];
}

#pragma mark - Delegate methods

- (void)webView:(WebView *)webView addMessageToConsole:(NSDictionary *)message
{
	if (![message isKindOfClass:[NSDictionary class]]) {
		return;
	}

	NSLog(@"JavaScript console: %@:%@: %@",
		  [[message objectForKey:@"sourceURL"] lastPathComponent],
		  [message objectForKey:@"lineNumber"],
		  [message objectForKey:@"message"]);
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

@end
