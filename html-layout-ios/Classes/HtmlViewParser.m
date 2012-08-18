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
    //Get the children and properties
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
    
    
    //Create the view
    UIView *view = [self allocViewFromElement:element];
    
    //Apply the propery
    [self applyProperty:view fromElement:element withParentView:parentView];
    
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
- (UIView *)allocViewFromElement:(TFHppleElement *)element
{
    //Create the class
    Class cls = NSClassFromString([element objectForKey:@"class"]);
    UIView *view = nil;
    
    //Allocate and init the view
    if ([element objectForKey:@"init"] != nil) {
        SEL initSelector = NSSelectorFromString([element objectForKey:@"init"]);
        if ([viewController respondsToSelector:initSelector]) {
            view = [viewController performSelector:initSelector];
        }
    }
    else {
        view = [[cls alloc] init];
    }
    return view;
    
    //Create the alloc selector
    /*
    if (alloc != nil) {
        SEL allocSelector = NSSelectorFromString([alloc objectForKey:@"name"]);
        if ([alloc objectForKey:@"type"] != nil){
            if ([[alloc objectForKey:@"type"] isEqualToString:@"int"]) {
                view = objc_msgSend(cls, allocSelector, [[alloc objectForKey:@"value"] intValue]);
            }
        }
        else {
            view = objc_msgSend(cls, allocSelector, [alloc objectForKey:@"value"]);
        }
    }
    else{
        view = [[cls alloc] init];
    }
    */
}

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
        frame.size.width = 10;
        frame.size.height = 10;
        [view setFrame:frame];
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
