//
//  LDYNewWindowController.m
//  menubar-webkit
//
//  Created by Xhacker Liu on 7/2/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import "LDYWebViewWindowController.h"

@interface LDYWebViewWindowController ()

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
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

@end
