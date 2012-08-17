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

@interface HtmlViewController ()

@end

@implementation HtmlViewController

@synthesize refreshButton;
@synthesize toolbar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initComponent];
    }
    return self;
}

- (void)initComponent
{
    [self initRefreshButton];
}

- (void)initRefreshButton
{
    refreshButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [refreshButton setTitle:@"Refresh" forState:UIControlStateNormal];
    [refreshButton addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventTouchUpInside];
    CGRect frame = refreshButton.frame;
    frame.origin.x = 10;
    frame.origin.y = 10;
    [refreshButton setFrame:frame];
    [refreshButton sizeToFit];
}

- (void)initSubviews
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"layout" ofType:@"html"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
    NSArray *elements = [doc searchWithXPathQuery:@"//body/view/*"];
    for (TFHppleElement *element in elements) {
        UIView *view = [self createViewFromElement:element];
        [self.view addSubview:view];
     }
}

- (void)refreshView
{
    [self loadView];
    [self viewDidLoad];
}

- (void)loadView
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"layout" ofType:@"html"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
    NSArray *elements = [doc searchWithXPathQuery:@"//body/view"];
    TFHppleElement *element = [elements objectAtIndex:0];
    self.view = [self createViewFromElement:element];
}

- (UIView *)createViewFromElement:(TFHppleElement *)element
{
    //Create the view from the views class attribute
    UIView *view = [[NSClassFromString([element objectForKey:@"class"]) alloc] init];
    
    //Set the property
    if ([element objectForKey:@"property"] != nil) {
        NSString *property = [element objectForKey:@"property"];
        property = [property stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[property substringToIndex:1] uppercaseString]];
        NSString *selectorString = [NSString stringWithFormat:@"set%@:", property];
        NSLog(@"%@", selectorString);
        SEL propertySelector = NSSelectorFromString(selectorString);
        if ([self respondsToSelector:propertySelector]) {
            [self performSelector:propertySelector withObject:view];
        }
    }
    
    //Set the background color if necessary
    if ([element objectForKey:@"background-color"] != nil) {
        UIColor *backgroundColor = [UIColor colorWithHex:[element objectForKey:@"background-color"] alpha:1.0f];
        [view setBackgroundColor:backgroundColor];
    }
    
    //Set the frame
    CGRect frame = view.frame;
    frame.size.width = [(NSString *)[element objectForKey:@"width"] intValue];
    frame.size.height = [(NSString *)[element objectForKey:@"height"] intValue];
    frame.origin.x = [(NSString *)[element objectForKey:@"x"] intValue];
    frame.origin.y = [(NSString *)[element objectForKey:@"y"] intValue];
    [view setFrame:frame];
    
    // Process the children
    for (TFHppleElement *childElement in element.children) {
        UIView *childView = [self createViewFromElement:childElement];
        [view addSubview:childView];
    }
    
    //Return the view
    return view;
}

- (void)viewDidLoad
{
    NSLog(@"View did load");
    [super viewDidLoad];
//    [self initSubviews];
    [toolbar setBarStyle:UIBarStyleBlack];
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
