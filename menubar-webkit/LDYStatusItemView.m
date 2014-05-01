//
//  LDYStatusItemView.m
//  menubar-webkit
//
//  Created by Xhacker Liu on 5/1/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import "LDYStatusItemView.h"

@implementation LDYStatusItemView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGFloat offset = (NSWidth(self.bounds) - 20) / 2;
    NSRect iconFrame = NSMakeRect(offset, 0, 20, 20);

    NSImage *iconImage = [NSImage imageNamed:@"StatusIcon"];
    [iconImage drawInRect:iconFrame];
}

@end
