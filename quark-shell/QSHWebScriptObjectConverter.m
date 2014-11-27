//
//  QSHWebScriptObjectConverter.m
//  quark-shell
//
//  Created by Xhacker Liu on 6/14/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import "QSHWebScriptObjectConverter.h"

@interface QSHWebScriptObjectConverter ()

@property (nonatomic, weak) WebView *webView;

@end

@implementation QSHWebScriptObjectConverter

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
    NSString *bridgeUtil = @"QSHBridgeUtil = {};";
    NSString *isArray = @"QSHBridgeUtil.isArray = function(obj) { return obj.constructor == Array; };";
    NSString *isObject = @"QSHBridgeUtil.isObject = function(obj) { return obj.constructor == Object; };";
    NSString *dictionaryKeys = @"QSHBridgeUtil.dictionaryKeys = function(obj) { \
                                     var a = []; \
                                     for (var key in obj) { \
                                         if (!obj.hasOwnProperty(key)) { \
                                             continue; \
                                         } \
                                         a.push(key); \
                                     } \
                                     return a; \
                                 }";
    NSString *callFunction = @"QSHBridgeUtil.callFunction = function(func) { func(); };";
    NSString *callFunctionWithArgs = @"QSHBridgeUtil.callFunctionWithArgs = function(func, args) { func.apply(null, args); };";

    WebScriptObject *win = self.webView.windowScriptObject;
    [win evaluateWebScript:bridgeUtil];
    [win evaluateWebScript:isArray];
    [win evaluateWebScript:isObject];
    [win evaluateWebScript:dictionaryKeys];
    [win evaluateWebScript:callFunction];
    [win evaluateWebScript:callFunctionWithArgs];
}

- (BOOL)isArray:(WebScriptObject *)obj
{
    WebScriptObject *win = self.webView.windowScriptObject;
    WebScriptObject *bridgeUtil = [win evaluateWebScript:@"QSHBridgeUtil"];
    NSNumber *result = [bridgeUtil callWebScriptMethod:@"isArray" withArguments:@[obj]];

    return result.boolValue;
}

- (BOOL)isDictionary:(WebScriptObject *)obj
{
    WebScriptObject *win = self.webView.windowScriptObject;
    WebScriptObject *bridgeUtil = [win evaluateWebScript:@"QSHBridgeUtil"];
    NSNumber *result = [bridgeUtil callWebScriptMethod:@"isObject" withArguments:@[obj]];

    return result.boolValue;
}

- (NSDictionary *)dictionaryFromWebScriptObject:(WebScriptObject *)webScriptObject
{
    WebScriptObject *win = self.webView.windowScriptObject;
    WebScriptObject *bridgeUtil = [win evaluateWebScript:@"QSHBridgeUtil"];

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
            else {
                dict[key] = item;
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
            else {
                [a addObject:item];
            }
        }
        else {
            [a addObject:item];
        }
    }

    return a;
}

- (void)callFunction:(WebScriptObject *)webScriptObject
{
    WebScriptObject *win = self.webView.windowScriptObject;
    WebScriptObject *bridgeUtil = [win evaluateWebScript:@"QSHBridgeUtil"];
    [bridgeUtil callWebScriptMethod:@"callFunction" withArguments:@[webScriptObject]];
}

- (void)callFunction:(WebScriptObject *)webScriptObject
            withArgs:(NSArray *)args
{
    WebScriptObject *win = self.webView.windowScriptObject;
    WebScriptObject *bridgeUtil = [win evaluateWebScript:@"QSHBridgeUtil"];
    [bridgeUtil callWebScriptMethod:@"callFunctionWithArgs" withArguments:@[webScriptObject, args]];
}

@end
