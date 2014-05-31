//
//  LDYWebViewDelegate.h
//  menubar-webkit
//
//  Created by Xhacker Liu on 3/31/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDYStatusItemView.h"

@interface LDYWebViewDelegate : NSObject

@property (nonatomic, weak) LDYStatusItemView *statusItemView;
@property (nonatomic, weak) WebView *webView;

@end
