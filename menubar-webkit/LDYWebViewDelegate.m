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

- (void)webView:(WebView*)webView didClearWindowObject:(WebScriptObject *)windowScriptObject forFrame:(WebFrame *)frame
{
    [windowScriptObject setValue:self forKey:kWebScriptNamespace];
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector
{
	return NO;
}

- (void)quit
{
    [NSApp terminate:nil];
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
