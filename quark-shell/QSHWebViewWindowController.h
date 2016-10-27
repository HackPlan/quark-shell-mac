//
//  QSHNewWindowController.h
//  quark-shell
//
//  Created by Xhacker Liu on 7/2/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QSHWebView.h"
#import "QSHWebViewDelegate.h"

@interface QSHWebViewWindowController : NSWindowController

@property (nonatomic, strong) QSHWebView *webView;

- (id)initWithURLString:(NSString *)URLString
                  width:(CGFloat)width
                 height:(CGFloat)height
            webDelegate:(QSHWebViewDelegate *)webDelegate;

@end
