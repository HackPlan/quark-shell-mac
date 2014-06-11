//
//  LDYPreferencesViewController.m
//  menubar-webkit
//
//  Created by Xhacker Liu on 6/11/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import "LDYPreferencesViewController.h"

@interface LDYPreferencesViewController ()

@end

@implementation LDYPreferencesViewController

- (id)init
{
    return [super initWithNibName:@"LDYPreferencesViewController" bundle:nil];
}

- (NSString *)identifier
{
    return @"GeneralPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)toolbarItemLabel
{
    return @"General";
}

@end
