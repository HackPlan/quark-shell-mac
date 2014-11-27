//
//  NSWindow+Fade.m
//  quark-shell
//
//  Courtesy to @indragiek: https://gist.github.com/indragiek/1397050
//

#import "NSWindow+Fade.h"

//#import "NSWindow+SNRAdditions.h"

#define kWindowAnimationDuration 0.1f

@implementation NSWindow (Fade)

- (void)fadeIn
{
    [self setAlphaValue:0.f];
    [self makeKeyAndOrderFront:nil];
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:kWindowAnimationDuration];
    [[self animator] setAlphaValue:1.f];
    [NSAnimationContext endGrouping];
}

- (void)fadeOut
{
    [NSAnimationContext beginGrouping];
    __block __unsafe_unretained NSWindow *bself = self;
    [[NSAnimationContext currentContext] setDuration:kWindowAnimationDuration];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        [bself orderOut:nil];
        [bself setAlphaValue:1.f];
    }];
    [[self animator] setAlphaValue:0.f];
    [NSAnimationContext endGrouping];
}

@end
