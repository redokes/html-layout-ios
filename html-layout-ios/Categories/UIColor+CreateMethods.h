//
//  UIColor+CreateMethods.h
//  fireplug-ios
//
//  Created by Jared Lewis on 7/26/12.
//  Copyright (c) 2012 Akimbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (CreateMethods)

// wrapper for [UIColor colorWithRed:green:blue:alpha:]
// values must be in range 0 - 255
+ (UIColor*)colorWith8BitRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(CGFloat)alpha;

// Creates color using hex representation
// hex - must be in format: #FF00CC 
// alpha - must be in range 0.0 - 1.0
+ (UIColor*)colorWithHex:(NSString*)hex alpha:(CGFloat)alpha;

@end
