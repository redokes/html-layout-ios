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
#import "UIFlexibleView.h"
#import "NSString+Util.h"
#import "HtmlViewParser.h"

@interface HtmlViewController ()

@end

@implementation HtmlViewController

@synthesize layoutPath;
@synthesize htmlViewParser;
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
}

- (void)loadView
{
//    self.view = rootView;
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
    NSString *width = [element objectForKey:@"width"];
    if ([width contains:@"%"]) {
//        frame.size.width = [width floatValue] / 100 * rootView.frame.size.width;
    }
    else {
        frame.size.width = [(NSString *)[element objectForKey:@"width"] intValue];
    }
    
    frame.size.height = [(NSString *)[element objectForKey:@"height"] intValue];
    frame.origin.x = [(NSString *)[element objectForKey:@"x"] intValue];
    frame.origin.y = [(NSString *)[element objectForKey:@"y"] intValue];
    [view setFrame:frame];
    
    
    SEL processChildrenSelector = NSSelectorFromString([NSString stringWithFormat:@"processChildren:for%@:", [view class]]);
    if ([self respondsToSelector:processChildrenSelector]) {
        [self performSelector:processChildrenSelector withObject:element.children withObject:view];
    }
    
    //Return the view
    return view;
}

- (void)processChildren:(NSArray *)children forUIView:(UIView *)view
{
    // Process the children
    for (TFHppleElement *childElement in children) {
        UIView *childView = [self createViewFromElement:childElement];
        [view addSubview:childView];
    }
}

- (void)processChildren:(NSArray *)children forUIFlexibleView:(UIFlexibleView *)view
{
    // Process the children
    for (TFHppleElement *childElement in children) {
        UIView *childView = [self createViewFromElement:childElement];
        
        // Check for flex
        [view addItem:childView withFlex:1];
        if ([childElement objectForKey:@"flex"] != nil) {
            
        }

    }
}


- (void)viewDidLoad
{
    NSLog(@"View did load");
    [super viewDidLoad];
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
