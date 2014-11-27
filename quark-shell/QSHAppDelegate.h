//
//  QSHAppDelegate.h
//  quark-shell
//
//  Created by Xhacker Liu on 3/25/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QSHAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic) BOOL pinned;

- (void)showWindow;
- (void)hideWindow;

@end
