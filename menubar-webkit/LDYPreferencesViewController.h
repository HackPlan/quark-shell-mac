//
//  LDYPreferencesViewController.h
//  menubar-webkit
//
//  Created by Xhacker Liu on 6/11/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MASPreferencesWindowController.h>

@interface LDYPreferencesViewController : NSViewController <MASPreferencesViewController>

- (instancetype)initWithIdentifier:(NSString *)identifier
                      toolbarImage:(NSImage *)image
                      toolbarLabel:(NSString *)label;

@end
