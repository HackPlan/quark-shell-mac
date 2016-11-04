//
//  QSHWebView.m
//  quark-shell
//
//  Created by Sun Liang on 27/10/2016.
//  Copyright © 2016 HackPlan. All rights reserved.
//

#import "QSHWebView.h"

@implementation QSHWebView

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

- (instancetype)initWithFrame:(NSRect)frameRect
{
    return [super initWithFrame:frameRect configuration: [QSHWebView webViewConfiguration]];
}

@end
