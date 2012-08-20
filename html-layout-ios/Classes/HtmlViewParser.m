//
//  HtmlViewParser.m
//  html-layout-ios
//
//  Created by Jared Lewis on 8/17/12.
//  Copyright (c) 2012 Jared Lewis. All rights reserved.
//

#import "HtmlViewParser.h"
#import "HtmlViewController.h"
#import "TFHpple.h"
#import "TFHppleElement.h"
#import "UIColor+CreateMethods.h"
#import "UIFlexibleView.h"
#import "NSString+Util.h"

@implementation HtmlViewParser

@synthesize viewController;
@synthesize rootElement;
@synthesize rootView;

- (id)initWithViewController:(HtmlViewController *)htmlViewController
{
    self = [self init];
    if (self) {
        viewController = htmlViewController;
    }
    return self;
}

- (void)parse:(NSData *)data
{
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
    NSArray *elements = [doc searchWithXPathQuery:@"//body/view"];
    rootElement = [elements objectAtIndex:0];
    rootView = [self createViewFromElement:rootElement withParentView:nil];
}

- (UIView *)createViewFromElement:(TFHppleElement *)element withParentView:(UIView *)parentView
{
    //Get the children and selectors
    NSMutableArray *children = [[NSMutableArray alloc] init];
    NSMutableArray *selectors = [[NSMutableArray alloc] init];
    TFHppleElement *alloc = nil;
    for (TFHppleElement *childElement in element.children) {
        if ([childElement.tagName isEqualToString:@"view"]) {
            [children addObject:childElement];
        }
        if ([childElement.tagName isEqualToString:@"selector"]) {
            [selectors addObject:childElement];
        }
        if ([childElement.tagName isEqualToString:@"alloc"]) {
            alloc = childElement;
        }
    }
    
    
    //Create the object
    UIView *view = nil;
    UIViewController *vc = nil;
    id viewObject = [self allocViewFromElement:element];

    //Determine if this is a view controller
    if ([viewObject isKindOfClass:[UIViewController class]]) {
        vc = (UIViewController *)viewObject;
        view = vc.view;
        [viewController addChildViewController:vc];
    }
    else {
        view = (UIView *)viewObject;
    }
    
    //Apply the propery
    [self applyProperty:viewObject fromElement:element withParentView:parentView];
    
    //Set the background color if necessary
    [self applyBackgroundColor:view fromElement:element];
    
    // Loop through attributes
    [self applyAttributes:view fromElement:element];
    
    //Apply selectors
    [self applySelectors:view fromElements:selectors];
    
    //Set the frame
    [self applyFrame:view fromElement:element withParentView:(UIView *)parentView];
    
    // Process the children
    SEL processChildrenSelector = NSSelectorFromString([NSString stringWithFormat:@"processChildren:for%@:", @"UIView"]);
    if ([view isKindOfClass:NSClassFromString(@"UIFlexibleView")]) {
            processChildrenSelector = NSSelectorFromString([NSString stringWithFormat:@"processChildren:for%@:", @"UIFlexibleView"]);
    }
    if ([self respondsToSelector:processChildrenSelector]) {
        [self performSelector:processChildrenSelector withObject:children withObject:view];
    }
    
    //Return the view
    return view;
}

///////////////////////////////////////////////////
//  Apply Methods
//////////////////////////////////////////////////
- (id)allocViewFromElement:(TFHppleElement *)element
{
    //Create the class
    Class cls = NSClassFromString([element objectForKey:@"class"]);
    id viewObject = nil;
    
    //Allocate and init the view
    if ([element objectForKey:@"init"] != nil) {
        SEL initSelector = NSSelectorFromString([element objectForKey:@"init"]);
        if ([viewController respondsToSelector:initSelector]) {
            viewObject = [viewController performSelector:initSelector];
        }
    }
    else {
        viewObject = [[cls alloc] init];
    }
    return viewObject;
}

- (void)applyProperty:(id)viewObject fromElement:(TFHppleElement *)element withParentView:(UIView *)parentView
{
    //Set the property
    NSString *property = [element objectForKey:@"id"];
    property = [property capitalize];
    NSString *selectorString = [NSString stringWithFormat:@"set%@:", property];
    SEL propertySelector = NSSelectorFromString(selectorString);
    if ([viewController respondsToSelector:propertySelector]) {
        [viewController performSelector:propertySelector withObject:viewObject];
    }
}

- (void)applySelectors:(UIView *)view fromElements:(NSArray *)elements
{
    for (TFHppleElement *element in elements) {
        NSString *name = [element objectForKey:@"name"];
        NSString *value = [element objectForKey:@"value"];
        NSString *type = [element objectForKey:@"type"];
        SEL propertySelector = NSSelectorFromString(name);
        if ([view respondsToSelector:propertySelector]) {
            if ([type isEqualToString:@"int"]) {
                [view performSelector:propertySelector withObject:[NSNumber numberWithInt:[value intValue]]];
            }
            else {
                [view performSelector:propertySelector withObject:value];
            }
        }
        
        UIToolbar *tb = [[UIToolbar alloc] init];
        [tb setBarStyle:UIBarStyleBlack];
    }
}

- (void)applyBackgroundColor:(UIView *)view fromElement:(TFHppleElement *)element
{
    if ([element objectForKey:@"background-color"] == nil) {
        return;
    }
    
    UIColor *backgroundColor = [UIColor colorWithHex:[element objectForKey:@"background-color"] alpha:1.0f];
    [view setBackgroundColor:backgroundColor];
}

- (void)applyAttributes:(UIView *)view fromElement:(TFHppleElement *)element
{
    for (NSString *attributeItem in element.attributes) {
        NSString *attribute = [attributeItem capitalize];
        NSString *selectorString = [NSString stringWithFormat:@"set%@FromString:", attribute];
        SEL propertySelector = NSSelectorFromString(selectorString);
        if ([view respondsToSelector:propertySelector]) {
            [view performSelector:propertySelector withObject:[element.attributes objectForKey:attributeItem]];
        }
    }
}

- (void)applyFrame:(UIView *)view fromElement:(TFHppleElement *)element withParentView:(UIView *)parentView
{
    CGRect frame = view.frame;
    
    // Check if this is the root view
    if (parentView == nil) {
        return;
    }
    
    // Apply width
    NSString *width = [element objectForKey:@"width"];
    NSString *height = [element objectForKey:@"height"];
    NSString *x = [element objectForKey:@"x"];
    NSString *y = [element objectForKey:@"y"];
    if (width != nil) {
        if ([width contains:@"%"]) {
            [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            frame.size.width = [width floatValue] / 100 * parentView.frame.size.width;
        }
        else {
            frame.size.width = [width intValue];
        }
    }
    
    //Apply the height
    if (height != nil) {
        frame.size.height = [height intValue];
    }
    
    //Apply x
    if (x != nil) {
        frame.origin.x = [x intValue];
    }
    
    //Apply y
    if (y != nil) {
        frame.origin.y = [y intValue];
    }
    
    //Set the frame
    [view setFrame:frame];
}

- (void)processChildren:(NSArray *)children forUIView:(UIView *)view
{
    // Process the children
    for (TFHppleElement *childElement in children) {
        UIView *childView = [self createViewFromElement:childElement withParentView:view];
        [view addSubview:childView];
    }
}

- (void)processChildren:(NSArray *)children forUIFlexibleView:(UIFlexibleView *)view
{
    // Process the children
    for (TFHppleElement *childElement in children) {
        UIView *childView = [self createViewFromElement:childElement withParentView:view];
        
        //Get a default config
        NSMutableDictionary *config = [[view getDefaultConfig] mutableCopy];
        
        // Check for margin
        if ([childElement objectForKey:@"margin"] != nil) {
            [config setObject:[NSValue valueWithCGRect:[UIFlexibleView processRectString:[childElement objectForKey:@"margin"]]] forKey:@"margin"];
        }
        
        // Check for flex
        if ([childElement objectForKey:@"flex"] != nil) {
            NSString *flex = [childElement objectForKey:@"flex"];
            [config setObject:[NSNumber numberWithInt:[flex intValue]] forKey:@"flex"];
        }
        
        //Add item
        [view addItem:childView withFlex:[(NSNumber *)[config objectForKey:@"flex"] intValue] andMargin:[(NSValue *)[config objectForKey:@"margin"] CGRectValue]];
    }
}

@end
