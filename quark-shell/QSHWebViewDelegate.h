//
//  QSHWebViewDelegate.h
//  quark-shell
//
//  Created by Xhacker Liu on 3/31/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QSHStatusItemView.h"
#import "QSHAppDelegate.h"

@interface QSHWebViewDelegate : NSObject

@property (nonatomic, weak) QSHAppDelegate *appDelegate;
@property (nonatomic, weak) NSStatusItem *statusItem;
@property (nonatomic, weak) QSHStatusItemView *statusItemView;
@property (nonatomic, weak) WebView *webView;

@end
