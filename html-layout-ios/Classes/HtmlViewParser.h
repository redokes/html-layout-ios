//
//  HtmlViewParser.h
//  html-layout-ios
//
//  Created by Jared Lewis on 8/17/12.
//  Copyright (c) 2012 Jared Lewis. All rights reserved.
//

#import <Foundation/Foundation.h>

//Classes needed
@class HtmlViewController;
@class TFHppleElement;

@interface HtmlViewParser : NSObject

@property (nonatomic, weak) HtmlViewController *viewController;
@property UIView *rootView;
@property TFHppleElement *rootElement;

- (id)initWithViewController:(HtmlViewController *)htmlViewController;
- (void)parse:(NSData *)data;
@end
