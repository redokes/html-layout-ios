//
//  DemoViewController.m
//  html-layout-ios
//
//  Created by Jared Lewis on 8/17/12.
//  Copyright (c) 2012 Jared Lewis. All rights reserved.
//

#import "DemoViewController.h"
#import "UIFlexibleView.h"

@interface DemoViewController ()

@end

@implementation DemoViewController

@synthesize rootView;
@synthesize webView;
@synthesize topToolbar;
@synthesize bottomToolbar;
@synthesize scrollView;
@synthesize scrollViewBody;
@synthesize demoButton;

- (void)initComponent
{
    [super initComponent];
    [self setLayoutPath:[[NSBundle mainBundle] pathForResource:@"layout" ofType:@"html"]];
    [self initWebView];
}

- (void)initTopToolbar
{
    UILabel *title = [[UILabel alloc] init];
    [title setTextColor:[UIColor whiteColor]];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setText:@"Demo View Controller"];
    [title sizeToFit];
    [topToolbar addItem:title];
}

- (void)initWebView
{
    //Load web view data
    NSString *strWebsiteUlr = [NSString stringWithFormat:@"http://www.nooga.com"];
    NSURL *url = [NSURL URLWithString:strWebsiteUlr];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView loadRequest:requestObj];
}

- (UIButton *)createButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Button" forState:UIControlStateNormal];
    [button sizeToFit];
    return button;
}

- (void)toggleToolbar
{
    if (topToolbar.hidden == NO) {
        [topToolbar setHidden:YES];
    }
    else {
        [topToolbar setHidden:NO];
    }
    [self.view setNeedsLayout];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    //Animate the root view
    //[rootView setAnimate:YES];
    
    //Setup the webview
    [self initWebView];
    
    //Setup the toolbar
    [self initTopToolbar];
    
    //Set the content of the scroller
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, [scrollViewBody getTotalHeight])];
    
    //Add an action to the demo button
    [demoButton addTarget:self action:@selector(toggleToolbar) forControlEvents:UIControlEventTouchUpInside];
    [demoButton setTitle:@"Toggle Toolbar" forState:UIControlStateNormal];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end
