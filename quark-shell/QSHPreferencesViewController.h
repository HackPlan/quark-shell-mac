//
//  QSHPreferencesViewController.h
//  quark-shell
//
//  Created by Xhacker Liu on 6/11/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MASPreferences/MASPreferences.h>
#import <MASShortcut/Shortcut.h>
#import "QSHWebView.h"
#import "QSHWebViewDelegate.h"

@interface QSHPreferencesViewController : NSViewController <MASPreferencesViewController>

@property (nonatomic, strong) QSHWebView *webView;

- (instancetype)initWithIdentifier:(NSString *)identifier
                      toolbarImage:(NSImage *)image
                      toolbarLabel:(NSString *)label
                            height:(NSInteger)height
                          delegate:(id)delegate;

- (void)addNativeComponent:(NSDictionary *)component;

@end
