//
//  NSString+Util.m
//  html-layout-ios
//
//  Created by Wes Okes on 8/17/12.
//  Copyright (c) 2012 Jared Lewis. All rights reserved.
//

#import "NSString+Util.h"

@implementation NSString (Util)

- (BOOL)contains:(NSString *)subStr
{
    if ([self rangeOfString:subStr].location == NSNotFound) {
        return NO;
    }
    else {
        return YES;
    }
}

- (NSString *)capitalize
{
    return [self stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[self substringToIndex:1] uppercaseString]];
}

@end
