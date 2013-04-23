//
//  ApplifierImpactNativeSpinner.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/15/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactNativeSpinner.h"
#import "../ApplifierImpact.h"

@implementation ApplifierImpactNativeSpinner

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
      [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
  AILOG_DEBUG(@"");
  CGRect allRect = self.bounds;
  CGRect circleRect = CGRectInset(allRect, 2.0f, 2.0f);
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  // Draw background
  CGContextSetRGBStrokeColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
  CGContextSetLineWidth(context, 3);
  CGContextStrokeEllipseInRect(context, circleRect);
  
  CGPoint center = CGPointMake(allRect.size.width / 2, allRect.size.height / 2);
  CGFloat radius = (allRect.size.width - 4) / 2;
  CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
  CGFloat endAngle = (0.2 * 2 * (float)M_PI) + startAngle;
  CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f); // white
  CGContextMoveToPoint(context, center.x, center.y);
  CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
  CGContextClosePath(context);
  CGContextFillPath(context);
}

- (void)destroyView {
}

@end
