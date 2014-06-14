//
//  LDYWebScriptObjectConverter.h
//  menubar-webkit
//
//  Created by Xhacker Liu on 6/14/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDYWebScriptObjectConverter : NSObject

- (instancetype)initWithWebView:(WebView *)webView;

- (BOOL)isArray:(WebScriptObject *)obj;
- (BOOL)isDictionary:(WebScriptObject *)obj;

/**
 *  Convert WebScriptObject to NSDictionary
 *  Assumption: webScriptObject has already been tested using isDictionary:
 *
 *  @param webScriptObject
 *
 *  @return NSDictionary
 */
- (NSDictionary *)dictionaryFromWebScriptObject:(WebScriptObject *)webScriptObject;

/**
 *  Convert WebScriptObject to NSArray
 *  Assumption: webScriptObject has already been tested using isArray:
 *
 *  @param webScriptObject
 *
 *  @return NSArray
 */
- (NSArray *)arrayFromWebScriptObject:(WebScriptObject *)webScriptObject;

@end
