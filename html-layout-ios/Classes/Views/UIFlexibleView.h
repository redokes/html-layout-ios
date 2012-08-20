//
//  UIFlexibleView.h
//  fireplug-ios
//
//  Created by Jared Lewis on 8/16/12.
//  Copyright (c) 2012 Akimbo. All rights reserved.
//

#import <UIKit/UIKit.h>

//Classes Needed


//Align Enum
enum {
    UIFlexibleViewAlignTop = 0,
    UIFlexibleViewAlignMiddle = 1,
    UIFlexibleViewAlignStretch = 2,
    UIFlexibleViewAlignStretchMax = 3
};
typedef NSUInteger UIFlexibleViewAlign;

//Pack Enum
enum {
    UIFlexibleViewPackStart = 0,
    UIFlexibleViewPackCenter = 1,
    UIFlexibleViewPackEnd = 2
};
typedef NSUInteger UIFlexibleViewPack;


//Type Enum
enum {
    UIFlexibleViewTypeHorizontal = 0,
    UIFlexibleViewTypeVertical = 1
};
typedef NSUInteger UIFlexibleViewType;

//Interface
@interface UIFlexibleView : UIView

//Properties
@property (nonatomic) UIFlexibleViewType type;
@property (nonatomic) UIFlexibleViewAlign align;
@property (nonatomic) UIFlexibleViewPack pack;
@property (nonatomic) BOOL animate;
@property (nonatomic) NSMutableArray *items;
@property (nonatomic, readonly) NSMutableDictionary *configs;
@property (nonatomic) CGRect padding;
@property (nonatomic) CGRect margin;

//Methods
- (void)initComponent;
- (NSDictionary *)getDefaultConfig;
- (NSDictionary *)getConfig:(UIView *)view;
- (void)setConfig:(NSDictionary *)config forItem:(UIView *)view;
- (void)addItem:(UIView *)view;
- (void)addItem:(UIView *)view withFlex:(int)flex;
- (void)addItem:(UIView *)view withFlex:(int)flex andMargin:(CGRect)margin;
- (void)addItem:(UIView *)view withFlex:(int)flex andMargin:(CGRect)margin atIndex:(int)index;
- (void)addItem:(UIView *)view withFlex:(int)flex andMargin:(CGRect)margin replaceItem:(UIView *)replaceView;
- (void)removeItem:(UIView *)view;
- (void)removeAll;
- (float)getTotalHeight;
- (float)getTotalWidth;

- (void)setTypeFromString:(NSString *)typeName;
- (void)setType:(UIFlexibleViewType)newType;
- (void)setAlignFromString:(NSString *)alignString;
- (void)setAlign:(UIFlexibleViewAlign)newAlign;
- (void)setPackFromString:(NSString *)packString;
- (void)setPack:(UIFlexibleViewPack)newPack;
- (void)setPaddingFromString:(NSString *)paddingString;

//Static methods
+ (CGRect)processRectString:(NSString *)rectString;

@end
