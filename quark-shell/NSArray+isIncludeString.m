//
//  NSArray+isIncludeString.m
//  Pomotodo
//
//  Created by c4605 on 2017/1/16.
//  Copyright © 2017年 HackPlan. All rights reserved.
//

#import "NSArray+isIncludeString.h"

@implementation NSArray (isIncludeString)

- (BOOL)isIncludeString:(NSString *)str
{
    for (NSString *elem in self) {
        if (
            [elem isKindOfClass:[NSString class]] &&
            [elem isEqualToString:str]
        ) {
            return YES;
        }
    }
    
    return NO;
}

@end
