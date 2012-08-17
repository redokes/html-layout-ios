//
//  HtmlViewController.h
//  html-layout
//
//  Created by Jared Lewis on 8/17/12.
//  Copyright (c) 2012 Jared Lewis. All rights reserved.
//

#import <UIKit/UIKit.h>

//Classes needed
@class TFHppleElement;

@interface HtmlViewController : UIViewController

@property UIButton *refreshButton;
@property UIToolbar *toolbar;
@property UIView *rootView;
@property TFHppleElement *rootElement;

@end
