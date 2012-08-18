//
//  DemoViewController.h
//  html-layout-ios
//
//  Created by Jared Lewis on 8/17/12.
//  Copyright (c) 2012 Jared Lewis. All rights reserved.
//

#import "HtmlViewController.h"

@class UIFlexibleView;

@interface DemoViewController : HtmlViewController

@property UIFlexibleView *rootView;
@property UIWebView *webView;
@property UIFlexibleView *topToolbar;
@property UITabBar *bottomToolbar;
@property UIScrollView *scrollView;
@property UIFlexibleView *scrollViewBody;
@property UIButton *demoButton;

- (UIButton *)createButton;

@end
