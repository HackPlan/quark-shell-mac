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

- (void)setLabel:(NSString *)label
{
    _label = label;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self.statusItem drawStatusBarBackgroundInRect:self.bounds withHighlight:self.itemHighlighted];
    
    CGFloat xOffset = (NSWidth(self.bounds) - 20) / 2;
    CGFloat yOffset = (NSHeight(self.bounds) - 20) / 2;
    NSRect iconFrame = NSMakeRect(xOffset, yOffset, 20, 20);
    
    if (self.label) {
        iconFrame = NSMakeRect(3, yOffset, 20, 20);
        NSColor *color = self.itemHighlighted ? [NSColor whiteColor] : [NSColor blackColor];
        NSDictionary *barTextAttributes = @{
                                            NSFontAttributeName: MENUBAR_FONT,
                                            NSForegroundColorAttributeName: color
                                            };
        [self.label drawInRect:NSMakeRect(25, 2, NSWidth(self.bounds) - 30, 20) withAttributes:barTextAttributes];
    }

    NSImage *iconImage = self.itemHighlighted ? self.highlightedIcon : self.icon;
    [iconImage drawInRect:iconFrame];
}

@end
