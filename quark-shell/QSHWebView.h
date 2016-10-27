//
//  QSHWebView.h
//  quark-shell
//
//  Created by 孙亮 on 27/10/2016.
//  Copyright © 2016 Hackplan. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "WKWebViewJavascriptBridge.h"

@interface WKPreferences (WKPrivate)
@property (nonatomic, setter=_setDeveloperExtrasEnabled:) BOOL _developerExtrasEnabled;
@end

@interface QSHWebView : WKWebView

@property (nonatomic, strong) WKWebViewJavascriptBridge *bridge;

@end
