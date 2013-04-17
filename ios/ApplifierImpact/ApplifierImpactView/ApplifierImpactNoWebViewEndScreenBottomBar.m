//
//  ApplifierImpactNoWebViewEndScreenBottomBar.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/17/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactNoWebViewEndScreenBottomBar.h"

@implementation ApplifierImpactNoWebViewEndScreenBottomBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
  UIColor *firstColor = [UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:1];
  const CGFloat *firstColorComponents = CGColorGetComponents(firstColor.CGColor);
  
  UIColor *secondColor = [UIColor colorWithRed:0.1802f green:0.1802f blue:0.1802f alpha:1];
  const CGFloat *secondColorComponents = CGColorGetComponents(secondColor.CGColor);
  
  CGFloat colors [] = {
    firstColorComponents[0], firstColorComponents[1], firstColorComponents[2], 1.0,
    secondColorComponents[0], secondColorComponents[1], secondColorComponents[2], 1.0
  };
  
  CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
  CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
  CGColorSpaceRelease(baseSpace), baseSpace = NULL;
  
  CGContextRef context = UIGraphicsGetCurrentContext();

  int bottomBarWidth = rect.size.height;
  if (rect.size.width > bottomBarWidth)
    bottomBarWidth = rect.size.width;
  
  bottomBarWidth += 40;
  
  CGContextSaveGState(context);
  CGContextAddRect(context, rect);
  CGContextClip(context);
  
  CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
  CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
  
  CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
  CGGradientRelease(gradient), gradient = NULL;
}

@end
