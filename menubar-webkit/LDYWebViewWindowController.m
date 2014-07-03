//
//  LDYNewWindowController.m
//  menubar-webkit
//
//  Created by Xhacker Liu on 7/2/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import "LDYWebViewWindowController.h"

@interface LDYWebViewWindowController ()

@property (weak) IBOutlet WebView *webView;

@end

@implementation LDYWebViewWindowController

- (id)initWithURLString:(NSString *)urlString
                  width:(NSInteger)width
                 height:(NSInteger)height
{
    self = [super initWithWindowNibName:@"LDYWebViewWindowController"];
    if (self) {
        [self.window setFrame:NSMakeRect(self.window.frame.origin.x, self.window.frame.origin.y, width, height) display:YES];
        self.window.animationBehavior = NSWindowAnimationBehaviorDocumentWindow;

        NSString *fullURLString = [kRootPath stringByAppendingString:urlString];
        NSString *url = [[NSURL URLWithString:fullURLString relativeToURL:[[NSBundle mainBundle] resourceURL]] absoluteString];
        self.webView.mainFrameURL = url;
        self.webView.policyDelegate = self;
        self.webView.frameLoadDelegate = self;
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
    NSString *scheme = request.URL.scheme;
    if ([scheme isEqualToString:@"file"]) {
        [listener use];
    }
    else {
        [listener ignore];
        [[NSWorkspace sharedWorkspace] openURL:request.URL];
    }
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    if (frame == self.webView.mainFrame) {
        self.window.title = title;
    }
}

@end
