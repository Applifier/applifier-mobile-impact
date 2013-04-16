//
//  ApplifierImpactNativeButton.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/16/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactNativeButton.h"
#import "../ApplifierImpact.h"

@interface ApplifierImpactNativeButton ()
  @property (nonatomic, strong) UIColor *strokeColor;
  @property (nonatomic, strong) NSArray *baseColors;
  @property (nonatomic, assign) UIRectCorner *cornerToRound;
  @property (nonatomic, assign) int cornerRadius;
@end

@implementation ApplifierImpactNativeButton

- (id)initWithFrame:(CGRect)frame andBaseColors:(NSArray *)baseColors strokeColor:(UIColor *)strokeColor {
  return [self initWithFrame:frame andBaseColors:baseColors strokeColor:strokeColor withCorner:nil];
}

- (id)initWithFrame:(CGRect)frame andBaseColors:(NSArray *)baseColors strokeColor:(UIColor *)strokeColor withCorner:(UIRectCorner)roundedCorner {
  return [self initWithFrame:frame andBaseColors:baseColors strokeColor:strokeColor withCorner:roundedCorner withCornerRadius:10];
}

- (id)initWithFrame:(CGRect)frame andBaseColors:(NSArray *)baseColors strokeColor:(UIColor *)strokeColor withCorner:(UIRectCorner)roundedCorner withCornerRadius:(int)cornerRadius {
    self = [super initWithFrame:frame];
    if (self) {
      self.strokeColor = strokeColor;
      self.baseColors = baseColors;
      self.cornerToRound = roundedCorner;
      self.cornerRadius = cornerRadius;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
  UIRectCorner *cornerToRound = UIRectCornerAllCorners;
  
  if (self.cornerToRound != nil)
    cornerToRound = self.cornerToRound;
  
  UIBezierPath *outerPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:cornerToRound cornerRadii:CGSizeMake(self.cornerRadius, self.cornerRadius)];
  [self.strokeColor setFill];
  [outerPath fill];
  
  UIBezierPath *innerPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(rect.origin.x + 2, rect.origin.y + 2, rect.size.width - 4, rect.size.height - 4) byRoundingCorners:cornerToRound cornerRadii:CGSizeMake(self.cornerRadius - 2, self.cornerRadius - 2)];
  
  
  UIColor *firstColor = [self.baseColors objectAtIndex:0];
  const CGFloat *firstColorComponents = CGColorGetComponents(firstColor.CGColor);

  UIColor *secondColor = [self.baseColors objectAtIndex:1];
  const CGFloat *secondColorComponents = CGColorGetComponents(secondColor.CGColor);
  
  CGFloat colors [] = {
    firstColorComponents[0], firstColorComponents[1], firstColorComponents[2], 1.0,
    secondColorComponents[0], secondColorComponents[1], secondColorComponents[2], 1.0
  };

  CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
  CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
  CGColorSpaceRelease(baseSpace), baseSpace = NULL;
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGContextSaveGState(context);
  CGContextAddPath(context, [innerPath CGPath]);
  CGContextClip(context);
  
  CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
  CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
  
  CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
  CGGradientRelease(gradient), gradient = NULL;
  
  [super drawRect:rect];
}

@end
