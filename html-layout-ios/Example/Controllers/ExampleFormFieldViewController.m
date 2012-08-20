//
//  ExampleFormFieldViewController.m
//  html-layout-ios
//
//  Created by Jared Lewis on 8/19/12.
//  Copyright (c) 2012 Jared Lewis. All rights reserved.
//

#import "ExampleFormFieldViewController.h"

@interface ExampleFormFieldViewController ()

@end

@implementation ExampleFormFieldViewController

@synthesize fieldLabel;
@synthesize textField;

- (void)initComponent{
    [super initComponent];
    [self setLayoutPath:[[NSBundle mainBundle] pathForResource:@"field" ofType:@"html"]];
}

@end
