//
//  QSHStatusItemView.h
//  quark-shell
//
//  Created by Xhacker Liu on 5/1/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QSHStatusItemView : NSButton

#define MENUBAR_FONT [NSFont menuBarFontOfSize:14.0]

@property (nonatomic, weak) NSStatusItem *statusItem;
@property (nonatomic) BOOL itemHighlighted; // differentiate from NSControl’s highlighted
@property (nonatomic) NSImage *icon;
@property (nonatomic) NSImage *highlightedIcon;
@property (nonatomic) NSString *label;

@end
