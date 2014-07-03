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

- (id)initWithURLString:(NSString *)URLString
                  width:(NSInteger)width
                 height:(NSInteger)height
{
    self = [super initWithWindowNibName:@"LDYWebViewWindowController"];
    if (self) {
        [self.window setFrame:NSMakeRect(self.window.frame.origin.x, self.window.frame.origin.y, width, height) display:YES];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

@end
