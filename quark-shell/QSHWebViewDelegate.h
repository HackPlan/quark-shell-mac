//
//  QSHWebViewDelegate.h
//  quark-shell
//
//  Created by Xhacker Liu on 3/31/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <MASShortcut/Shortcut.h>
#import "QSHStatusItemView.h"
#import "QSHAppDelegate.h"
#import "WKWebViewJavascriptBridge.h"

@class QSHWebView;
@class QSHWebViewWindowController;

@interface QSHWebViewDelegate : NSObject <WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, weak) QSHAppDelegate *appDelegate;
@property (nonatomic, weak) NSStatusItem *statusItem;
@property (nonatomic, weak) QSHStatusItemView *statusItemView;
@property (nonatomic, weak) QSHWebView *webView;
@property (nonatomic, weak) WKWebViewJavascriptBridge *mainBridge;

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector;
+ (NSURL *)getRootURL;
+ (NSURL *)getIndexURL;

+ (void)initWebviewWithBridge:(QSHWebView*)webview url:(NSURL*)url webDelegate:(QSHWebViewDelegate*)webDelegate isMain:(BOOL)isMain;

- (void)changeIcon:(NSArray *)args;

- (void)removeWindowFromWindows:(QSHWebViewWindowController *)windowController;

@end
