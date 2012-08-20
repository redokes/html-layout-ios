//
//  ExampleFormField.m
//  html-layout-ios
//
//  Created by Jared Lewis on 8/18/12.
//  Copyright (c) 2012 Jared Lewis. All rights reserved.
//

#import "ExampleFormField.h"

@implementation ExampleFormField

@synthesize fieldLabel;
@synthesize textField;

- (void)initComponent
{
    [super initComponent];
    [self setTypeFromString:@"hbox"];
    [self setPack:UIFlexibleViewPackCenter];
    [self setAlign:UIFlexibleViewAlignStretchMax];
    [self initFieldLabel];
    [self initTextField];
    [self setBackgroundColor:[UIColor whiteColor]];
}

- (void)initFieldLabel
{
    fieldLabel = [[UILabel alloc] init];
    [fieldLabel setText:@"Field:"];
    [fieldLabel setBackgroundColor:[UIColor clearColor]];
    [fieldLabel sizeToFit];
    CGRect frame = fieldLabel.frame;
    frame.size.width = 75;
    [fieldLabel setFrame:frame];
    [self addItem:fieldLabel withFlex:0 andMargin:CGRectMake(20, 0, 5, 0)];
}

- (void)initTextField
{
    textField = [[UITextField alloc] init];
    [textField setBackgroundColor:[UIColor whiteColor]];
    [self addItem:textField withFlex:2 andMargin:CGRectMake(0, 0, 20, 0)];
}

- (void)setLabel:(NSString *)label
{
    [fieldLabel setText:label];

}

@end
