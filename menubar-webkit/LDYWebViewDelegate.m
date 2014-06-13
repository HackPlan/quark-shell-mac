//
//  LDYWebViewDelegate.m
//  menubar-webkit
//
//  Created by Xhacker Liu on 3/31/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import "LDYWebViewDelegate.h"
#import "LDYPreferencesViewController.h"
#import <MASShortcut+Monitoring.h>
#import <MASPreferencesWindowController.h>

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
    NSString *callbackName = [shortcutObj valueForKey:@"callbackName"];
    MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:keycode modifierFlags:flags];
    [MASShortcut addGlobalHotkeyMonitorWithShortcut:shortcut handler:^{
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@()", callbackName]];
    }];
}

- (void)setupPreferenes:(WebScriptObject *)scriptObj
{
    NSMutableArray *viewControllers = [NSMutableArray array];
	id item = nil;
	unsigned i = 0;
	WebUndefined *undefined = [WebUndefined undefined];
	while ((item = [scriptObj webScriptValueAtIndex:i++]) != undefined) {
        WebScriptObject *itemObj = item;
        NSViewController *vc = [[LDYPreferencesViewController alloc]
                                initWithIdentifier:[itemObj valueForKey:@"name"]
                                toolbarImage:[NSImage imageNamed:[itemObj valueForKey:@"icon"]]
                                toolbarLabel:[itemObj valueForKey:@"name"]];
        [viewControllers addObject:vc];
	}

    NSString *title = @"Preferences";
    self.preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:viewControllers title:title];
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

@end
