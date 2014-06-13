//
//  LDYPreferencesViewController.m
//  menubar-webkit
//
//  Created by Xhacker Liu on 6/11/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import "LDYPreferencesViewController.h"

@interface LDYPreferencesViewController ()

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic) NSImage *toolbarItemImage;
@property (nonatomic, copy) NSString *toolbarItemLabel;

@end

@implementation LDYPreferencesViewController

- (instancetype)initWithIdentifier:(NSString *)identifier
                      toolbarImage:(NSImage *)image
                      toolbarLabel:(NSString *)label
{
    self = [super initWithNibName:@"LDYPreferencesViewController" bundle:nil];
    if (self) {
        _identifier = identifier;
        _toolbarItemImage = image;
        _toolbarItemLabel = label;
    }
    return self;
}

@end
