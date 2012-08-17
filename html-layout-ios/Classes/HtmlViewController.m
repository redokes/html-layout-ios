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
@synthesize toolbar;
@synthesize rootView;

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
}

- (void)initHtmlViewParser
{
    htmlViewParser = [[HtmlViewParser alloc] initWithViewController:self];
//    NSLog(@"%@", layoutPath);
    [htmlViewParser parse];
}

- (void)loadView
{
    self.view = htmlViewParser.rootView;
}

- (void)viewDidLoad
{
    NSLog(@"View did load");
    [super viewDidLoad];
    [toolbar setBarStyle:UIBarStyleBlack];
    [rootView setType:UIFlexibleViewTypeVertical];
    [rootView setAlign:UIFlexibleViewAlignStretch];
    //[self.view addSubview:refreshButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
