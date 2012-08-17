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
@property (nonatomic) HtmlViewParser *htmlViewParser;
@property UIButton *refreshButton;
@property UIToolbar *toolbar;
@property (nonatomic) UIFlexibleView *rootView;

- (id)initWithLayoutPath:(NSString *)path;

@end
