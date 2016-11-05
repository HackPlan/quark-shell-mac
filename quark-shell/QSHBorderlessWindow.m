//
//  QSHBorderlessWindow.m
//  quark-shell
//
//  Created by Sun Liang on 06/11/2016.
//  Copyright © 2016 HackPlan. All rights reserved.
//

#import "QSHBorderlessWindow.h"

@interface BorderlessWindow()

@property (assign) NSPoint initialLocation;

@end

@implementation BorderlessWindow

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (BOOL)canBecomeMainWindow
{
    return YES;
}

- (void)sendEvent:(NSEvent *)theEvent
{
    if ([theEvent type] == NSLeftMouseDown)
    {
        [self mouseDown:theEvent];
    }
    else if ([theEvent type] == NSLeftMouseDragged)
    {
        [self mouseDragged:theEvent];
    }
    
    [super sendEvent:theEvent];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    self.initialLocation = [theEvent locationInWindow];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint currentLocation;
    NSPoint newOrigin;
    
    NSRect  screenFrame = [[NSScreen mainScreen] frame];
    NSRect  windowFrame = [self frame];
    
    currentLocation = [NSEvent mouseLocation];
    newOrigin.x = currentLocation.x - self.initialLocation.x;
    newOrigin.y = currentLocation.y - self.initialLocation.y;
    
    // Don't let window get dragged up under the menu bar
    if( (newOrigin.y+windowFrame.size.height) > (screenFrame.origin.y+screenFrame.size.height) ){
        newOrigin.y=screenFrame.origin.y + (screenFrame.size.height-windowFrame.size.height);
    }
    
    //go ahead and move the window to the new location
    [self setFrameOrigin:newOrigin];
}

@end
