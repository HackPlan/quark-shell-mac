//
//  LDYPreferencesViewController.m
//  menubar-webkit
//
//  Created by Xhacker Liu on 6/11/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import "LDYPreferencesViewController.h"

@interface LDYPreferencesViewController ()

@property (nonatomic) NSString *identifier;
@property (nonatomic) NSImage *toolbarItemImage;
@property (nonatomic) NSString *toolbarItemLabel;
@property (nonatomic, weak) id delegate;

@end

@implementation LDYPreferencesViewController

- (instancetype)initWithIdentifier:(NSString *)identifier
                      toolbarImage:(NSImage *)image
                      toolbarLabel:(NSString *)label
                          delegate:(id)delegate
{
    self = [super initWithNibName:@"LDYPreferencesViewController" bundle:nil];
    if (self) {
        _identifier = identifier;
        _toolbarItemImage = image;
        _toolbarItemLabel = label;
        _delegate = delegate;
    }
    return self;
}

- (void)loadView
{
    [super loadView];

    NSString *url = [[NSURL URLWithString:kPreferencesDirectory relativeToURL:[[NSBundle mainBundle] resourceURL]] absoluteString];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"%@.html", self.identifier]];
    self.webView.mainFrameURL = url;

    self.webView.frameLoadDelegate = self.delegate;
    self.webView.UIDelegate = self.delegate;
    self.webView.policyDelegate = self.delegate;
}

@end
