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
        _icon = [NSImage imageNamed:@"StatusIcon"];
        _highlightedIcon = [NSImage imageNamed:@"StatusIconWhite"];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;

    [self setNeedsDisplay];
}

- (void)setIcon:(NSImage *)icon
{
    _icon = icon;

    [self setNeedsDisplay];
}

- (void)setHighlightedIcon:(NSImage *)highlightedIcon
{
    _highlightedIcon = highlightedIcon;

    [self setNeedsDisplay];
}

- (void)drawRect:(NSRect)dirtyRect
{

    CGFloat offset = (NSWidth(self.bounds) - 20) / 2;
    NSRect iconFrame = NSMakeRect(offset, 0, 20, 20);

    if (self.highlighted) {
        [self.statusItem drawStatusBarBackgroundInRect:self.bounds withHighlight:YES];
        NSImage *iconImage = self.highlightedIcon;
        [iconImage drawInRect:iconFrame];
    }
    else {
        NSImage *iconImage = self.icon;
        [iconImage drawInRect:iconFrame];
    }
}

@end
