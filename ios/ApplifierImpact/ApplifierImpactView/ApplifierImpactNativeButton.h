//
//  ApplifierImpactNativeButton.h
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/16/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApplifierImpactNativeButton : UIButton
- (id)initWithFrame:(CGRect)frame andBaseColors:(NSArray *)baseColors strokeColor:(UIColor *)strokeColor;
- (id)initWithFrame:(CGRect)frame andBaseColors:(NSArray *)baseColors strokeColor:(UIColor *)strokeColor withCorner:(UIRectCorner)roundedCorner;
- (id)initWithFrame:(CGRect)frame andBaseColors:(NSArray *)baseColors strokeColor:(UIColor *)strokeColor withCorner:(UIRectCorner)roundedCorner withCornerRadius:(int)cornerRadius;
- (id)initWithFrame:(CGRect)frame andBaseColors:(NSArray *)baseColors strokeColor:(UIColor *)strokeColor withCorner:(UIRectCorner)roundedCorner withCornerRadius:(int)cornerRadius withIcon:(UIView *)iconView;
- (void)destroyView;
@end
