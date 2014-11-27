//
//  QSHStatusItemView.m
//  quark-shell
//
//  Created by Xhacker Liu on 5/1/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import "QSHStatusItemView.h"

@implementation QSHStatusItemView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _icon = [NSImage imageNamed:@"StatusIcon"];
        _highlightedIcon = [NSImage imageNamed:@"StatusIconWhite"];
    }
    return self;
}

- (void)setItemHighlighted:(BOOL)itemHighlighted
{
    _itemHighlighted = itemHighlighted;

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

    [self.statusItem drawStatusBarBackgroundInRect:self.bounds withHighlight:self.itemHighlighted];
    NSImage *iconImage = self.itemHighlighted ? self.highlightedIcon : self.icon;
    [iconImage drawInRect:iconFrame];
}

@end
