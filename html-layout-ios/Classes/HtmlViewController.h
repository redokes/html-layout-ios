//
//  HtmlViewController.h
//  html-layout
//
//  Created by Jared Lewis on 8/17/12.
//  Copyright (c) 2012 Jared Lewis. All rights reserved.
//

#import <UIKit/UIKit.h>

//Classes needed
@class HtmlViewParser;
@class TFHppleElement;
@class UIFlexibleView;

@interface HtmlViewController : UIViewController

@property (nonatomic) NSString *layoutPath;
@property (nonatomic) NSString *layoutUrl;
@property (nonatomic) HtmlViewParser *htmlViewParser;
@property (nonatomic) UIButton *refreshButton;

- (id)initWithLayoutPath:(NSString *)path;
- (id)initWithLayoutUrl:(NSString *)path;
- (void)initComponent;

@end
