//
//  DemoFormViewController.m
//  html-layout-ios
//
//  Created by Jared Lewis on 8/18/12.
//  Copyright (c) 2012 Jared Lewis. All rights reserved.
//

#import "ExampleFormViewController.h"
#import "UIFlexibleView.h"
#import "ExampleFormFieldViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ExampleFormViewController ()

@end

@implementation ExampleFormViewController

@synthesize formContainer;
@synthesize scrollView;
@synthesize scrollViewBody;
@synthesize firstNameField;
@synthesize lastNameField;
@synthesize emailField;
@synthesize addressField;
@synthesize cityField;
@synthesize stateField;
@synthesize zipField;

- (void)initComponent{
    [super initComponent];
    [self setLayoutPath:[[NSBundle mainBundle] pathForResource:@"form" ofType:@"html"]];
}

- (UIButton *)createButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Button" forState:UIControlStateNormal];
    [button sizeToFit];
    return button;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, [scrollViewBody getTotalHeight])];
    [firstNameField.fieldLabel setText:@"First Name:"];
    [lastNameField.fieldLabel setText:@"Last Name:"];
    [emailField.fieldLabel setText:@"Email:"];
    [addressField.fieldLabel setText:@"Address:"];
    [cityField.fieldLabel setText:@"City:"];
    [stateField.fieldLabel setText:@"State:"];
    [zipField.fieldLabel setText:@"Zip:"];
    
    [formContainer.layer setCornerRadius:7.0f];
    [formContainer.layer setBorderColor:[UIColor whiteColor].CGColor];
    [formContainer.layer setBorderWidth:1.5f];
    [formContainer.layer setShadowColor:[UIColor blackColor].CGColor];
    [formContainer.layer setShadowOpacity:0.8];
    [formContainer.layer setShadowRadius:3.0];
    [formContainer.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
}

@end
