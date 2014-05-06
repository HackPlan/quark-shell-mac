//
//  LDYWebViewDelegate.m
//  menubar-webkit
//
//  Created by Xhacker Liu on 3/31/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import "LDYWebViewDelegate.h"

static NSString * const kWebScriptNamespace = @"mw";

@implementation LDYWebViewDelegate

+ (void)initialize
{
	[[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"WebKitDeveloperExtras"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)webView:(WebView*)webView didClearWindowObject:(WebScriptObject *)windowScriptObject forFrame:(WebFrame *)frame
{
    [windowScriptObject setValue:self forKey:kWebScriptNamespace];
}

#pragma mark WebScripting Protocol

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector
{
    if (selector == @selector(quit) ||
        selector == @selector(openURL:) ||
        selector == @selector(notify:)) {
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
    else if (selector == @selector(openURL:)) {
        result = @"openURL";
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

- (void)notify:(WebScriptObject *)message
{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = [message valueForKey:@"title"];
    notification.informativeText = [message valueForKey:@"content"];
    notification.deliveryDate = [NSDate date];
    notification.soundName = NSUserNotificationDefaultSoundName;
    [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notification];
}

#pragma mark - Delegate methods

- (void)webView:(WebView*)webView addMessageToConsole:(NSDictionary*)message
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
