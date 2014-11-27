//
//  QSHNewWindowController.m
//  quark-shell
//
//  Created by Xhacker Liu on 7/2/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import "QSHWebViewWindowController.h"

@interface QSHWebViewWindowController ()

@end

@implementation QSHWebViewWindowController

- (id)initWithURLString:(NSString *)urlString
                  width:(CGFloat)width
                 height:(CGFloat)height
{
    self = [super initWithWindowNibName:@"QSHWebViewWindowController"];
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
