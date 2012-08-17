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

- (void)parse
{
    NSData *data = [NSData dataWithContentsOfFile:viewController.layoutPath];
//    NSLog(@"%@", data);
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
    NSArray *elements = [doc searchWithXPathQuery:@"//body/view"];
    rootElement = [elements objectAtIndex:0];
    rootView = [self createViewFromElement:rootElement withParentView:nil];
}

- (UIView *)createViewFromElement:(TFHppleElement *)element withParentView:(UIView *)parentView
{
    //Create the view from the views class attribute
    UIView *view = [[NSClassFromString([element objectForKey:@"class"]) alloc] init];
    
    //Apply the propery
    [self applyProperty:view fromElement:element withParentView:parentView];
    
    //Set the background color if necessary
    [self applyBackgroundColor:view fromElement:element];
    
    // Loop through attributes
    [self applyAttributes:view fromElement:element];
    
    //Set the frame
    [self applyFrame:view fromElement:element withParentView:(UIView *)parentView];
    
    // Process the children
    SEL processChildrenSelector = NSSelectorFromString([NSString stringWithFormat:@"processChildren:for%@:", [view class]]);
    if ([self respondsToSelector:processChildrenSelector]) {
        [self performSelector:processChildrenSelector withObject:element.children withObject:view];
    }
    
    //Return the view
    return view;
}

///////////////////////////////////////////////////
//  Apply Methods
//////////////////////////////////////////////////
- (void)applyProperty:(UIView *)view fromElement:(TFHppleElement *)element withParentView:(UIView *)parentView
{
    //Set the property
    NSString *property = [element objectForKey:@"property"];
    property = [property capitalize];
    NSString *selectorString = [NSString stringWithFormat:@"set%@:", property];
    SEL propertySelector = NSSelectorFromString(selectorString);
    if ([viewController respondsToSelector:propertySelector]) {
        [viewController performSelector:propertySelector withObject:view];
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
        frame.size.width = 10;
        frame.size.height = 10;
        [view setFrame:frame];
        return;
    }
    
    // Apply width
    NSString *width = [element objectForKey:@"width"];
    if ([width contains:@"%"]) {
        [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        frame.size.width = [width floatValue] / 100 * parentView.frame.size.width;
    }
    else {
        frame.size.width = [(NSString *)[element objectForKey:@"width"] intValue];
    }
    frame.size.width = [(NSString *)[element objectForKey:@"width"] intValue];
    frame.size.height = [(NSString *)[element objectForKey:@"height"] intValue];
    frame.origin.x = [(NSString *)[element objectForKey:@"x"] intValue];
    frame.origin.y = [(NSString *)[element objectForKey:@"y"] intValue];
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
        CGRect margin = CGRectMake(0, 0, 0, 0);
        if ([childElement objectForKey:@"margin"] != nil) {
            NSArray *marginParts = [[childElement objectForKey:@"margin"] componentsSeparatedByString:@" "];
            int numParts = [marginParts count];
            int marginTop = [[marginParts objectAtIndex:0] intValue];
            int marginRight = 0;
            int marginBottom = 0;
            int marginLeft = 0;
            switch (numParts) {
                case 1:
                    marginRight = marginBottom = marginLeft = marginTop;
                    break;
                case 2:
                    marginBottom = marginTop;
                    marginRight = marginLeft = [[marginParts objectAtIndex:1] intValue];
                    break;
                case 3:
                    marginRight = marginLeft = [[marginParts objectAtIndex:1] intValue];
                    marginBottom = [[marginParts objectAtIndex:2] intValue];
                    break;
                case 4:
                    marginRight = [[marginParts objectAtIndex:1] intValue];
                    marginBottom = [[marginParts objectAtIndex:2] intValue];
                    marginLeft = [[marginParts objectAtIndex:3] intValue];
                    break;
            }
            
            margin = CGRectMake(marginLeft, marginTop, marginRight, marginBottom);
            [config setObject:[NSValue valueWithCGRect:margin] forKey:@"margin"];
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
