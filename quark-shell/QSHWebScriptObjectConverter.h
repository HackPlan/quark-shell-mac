//
//  QSHWebScriptObjectConverter.h
//  quark-shell
//
//  Created by Xhacker Liu on 6/14/14.
//  Copyright (c) 2014 Xhacker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QSHWebScriptObjectConverter : NSObject

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

/**
 *  Call function in WebScriptObject
 *
 *  @param webScriptObject Function object
 */
- (void)callFunction:(WebScriptObject *)webScriptObject;

/**
 *  Call function in WebScriptObject with arguments
 *
 *  @param webScriptObject Function object
 *  @param args arguments
 */
- (void)callFunction:(WebScriptObject *)webScriptObject
            withArgs:(NSArray *)args;

@end
