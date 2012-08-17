//
//  DemoViewController.m
//  html-layout-ios
//
//  Created by Jared Lewis on 8/17/12.
//  Copyright (c) 2012 Jared Lewis. All rights reserved.
//

#import "DemoViewController.h"

@interface DemoViewController ()

@end

@implementation DemoViewController

@synthesize webView;
@synthesize topToolbar;
@synthesize bottomToolbar;

- (void)initComponent
{
    [super initComponent];
    [self setLayoutPath:[[NSBundle mainBundle] pathForResource:@"layout" ofType:@"html"]];
    [self initWebView];
}

- (void)initWebView
{
    //Load web view data
    NSString *strWebsiteUlr = [NSString stringWithFormat:@"http://www.nooga.com"];
    NSURL *url = [NSURL URLWithString:strWebsiteUlr];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView loadRequest:requestObj];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self initWebView];
}

@end
