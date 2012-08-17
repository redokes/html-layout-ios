//
//  UIFlexibleView.m
//  fireplug-ios
//
//  Created by Jared Lewis on 8/16/12.
//  Copyright (c) 2012 Akimbo. All rights reserved.
//

#import "UIFlexibleView.h"

@implementation UIFlexibleView

@synthesize type;
@synthesize align;
@synthesize pack;
@synthesize animate;
@synthesize items;
@synthesize configs;

//////////////////////////////////////////////////////////
//  Init Methods
//////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initComponent];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initComponent];
    }
    return self;
}

- (void)initComponent
{
    animate = NO;
    items = [[NSMutableArray alloc] init];
    configs = [[NSMutableDictionary alloc] init];
}

//////////////////////////////////////////////////////////
//  Mutators
//////////////////////////////////////////////////////////
- (void)setType:(UIFlexibleViewType)newType
{
    if (type == newType) {
        return;
    }
    type = newType;
    [self setNeedsLayout];
}

- (void)setAlign:(UIFlexibleViewAlign)newAlign
{
    if (align == newAlign) {
        return;
    }
    align = newAlign;
    [self setNeedsLayout];
}

- (void)setPack:(UIFlexibleViewPack)newPack
{
    if (pack == newPack) {
        return;
    }
    pack = newPack;
    [self setNeedsLayout];
}

- (void)setItems:(NSMutableArray *)newItems
{
    [self removeAll];
    items = newItems;
    [self setNeedsLayout];
}

//////////////////////////////////////////////////////////
//  Methods
//////////////////////////////////////////////////////////
- (NSDictionary *)getConfig:(UIView *)view
{
    if ([configs objectForKey:[NSValue valueWithNonretainedObject:view]] != nil) {
        return [configs objectForKey:[NSValue valueWithNonretainedObject:view]];
    }
    return [self getDefaultConfig];
}
- (NSDictionary *)getDefaultConfig
{
    return @{
        @"flex" : [NSNumber numberWithInt:0],
        @"margin": [NSValue valueWithCGRect:CGRectMake(0, 0, 0, 0)],
        @"frame": [NSValue valueWithCGRect:CGRectMake(0, 0, 50, 40)]
    };
}

- (void)setConfig:(NSDictionary *)config forItem:(UIView *)view
{
    [configs setObject:config forKey:[NSValue valueWithNonretainedObject:view]];
}

- (void)addItem:(UIView *)view
{
    [self addItem:view withFlex:0 andMargin:CGRectMake(0, 0, 0, 0)];
}
- (void)addItem:(UIView *)view withFlex:(int)flex
{
    [self addItem:view withFlex:flex andMargin:CGRectMake(0, 0, 0, 0)];
}
- (void)addItem:(UIView *)view withFlex:(int)flex andMargin:(CGRect)margin
{
    [self addItem:view withFlex:flex andMargin:margin atIndex:items.count];
}

- (void)addItem:(UIView *)view withFlex:(int)flex andMargin:(CGRect)margin replaceItem:(UIView *)replaceView
{
    //Make sure the view we are replacing exists
    if ([items containsObject:replaceView] == NO) {
        return;
    }
    
    //Get the index of the item we are replacing
    int index = [items indexOfObject:replaceView];
    [self addItem:view withFlex:flex andMargin:margin atIndex:index];
    [self removeItem:replaceView];
}

- (void)addItem:(UIView *)view withFlex:(int)flex andMargin:(CGRect)margin atIndex:(int)index
{
    //Do not add if this view already exists
    if ([items containsObject:view]) {
        return;
    }
    
    //Create the config
    NSDictionary *config = @{
        @"flex" : [NSNumber numberWithInt:flex],
        @"margin": [NSValue valueWithCGRect:margin],
        @"frame": [NSValue valueWithCGRect:view.frame]
    };
    
    [items insertObject:view atIndex:index];
    [configs setObject:config forKey:[NSValue valueWithNonretainedObject:view]];
    [self addSubview:view];
    [self setNeedsLayout];
}

- (void)removeItem:(UIView *)view
{
    [view removeFromSuperview];
    [items removeObject:view];
    [configs removeObjectForKey:[NSValue valueWithNonretainedObject:view]];
    [self setNeedsLayout];
}

- (void)removeAll
{
    //Remove all views
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    //Clear the items and configs
    [items removeAllObjects];
    [configs removeAllObjects];
    [self setNeedsLayout];
}

//////////////////////////////////////////////////////////
//  Layout Methods
//////////////////////////////////////////////////////////
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    switch (type) {
        case UIFlexibleViewTypeHorizontal:
            if (animate == YES) {
                [UIView animateWithDuration:0.2f animations:^{
                    [self layoutHorizontal];
                }];
            } else {
                [self layoutHorizontal];
            }
            break;
            
        case UIFlexibleViewTypeVertical:
            if (animate == YES) {
                [UIView animateWithDuration:0.2f animations:^{
                    [self layoutVertical];
                }];
            } else {
                [self layoutVertical];
            }
            break;
        
        default:
            break;
    }
}

- (void)layoutHorizontal
{
    int itemCount = items.count;
    CGRect viewSize = self.frame;
    float availableWidth = viewSize.size.width;
    float flexWidth = availableWidth;
    float x = 0;
    float y = 0;
    int i = 0;
    int maxFlex = 0;
    int totalFlex = 0;
    int maxHeight = 0;
    int totalWidth = 0;
    
    //Compute all information about the items
    for (i = 0; i < itemCount; i++){
        //Get the item
        UIView *view = [items objectAtIndex:i];
        
        //Get the item config
        NSDictionary *config = [self getConfig:view];
        NSNumber *flexNumber = [config objectForKey:@"flex"];
        int flex = [flexNumber intValue];
        NSValue *marginValue = [config objectForKey:@"margin"];
        CGRect margin = [marginValue CGRectValue];
        NSValue *frameValue = [config objectForKey:@"frame"];
        CGRect frame = [frameValue CGRectValue];
        
        //Compute the max flex
        if(flex >= maxFlex){
            maxFlex = flex;
        }
        
        //Compute the flexwidth
        if(flex > 0){
            totalFlex = totalFlex + flex;
        }
        else{
            flexWidth -= frame.size.width;
            totalWidth += frame.size.width;
        }
        flexWidth -= (margin.origin.x + margin.size.width);
        availableWidth -= (margin.origin.x + margin.size.width);
        totalWidth += (margin.origin.x + margin.size.width);
        
        //Compute the maxheight
        if(frame.size.height > maxHeight){
            maxHeight = frame.size.height;
        }
    }
    
    //Determine if we need to pack the items
    if(totalFlex == 0 && totalWidth < availableWidth){
        if(self.pack == UIFlexibleViewPackCenter){
            x += (availableWidth - totalWidth) / 2;
        }
        if(self.pack == UIFlexibleViewPackEnd){
            x += (availableWidth - totalWidth);
        }
    }
    
    //Draw all the items in this view
    for (i = 0; i < itemCount; i++){
        //Get the view
        UIView *view = [items objectAtIndex:i];
        
        //Get the item config
        NSDictionary *config = [self getConfig:view];
        NSNumber *flexNumber = [config objectForKey:@"flex"];
        int flex = [flexNumber intValue];
        NSValue *marginValue = [config objectForKey:@"margin"];
        CGRect margin = [marginValue CGRectValue];
        NSValue *frameValue = [config objectForKey:@"frame"];
        CGRect frame = [frameValue CGRectValue];
        
        //Compute the x and y
        int itemX = x + margin.origin.x;
        int itemY = y + margin.origin.y;
        
        //Compute the item width
        int itemWidth = 0;
        if(flex > 0){
            float flexRatio = (flex / (float)totalFlex);
            itemWidth = (int)floor((flexWidth * flexRatio));
        }
        else{
            itemWidth = frame.size.width;
        }
        
        //Compute the item height
        int itemHeight = frame.size.height;
        if(self.align == UIFlexibleViewAlignStretch){
            itemHeight = self.bounds.size.height - margin.origin.y - margin.size.height;
        }
        if(self.align == UIFlexibleViewAlignStretchMax){
            itemHeight = maxHeight;
        }
        if(self.align == UIFlexibleViewAlignMiddle){
            itemY += (self.frame.size.height / 2) - (frame.size.height / 2);
        }
        
        //Create the frame for the item
        frame = CGRectMake(itemX, itemY, itemWidth, itemHeight);
        
        //Set the items frame
        [view setFrame:frame];
        
        //Reset the x and y
        x = itemX + itemWidth + margin.size.width;
    }
}

- (void)layoutVertical
{
    int itemCount = items.count;
    CGRect viewSize = self.frame;
    float availableHeight = viewSize.size.height;
    float flexHeight = availableHeight;
    float x = 0;
    float y = 0;
    int i = 0;
    int maxFlex = 0;
    int totalFlex = 0;
    int maxWidth = 0;
    int totalHeight = 0;
    
    //Compute all information about the items
    for (i = 0; i < itemCount; i++){
        //Get the item
        UIView *view = [items objectAtIndex:i];
        
        //Get the item config
        NSDictionary *config = [self getConfig:view];
        NSNumber *flexNumber = [config objectForKey:@"flex"];
        int flex = [flexNumber intValue];
        NSValue *marginValue = [config objectForKey:@"margin"];
        CGRect margin = [marginValue CGRectValue];
        NSValue *frameValue = [config objectForKey:@"frame"];
        CGRect frame = [frameValue CGRectValue];
        
        //Compute the max flex
        if(flex >= maxFlex){
            maxFlex = flex;
        }
        
        //Compute the flexwidth
        if(flex > 0){
            totalFlex = totalFlex + flex;
        }
        else{
            flexHeight -= frame.size.height;
            totalHeight += frame.size.height;
        }
        flexHeight -= (margin.origin.y + margin.size.height);
        availableHeight -= (margin.origin.y + margin.size.height);
        totalHeight += (margin.origin.y + margin.size.height);
        
        //Compute the maxwidth
        if(frame.size.width > maxWidth){
            maxWidth = frame.size.width;
        }
    }
    
    //Determine if we need to pack the items
    if(totalFlex == 0 && totalHeight < availableHeight){
        if(self.pack == UIFlexibleViewPackCenter){
            y += (availableHeight - totalHeight) / 2;
        }
        if(self.pack == UIFlexibleViewPackEnd){
            y += (availableHeight - totalHeight);
        }
    }
    
    //Draw all the items in this view
    for (i = 0; i < itemCount; i++){
        //Get the view
        UIView *view = [items objectAtIndex:i];
        
        //Get the item config
        NSDictionary *config = [self getConfig:view];
        NSNumber *flexNumber = [config objectForKey:@"flex"];
        int flex = [flexNumber intValue];
        NSValue *marginValue = [config objectForKey:@"margin"];
        CGRect margin = [marginValue CGRectValue];
        NSValue *frameValue = [config objectForKey:@"frame"];
        CGRect frame = [frameValue CGRectValue];
        
        //Compute the x and y
        int itemX = x + margin.origin.x;
        int itemY = y + margin.origin.y;
        
        //Compute the item height
        int itemHeight = 0;
        if(flex > 0){
            float flexRatio = (flex / (float)totalFlex);
            itemHeight = (int)floor((flexHeight * flexRatio));
        }
        else{
            itemHeight = frame.size.height;
        }
        
        //Compute the item width
        int itemWidth = frame.size.width;
        if(self.align == UIFlexibleViewAlignStretch){
            itemWidth = self.bounds.size.width - margin.origin.x - margin.size.width;
        }
        if(self.align == UIFlexibleViewAlignStretchMax){
            itemWidth = maxWidth;
        }
        if(self.align == UIFlexibleViewAlignMiddle){
            itemX += (self.frame.size.width / 2) - (frame.size.width / 2);
        }
        
        //Create the frame for the item
        frame = CGRectMake(itemX, itemY, itemWidth, itemHeight);
        
        //Set the items frame
        [view setFrame:frame];
        
        //Reset the x and y
        y = itemY + itemHeight + margin.size.height;
    }
}


@end
