//
//  QSHWindowBorderView.m
//  quark-shell
//
//  Created by Xhacker Liu on 4/20/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import "QSHWindowBorderView.h"

static const CGFloat roundedRectangleCornerRadius = 5;
static const CGFloat arrowHeight = 10;
static const CGFloat arrowWidth = 20;

@implementation QSHWindowBorderView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (NSRect)innerFrame
{
    return NSMakeRect(0, 0, NSWidth(self.bounds), NSHeight(self.bounds) - arrowHeight);
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];

    NSRect roundedRectangleRect = NSMakeRect(0, 0, NSWidth(self.bounds), NSHeight(self.bounds) - arrowHeight);
    NSRect roundedRectangleInnerRect = NSInsetRect(roundedRectangleRect, roundedRectangleCornerRadius, roundedRectangleCornerRadius);
    NSBezierPath *roundedRectanglePath = [NSBezierPath bezierPath];
    [roundedRectanglePath appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(roundedRectangleInnerRect), NSMinY(roundedRectangleInnerRect)) radius: roundedRectangleCornerRadius startAngle:180 endAngle:270];
    [roundedRectanglePath appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(roundedRectangleInnerRect), NSMinY(roundedRectangleInnerRect)) radius: roundedRectangleCornerRadius startAngle:270 endAngle:360];
    [roundedRectanglePath appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(roundedRectangleInnerRect), NSMaxY(roundedRectangleInnerRect)) radius: roundedRectangleCornerRadius startAngle:0 endAngle:90];
    
    // draw arrow
    CGFloat arrowMidX = (_arrowMidX == 0) ? NSMidX(roundedRectangleRect) : _arrowMidX;
    
    [roundedRectanglePath lineToPoint:NSMakePoint(arrowMidX - arrowWidth / 2, NSMaxY(roundedRectangleRect))];
    [roundedRectanglePath lineToPoint:NSMakePoint(arrowMidX, NSMaxY(roundedRectangleRect) + arrowHeight)];
    [roundedRectanglePath lineToPoint:NSMakePoint(arrowMidX + arrowWidth / 2, NSMaxY(roundedRectangleRect))];
    
    [roundedRectanglePath appendBezierPathWithArcWithCenter: NSMakePoint(NSMinX(roundedRectangleInnerRect), NSMaxY(roundedRectangleInnerRect)) radius:roundedRectangleCornerRadius startAngle:90 endAngle:180];
    [roundedRectanglePath closePath];
    
    [[NSColor controlColor] setFill];
    [roundedRectanglePath fill];
}

@end
