//
//  QSHPreferencesViewController.m
//  quark-shell
//
//  Created by Xhacker Liu on 6/11/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import "QSHPreferencesViewController.h"

@interface QSHPreferencesViewController ()

@property (nonatomic) NSString *identifier;
@property (nonatomic) NSString *url;
@property (nonatomic) NSImage *toolbarItemImage;
@property (nonatomic) NSString *toolbarItemLabel;
@property (nonatomic) NSInteger height;
@property (nonatomic, weak) QSHWebViewDelegate* delegate;

@end

@implementation QSHPreferencesViewController

// a hack for OS X 10.9, don't really know why
@synthesize identifier = _identifier;

- (instancetype)initWithIdentifier:(NSString *)identifier
                               url:(NSString *)url
                      toolbarImage:(NSImage *)image
                      toolbarLabel:(NSString *)label
                            height:(NSInteger)height
                          delegate:(id)delegate
{
    self = [super initWithNibName:@"QSHPreferencesViewController" bundle:nil];
    if (self) {
        _identifier = identifier;
        _url = url;
        _toolbarItemImage = image;
        _toolbarItemLabel = label;
        _height = height;
        _delegate = delegate;
    }
    return self;
}

- (void)_createViews {
    NSView* contentView = self.view;
    
    // WKWebView
    _webView = [[QSHWebView alloc] initWithFrame:contentView.frame];
    [_webView setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];
    _webView.configuration.preferences._developerExtrasEnabled = YES;
    [contentView addSubview:_webView];
}

- (void)loadView
{
    [super loadView];

    self.view.frame = NSMakeRect(self.view.frame.origin.x, self.view.frame.origin.y,
                                 self.view.frame.size.width, self.height);
    
    [self _createViews];

    NSURL *url = [NSURL URLWithString:_url relativeToURL:[QSHWebViewDelegate getRootURL]];
    
    [QSHWebViewDelegate initWebviewWithBridge:_webView url:url webDelegate:_delegate isMain:NO];
}

- (void)addNativeComponent:(NSDictionary *)component
{
    if ([component[@"type"] isEqualToString:@"ShortcutRecorder"]) {
        static const CGFloat width = 180;
        static const CGFloat height = 19;
        CGFloat x = [component[@"options"][@"x"] doubleValue];
        CGFloat yFlipped = self.view.frame.size.height - [component[@"options"][@"y"] doubleValue] - height;

        MASShortcutView *shortcutView = [[MASShortcutView alloc] initWithFrame:NSMakeRect(x, yFlipped, width, height)];
        
        NSString *shortcutDefaultsKey = [@"shortcut_" stringByAppendingString:component[@"options"][@"id"]];
        
        shortcutView.associatedUserDefaultsKey = shortcutDefaultsKey;
        
        [[MASShortcutBinder sharedBinder] bindShortcutWithDefaultsKey:shortcutDefaultsKey toAction:^{
            [self.delegate.mainBridge callHandler:@"onQuarkShortcut" data:component[@"options"][@"id"] ];
        }];

        [self.view addSubview:shortcutView];
    }
}

@end
