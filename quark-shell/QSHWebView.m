//
//  QSHWebView.m
//  quark-shell
//
//  Created by Sun Liang on 27/10/2016.
//  Copyright © 2016 HackPlan. All rights reserved.
//

#import "QSHWebView.h"
#import "QSH_GCDTimer.h"

@interface QSHWebView () {
    NSMutableDictionary *_intervalTimers;
}

@end

@implementation QSHWebView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _intervalTimers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
    return [super initWithFrame:frameRect configuration: [QSHWebView webViewConfiguration]];
}

- (void)setInterval:(NSNumber *)callbackId interval:(NSNumber *)interval isRepeat:(BOOL)isRepeat
{
    [self clearInterval:callbackId];
    _intervalTimers[callbackId] = [QSH_GCDTimer
                                   timerWithTimeInterval:interval
                                   inQueue:dispatch_get_main_queue()
                                   repeats:isRepeat
                                   block:^(QSH_GCDTimer *timer) {
                                       [self.bridge
                                        callHandler:@"intervalCallback"
                                        data:@{@"callbackId": callbackId}
                                        ];
                                   }];
}

- (void)clearInterval:(NSNumber *)timerId
{
    QSH_GCDTimer *timer = _intervalTimers[timerId];
    if (timer != nil) {
        [_intervalTimers removeObjectForKey:timerId];
        [timer invalidate];
    }
}

- (void)clearAllIntervalTimer
{
    for (NSNumber *timerId in [_intervalTimers allKeys]) {
        [self clearInterval:timerId];
    }
}

# pragma mark - private methods

+ (NSString *)quarkSourceScript
{
    return [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Quark" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
}

+ (NSString *)quarkHeaderScript
{
    return [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"QuarkHeader" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
}

+ (WKWebViewConfiguration *)webViewConfiguration
{
    static WKWebViewConfiguration *configuration = nil;
    
    if (configuration == nil) {
        configuration = [[WKWebViewConfiguration alloc] init];
        
        WKUserScript *headerScript = [[WKUserScript alloc] initWithSource:[self quarkHeaderScript] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
        WKUserScript *footerScript = [[WKUserScript alloc] initWithSource:[self quarkSourceScript] injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        
        [configuration.userContentController addUserScript:headerScript];
        [configuration.userContentController addUserScript:footerScript];
    }
    
    return configuration;
}

@end
