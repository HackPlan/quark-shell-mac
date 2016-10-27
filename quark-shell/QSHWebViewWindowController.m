//
//  QSHNewWindowController.m
//  quark-shell
//
//  Created by Xhacker Liu on 7/2/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import "QSHWebViewWindowController.h"

@interface QSHWebViewWindowController () <WKUIDelegate, NSWindowDelegate>

@end

@implementation QSHWebViewWindowController {
    QSHWebViewDelegate *_webDelegate;
}

- (void)_createViews {
    NSView* contentView = self.window.contentView;
    
    // WKWebView
    _webView = [[QSHWebView alloc] initWithFrame:contentView.frame];
    [_webView setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];
    _webView.configuration.preferences._developerExtrasEnabled = YES;
    [contentView addSubview:_webView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"title"])
    {
        if (object == _webView) {
            self.window.title = _webView.title;
        }
        else
        {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (id)initWithURLString:(NSString *)urlString
                  width:(CGFloat)width
                 height:(CGFloat)height
            webDelegate:(QSHWebViewDelegate *)webDelegate
{
    self = [super initWithWindowNibName:@"QSHWebViewWindowController"];
    if (self) {
        [self.window setFrame:NSMakeRect(self.window.frame.origin.x, self.window.frame.origin.y, width, height) display:YES];
        self.window.animationBehavior = NSWindowAnimationBehaviorDocumentWindow;

        NSString *fullURLString = [kRootPath stringByAppendingString:urlString];
        NSURL *url = [NSURL URLWithString:fullURLString relativeToURL:[[NSBundle mainBundle] resourceURL]];
        
        [self _createViews];
        
        [QSHWebViewDelegate initWebviewWithBridge:_webView url:url webDelegate:webDelegate isMain:NO];
        
        [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
        
        _webDelegate = webDelegate;
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    self.window.delegate = self;
}

- (void)windowWillClose:(NSNotification *)notification
{
    [_webView removeObserver:self forKeyPath:@"title"];
    [_webDelegate removeWindowFromWindows:self];
}

@end
