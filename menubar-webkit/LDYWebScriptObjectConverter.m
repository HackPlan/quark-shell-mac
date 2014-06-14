//
//  LDYWebScriptObjectConverter.m
//  menubar-webkit
//
//  Created by Xhacker Liu on 6/14/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import "LDYWebScriptObjectConverter.h"

@interface LDYWebScriptObjectConverter ()

@property (nonatomic, weak) WebView *webView;

@end

@implementation LDYWebScriptObjectConverter

- (instancetype)initWithWebView:(WebView *)webView
{
    self = [super init];
    if (self) {
        _webView = webView;
        [self registerJavaScriptHelpers];
    }
    return self;
}

- (void)registerJavaScriptHelpers
{
    NSString *cordovaBridgeUtil = @"LDYBridgeUtil = {};";
    NSString *isArray = @"LDYBridgeUtil.isArray = function(obj) { return obj.constructor == Array; };";
    NSString *isObject = @"LDYBridgeUtil.isObject = function(obj) { return obj.constructor == Object; };";
    NSString *dictionaryKeys = @"LDYBridgeUtil.dictionaryKeys = function(obj) { \
                                     var a = []; \
                                     for (var key in obj) { \
                                         if (!obj.hasOwnProperty(key)) { \
                                             continue; \
                                         } \
                                         a.push(key); \
                                     } \
                                     return a; \
                                 }";

    WebScriptObject *win = self.webView.windowScriptObject;
    [win evaluateWebScript:cordovaBridgeUtil];
    [win evaluateWebScript:isArray];
    [win evaluateWebScript:isObject];
    [win evaluateWebScript:dictionaryKeys];
}

- (BOOL)isArray:(WebScriptObject *)obj
{
    WebScriptObject *win = self.webView.windowScriptObject;
    WebScriptObject *bridgeUtil = [win evaluateWebScript:@"LDYBridgeUtil"];
    NSNumber *result = [bridgeUtil callWebScriptMethod:@"isArray" withArguments:@[obj]];

    return result.boolValue;
}

- (BOOL)isDictionary:(WebScriptObject *)obj
{
    WebScriptObject *win = self.webView.windowScriptObject;
    WebScriptObject *bridgeUtil = [win evaluateWebScript:@"LDYBridgeUtil"];
    NSNumber *result = [bridgeUtil callWebScriptMethod:@"isObject" withArguments:@[obj]];

    return result.boolValue;
}

- (NSDictionary *)dictionaryFromWebScriptObject:(WebScriptObject *)webScriptObject
{
    WebScriptObject *win = self.webView.windowScriptObject;
    WebScriptObject *bridgeUtil = [win evaluateWebScript:@"LDYBridgeUtil"];

    WebScriptObject *keysObject = [bridgeUtil callWebScriptMethod:@"dictionaryKeys" withArguments:@[webScriptObject]];
    NSArray *keys = [self arrayFromWebScriptObject:keysObject];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:keys.count];

    for (NSString *key in keys) {
        id item = [webScriptObject valueForKey:key];
        if ([item isKindOfClass:[WebScriptObject class]]) {
            if ([self isArray:item]) {
                dict[key] = [self arrayFromWebScriptObject:item];
            }
            else if ([self isDictionary:item]) {
                dict[key] = [self dictionaryFromWebScriptObject:item];
            }
        }
        else {
            dict[key] = item;
        }
    }

    return dict;
}

- (NSArray *)arrayFromWebScriptObject:(WebScriptObject *)webScriptObject
{
    NSUInteger count = [[webScriptObject valueForKey:@"length"] integerValue];
    NSMutableArray *a = [NSMutableArray array];
    for (unsigned i = 0; i < count; i++) {
        id item = [webScriptObject webScriptValueAtIndex:i];
        if ([item isKindOfClass:[WebScriptObject class]]) {
            if ([self isArray:item]) {
                [a addObject:[self arrayFromWebScriptObject:item]];
            }
            else if ([self isDictionary:item]) {
                [a addObject:[self dictionaryFromWebScriptObject:item]];
            }
        }
        else {
            [a addObject:item];
        }
    }

    return a;
}

@end
