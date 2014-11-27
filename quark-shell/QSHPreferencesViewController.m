//
//  QSHPreferencesViewController.m
//  quark-shell
//
//  Created by Xhacker Liu on 6/11/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import "QSHPreferencesViewController.h"
#import "QSHWebScriptObjectConverter.h"
#import <MASShortcutView.h>
#import <MASShortcut.h>

@interface QSHPreferencesViewController ()

@property (nonatomic) NSString *identifier;
@property (nonatomic) NSImage *toolbarItemImage;
@property (nonatomic) NSString *toolbarItemLabel;
@property (nonatomic) NSInteger height;
@property (nonatomic, weak) id delegate;

@end

@implementation QSHPreferencesViewController

// a hack for OS X 10.9, don't really know why
@synthesize identifier = _identifier;

- (instancetype)initWithIdentifier:(NSString *)identifier
                      toolbarImage:(NSImage *)image
                      toolbarLabel:(NSString *)label
                            height:(NSInteger)height
                          delegate:(id)delegate
{
    self = [super initWithNibName:@"QSHPreferencesViewController" bundle:nil];
    if (self) {
        _identifier = identifier;
        _toolbarItemImage = image;
        _toolbarItemLabel = label;
        _height = height;
        _delegate = delegate;
    }
    return self;
}

- (void)loadView
{
    [super loadView];

    self.view.frame = NSMakeRect(self.view.frame.origin.x, self.view.frame.origin.y,
                                 self.view.frame.size.width, self.height);

    NSString *url = [[NSURL URLWithString:kPreferencesDirectory relativeToURL:[[NSBundle mainBundle] resourceURL]] absoluteString];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"%@.html", self.identifier]];
    self.webView.mainFrameURL = url;

    self.webView.frameLoadDelegate = self.delegate;
    self.webView.UIDelegate = self.delegate;
    self.webView.policyDelegate = self.delegate;
}

- (void)addNativeComponent:(NSDictionary *)component
{
    if ([component[@"type"] isEqualToString:@"ShortcutRecorder"]) {
        static const CGFloat width = 180;
        static const CGFloat height = 19;
        CGFloat x = [component[@"options"][@"x"] doubleValue];
        CGFloat yFlipped = self.view.frame.size.height - [component[@"options"][@"y"] doubleValue] - height;

        MASShortcutView *shortcutView = [[MASShortcutView alloc] initWithFrame:NSMakeRect(x, yFlipped, width, height)];
        if (component[@"options"][@"keycode"]) {
            NSUInteger keycode = [component[@"options"][@"keycode"] unsignedIntegerValue];
            NSUInteger flags = [component[@"options"][@"modifierFlags"] unsignedIntegerValue];
            MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:keycode modifierFlags:flags];
            shortcutView.shortcutValue = shortcut;
        }
        
        shortcutView.shortcutValueChange = ^(MASShortcutView *sender) {
            QSHWebScriptObjectConverter *converter = [[QSHWebScriptObjectConverter alloc] initWithWebView:self.webView];
            [converter callFunction:component[@"options"][@"onChange"]
                           withArgs:@[@([sender.shortcutValue keyCode]),
                                      @([sender.shortcutValue modifierFlags])]];
        };

        [self.view addSubview:shortcutView];
    }
}

@end
