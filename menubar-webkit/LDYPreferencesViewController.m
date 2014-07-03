//
//  LDYPreferencesViewController.m
//  menubar-webkit
//
//  Created by Xhacker Liu on 6/11/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import "LDYPreferencesViewController.h"

@interface LDYPreferencesViewController ()

@property (weak) IBOutlet WebView *webView;

@property (nonatomic) NSString *identifier;
@property (nonatomic) NSImage *toolbarItemImage;
@property (nonatomic) NSString *toolbarItemLabel;

@end

@implementation LDYPreferencesViewController

- (instancetype)initWithIdentifier:(NSString *)identifier
                      toolbarImage:(NSImage *)image
                      toolbarLabel:(NSString *)label
{
    self = [super initWithNibName:@"LDYPreferencesViewController" bundle:nil];
    if (self) {
        _identifier = identifier;
        _toolbarItemImage = image;
        _toolbarItemLabel = label;
    }
    return self;
}

- (void)loadView
{
    [super loadView];

    NSString *url = [[NSURL URLWithString:kPreferencesDirectory relativeToURL:[[NSBundle mainBundle] resourceURL]] absoluteString];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"%@.html", self.identifier]];
    self.webView.mainFrameURL = url;

    self.webView.policyDelegate = self;
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

@end
