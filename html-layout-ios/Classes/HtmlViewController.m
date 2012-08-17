//
//  HtmlViewController.m
//  html-layout
//
//  Created by Jared Lewis on 8/17/12.
//  Copyright (c) 2012 Jared Lewis. All rights reserved.
//

#import "HtmlViewController.h"
#import "TFHpple.h"
#import "TFHppleElement.h"
#import "UIColor+CreateMethods.h"
#import "HtmlViewParser.h"
#import "UIFlexibleView.h"

@interface HtmlViewController ()

@end

@implementation HtmlViewController

@synthesize layoutPath;
@synthesize htmlViewParser;
@synthesize refreshButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initComponent];
    }
    return self;
}

- (id)initWithLayoutPath:(NSString *)path
{
    layoutPath = path;
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        
    }
    return self;
}

- (void)initComponent
{
    [self initHtmlViewParser];
    [self initRefreshButton];
}

- (void)initHtmlViewParser
{
    htmlViewParser = [[HtmlViewParser alloc] initWithViewController:self];
}

- (void)initRefreshButton
{
    refreshButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [refreshButton setTitle:@"Refresh" forState:UIControlStateNormal];
    [refreshButton sizeToFit];
    [refreshButton addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventTouchUpInside];
    CGRect frame = refreshButton.frame;
    frame.origin.x = 5;
    frame.origin.y = 5;
    [refreshButton setFrame:frame];
}

- (void)loadView
{
    [super loadView];
    [htmlViewParser parse:[NSData dataWithContentsOfFile:self.layoutPath]];
    self.view = htmlViewParser.rootView;
}

- (void)refreshView
{
    
}

@end
