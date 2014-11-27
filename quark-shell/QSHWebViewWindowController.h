//
//  QSHNewWindowController.h
//  quark-shell
//
//  Created by Xhacker Liu on 7/2/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QSHWebViewWindowController : NSWindowController

@property (weak) IBOutlet WebView *webView;

- (id)initWithURLString:(NSString *)URLString
                  width:(CGFloat)width
                 height:(CGFloat)height;

@end
