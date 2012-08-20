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
@synthesize margin;
@synthesize padding;

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
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    padding = CGRectMake(0, 0, 0, 0);
}


//////////////////////////////////////////////////////////
//  Statics
//////////////////////////////////////////////////////////
+ (CGRect)processRectString:(NSString *)rectString
{
    CGRect rect = CGRectMake(0, 0, 0, 0);
    NSArray *rectParts = [rectString componentsSeparatedByString:@" "];
    int numParts = [rectParts count];
    int top = [[rectParts objectAtIndex:0] intValue];
    int right = 0;
    int bottom = 0;
    int left = 0;
    switch (numParts) {
        case 1:
            right = bottom = left = top;
            break;
        case 2:
            bottom = top;
            right = left = [[rectParts objectAtIndex:1] intValue];
            break;
        case 3:
            right = left = [[rectParts objectAtIndex:1] intValue];
            bottom = [[rectParts objectAtIndex:2] intValue];
            break;
        case 4:
            right = [[rectParts objectAtIndex:1] intValue];
            bottom = [[rectParts objectAtIndex:2] intValue];
            left = [[rectParts objectAtIndex:3] intValue];
            break;
    }
    
    rect = CGRectMake(left, top, right, bottom);
    NSLog(@"%@", [NSValue valueWithCGRect:rect]);
    return rect;
}

//////////////////////////////////////////////////////////
//  Mutators
//////////////////////////////////////////////////////////
- (void)setTypeFromString:(NSString *)typeName
{
    if ([typeName isEqualToString:@"hbox"]) {
        [self setType:UIFlexibleViewTypeHorizontal];
    }
    if ([typeName isEqualToString:@"vbox"]) {
        [self setType:UIFlexibleViewTypeVertical];
    }
}

- (void)setType:(UIFlexibleViewType)newType
{
    if (type == newType) {
        return;
    }
    type = newType;
    [self setNeedsLayout];
}

- (void)setAlignFromString:(NSString *)alignString
{
    if ([alignString isEqualToString:@"top"]) {
        [self setAlign:UIFlexibleViewAlignTop];
    }
    if ([alignString isEqualToString:@"middle"]) {
        [self setAlign:UIFlexibleViewAlignMiddle];
    }
    if ([alignString isEqualToString:@"stretch"]) {
        [self setAlign:UIFlexibleViewAlignStretch];
    }
    if ([alignString isEqualToString:@"stretchmax"]) {
        [self setAlign:UIFlexibleViewAlignStretchMax];
    }
}

- (void)setAlign:(UIFlexibleViewAlign)newAlign
{
    if (align == newAlign) {
        return;
    }
    align = newAlign;
    [self setNeedsLayout];
}

- (void)setPackFromString:(NSString *)packString
{
    if ([packString isEqualToString:@"start"]) {
        [self setPack:UIFlexibleViewPackStart];
    }
    if ([packString isEqualToString:@"center"]) {
        [self setPack:UIFlexibleViewPackCenter];
    }
    if ([packString isEqualToString:@"end"]) {
        [self setPack:UIFlexibleViewPackEnd];
    }
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

- (void)setPadding:(CGRect)newPadding
{
    padding = newPadding;
    [self layoutSubviews];
}

- (void)setPaddingFromString:(NSString *)paddingString
{
    [self setPadding:[UIFlexibleView processRectString:paddingString]];
}

//////////////////////////////////////////////////////////
//  Methods
//////////////////////////////////////////////////////////
- (void)sizeToFit
{
    CGRect frame = self.frame;
    float width = [self getTotalWidth];
    float height = [self getTotalHeight];
    if (type == UIFlexibleViewTypeHorizontal) {
        if (width > self.bounds.size.width) {
            frame.size.width = width;
        }
    }
    if (type == UIFlexibleViewTypeVertical) {
        if (height > self.bounds.size.height) {
            frame.size.height = height;
        }
    }
    [self setFrame:frame];
}

- (NSArray *)getVisibleItems
{
    NSMutableArray *visibleItems = [[NSMutableArray alloc] init];
    for (UIView *view in items) {
        if (view.hidden == YES) {
            continue;
        }
        [visibleItems addObject:view];
    }
    return visibleItems;
}

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
- (void)addItem:(UIView *)view withFlex:(int)flex andMargin:(CGRect)viewMargin
{
    [self addItem:view withFlex:flex andMargin:viewMargin atIndex:items.count];
}

- (void)addItem:(UIView *)view withFlex:(int)flex andMargin:(CGRect)viewMargin replaceItem:(UIView *)replaceView
{
    //Make sure the view we are replacing exists
    if ([items containsObject:replaceView] == NO) {
        return;
    }
    
    //Get the index of the item we are replacing
    int index = [items indexOfObject:replaceView];
    [self addItem:view withFlex:flex andMargin:viewMargin atIndex:index];
    [self removeItem:replaceView];
}

- (void)addItem:(UIView *)view withFlex:(int)flex andMargin:(CGRect)viewMargin atIndex:(int)index
{
    //Do not add if this view already exists
    if ([items containsObject:view]) {
        return;
    }
    
    //Let this view handle the resizing
    [view setAutoresizingMask:0];
    
    //Create the config
    NSDictionary *config = @{
        @"flex" : [NSNumber numberWithInt:flex],
        @"margin": [NSValue valueWithCGRect:viewMargin],
        @"frame": [NSValue valueWithCGRect:view.frame]
    };
    
    [items insertObject:view atIndex:index];
    [configs setObject:config forKey:[NSValue valueWithNonretainedObject:view]];
    [self addSubview:view];
    [self layoutSubviews];
}

- (void)removeItem:(UIView *)view
{
    [view removeFromSuperview];
    [items removeObject:view];
    [configs removeObjectForKey:[NSValue valueWithNonretainedObject:view]];
    [self layoutSubviews];
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
    [self layoutSubviews];
}

- (float)getTotalHeight
{
    float height = padding.origin.y + padding.size.height;
    for (UIView *view in [self getVisibleItems]) {
        NSDictionary *config = [self getConfig:view];
        NSValue *marginValue = [config objectForKey:@"margin"];
        CGRect viewMargin = [marginValue CGRectValue];
        height += view.frame.size.height + viewMargin.origin.y + viewMargin.size.height;
    }
    return height;
}

- (float)getTotalWidth
{
    float width = padding.origin.x + padding.size.width;
    for (UIView *view in [self getVisibleItems]) {
        NSDictionary *config = [self getConfig:view];
        NSValue *marginValue = [config objectForKey:@"margin"];
        CGRect viewMargin = [marginValue CGRectValue];
        width += view.frame.size.width + viewMargin.origin.x + viewMargin.size.width;
    }
    return width;
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
    
    [self sizeToFit];
}

- (void)layoutHorizontal
{
    NSArray *views = [self getVisibleItems];
    int itemCount = views.count;
    CGRect viewSize = self.bounds;
    float availableWidth = viewSize.size.width - (padding.origin.x + padding.size.width);
    float flexWidth = availableWidth;
    float x = padding.origin.x;
    float y = padding.origin.y;
    int i = 0;
    int maxFlex = 0;
    int totalFlex = 0;
    int maxHeight = 0;
    int totalWidth = 0;
    
    //Compute all information about the items
    for (i = 0; i < itemCount; i++){
        //Get the item
        UIView *view = [views objectAtIndex:i];
        
        //Get the item config
        NSDictionary *config = [self getConfig:view];
        NSNumber *flexNumber = [config objectForKey:@"flex"];
        int flex = [flexNumber intValue];
        NSValue *marginValue = [config objectForKey:@"margin"];
        CGRect viewMargin = [marginValue CGRectValue];
        NSValue *frameValue = [config objectForKey:@"frame"];
        CGRect frame = [frameValue CGRectValue];
        //frame = view.frame;
        
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
        flexWidth -= (viewMargin.origin.x + viewMargin.size.width);
        availableWidth -= (viewMargin.origin.x + viewMargin.size.width);
        totalWidth += (viewMargin.origin.x + viewMargin.size.width);
        
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
        UIView *view = [views objectAtIndex:i];
        
        //Get the item config
        NSDictionary *config = [self getConfig:view];
        NSNumber *flexNumber = [config objectForKey:@"flex"];
        int flex = [flexNumber intValue];
        NSValue *marginValue = [config objectForKey:@"margin"];
        CGRect viewMargin = [marginValue CGRectValue];
        NSValue *frameValue = [config objectForKey:@"frame"];
        CGRect frame = [frameValue CGRectValue];
        //frame = view.frame;
        
        //Compute the x and y
        float itemX = x + viewMargin.origin.x;
        float itemY = y + viewMargin.origin.y;
        
        //Compute the item width
        float itemWidth = 0.0f;
        if(flex > 0){
            float flexRatio = (flex / (float)totalFlex);
            itemWidth = ((flexWidth * flexRatio));
        }
        else{
            itemWidth = frame.size.width;
        }
        
        //Compute the item height
        float itemHeight = frame.size.height;
        if(self.align == UIFlexibleViewAlignStretch){
            itemHeight = self.bounds.size.height - padding.origin.y - padding.size.height - viewMargin.origin.y - viewMargin.size.height;
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
        x = itemX + itemWidth + viewMargin.size.width;
    }
    
    //If there is no height use the maxHeight
    if (self.frame.size.height < maxHeight) {
        CGRect selfFrame = self.frame;
        selfFrame.size.height = maxHeight + padding.origin.y + padding.size.height;
        [self setFrame:selfFrame];
        [self.superview layoutSubviews];
    }
}

- (void)layoutVertical
{
    NSArray *views = [self getVisibleItems];
    int itemCount = views.count;
    CGRect viewSize = self.bounds;
    float availableHeight = viewSize.size.height - (padding.origin.y + padding.size.height);
    float flexHeight = availableHeight;
    float x = padding.origin.x;
    float y = padding.origin.y;
    int i = 0;
    int maxFlex = 0;
    int totalFlex = 0;
    int maxWidth = 0;
    int totalHeight = 0;
    
    //Compute all information about the items
    for (i = 0; i < itemCount; i++){
        //Get the item
        UIView *view = [views objectAtIndex:i];
        
        //Get the item config
        NSDictionary *config = [self getConfig:view];
        NSNumber *flexNumber = [config objectForKey:@"flex"];
        int flex = [flexNumber intValue];
        NSValue *marginValue = [config objectForKey:@"margin"];
        CGRect viewMargin = [marginValue CGRectValue];
        NSValue *frameValue = [config objectForKey:@"frame"];
        CGRect frame = [frameValue CGRectValue];
        //frame = view.frame;
        
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
        flexHeight -= (viewMargin.origin.y + viewMargin.size.height);
        availableHeight -= (viewMargin.origin.y + viewMargin.size.height);
        totalHeight += (viewMargin.origin.y + viewMargin.size.height);
        
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
        UIView *view = [views objectAtIndex:i];
        
        //Get the item config
        NSDictionary *config = [self getConfig:view];
        NSNumber *flexNumber = [config objectForKey:@"flex"];
        int flex = [flexNumber intValue];
        NSValue *marginValue = [config objectForKey:@"margin"];
        CGRect viewMargin = [marginValue CGRectValue];
        NSValue *frameValue = [config objectForKey:@"frame"];
        CGRect frame = [frameValue CGRectValue];
        //frame = view.frame;
        
        //Compute the x and y
        float itemX = x + viewMargin.origin.x;
        float itemY = y + viewMargin.origin.y;
        
        //Compute the item height
        float itemHeight = 0.0f;
        if(flex > 0){
            float flexRatio = (flex / (float)totalFlex);
            itemHeight = ((flexHeight * flexRatio));
        }
        else{
            itemHeight = frame.size.height;
        }
        
        //Compute the item width
        int itemWidth = frame.size.width;
        if(self.align == UIFlexibleViewAlignStretch){
            itemWidth = self.bounds.size.width - padding.origin.x - padding.size.width - viewMargin.origin.x - viewMargin.size.width;
        }
        if(self.align == UIFlexibleViewAlignStretchMax){
            itemWidth = maxWidth;
        }
        if(self.align == UIFlexibleViewAlignMiddle){
            itemX += ((self.frame.size.width - padding.origin.x - padding.size.width) / 2) - (frame.size.width / 2);
        }
        
        //Create the frame for the item
        frame = CGRectMake(itemX, itemY, itemWidth, itemHeight);
        
        //Set the items frame
        [view setFrame:frame];
        
        //Reset the x and y
        y = itemY + itemHeight + viewMargin.size.height;
    }
}


@end
