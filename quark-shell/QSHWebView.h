//
//  QSHWebView.h
//  quark-shell
//
//  Created by Sun Liang on 27/10/2016.
//  Copyright © 2016 HackPlan. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "WKWebViewJavascriptBridge.h"

@class QSHWebViewWindowController;

@interface WKPreferences (WKPrivate)
@property (nonatomic, setter=_setDeveloperExtrasEnabled:) BOOL _developerExtrasEnabled;
@end

@interface QSHWebView : WKWebView

@property (nonatomic, strong) WKWebViewJavascriptBridge *bridge;
@property (nonatomic) QSHWebViewWindowController *parentWindow;

- (void)setInterval:(NSNumber *)callbackId interval:(NSNumber *)interval isRepeat:(BOOL)isRepeat;
- (void)clearInterval:(NSNumber *)callbackId;
- (void)clearAllIntervalTimer;

@end
