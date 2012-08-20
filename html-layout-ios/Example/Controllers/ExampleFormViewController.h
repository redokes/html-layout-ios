//
//  DemoFormViewController.h
//  html-layout-ios
//
//  Created by Jared Lewis on 8/18/12.
//  Copyright (c) 2012 Jared Lewis. All rights reserved.
//

#import "HtmlViewController.h"

@class UIFlexibleView;
@class ExampleFormFieldViewController;

@interface ExampleFormViewController : HtmlViewController

@property UIFlexibleView *formContainer;
@property UIScrollView *scrollView;
@property UIFlexibleView *scrollViewBody;
@property ExampleFormFieldViewController *firstNameField;
@property ExampleFormFieldViewController *lastNameField;
@property ExampleFormFieldViewController *emailField;
@property ExampleFormFieldViewController *addressField;
@property ExampleFormFieldViewController *cityField;
@property ExampleFormFieldViewController *stateField;
@property ExampleFormFieldViewController *zipField;

- (UIButton *)createButton;
@end
