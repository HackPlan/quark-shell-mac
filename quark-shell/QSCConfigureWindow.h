//
//  QSCConfigureWindow.h
//  quark-shell
//
//  Created by Sun Liang on 2016/11/9.
//  Copyright © 2016年 HackPlan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import "QSHAppDelegate.h"

@interface QSCConfigureWindow : NSWindowController

@property (nonatomic, weak) QSHAppDelegate *appDelegate;

- (IBAction)loadButtonTapped:(NSButton *)sender;
- (IBAction)makeButtonTapped:(NSButton *)sender;
- (IBAction)resetButtonTapped:(NSButton *)sender;
@end

