//
//  ApplifierImpactImageViewRoundedCorners.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/18/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactImageViewRoundedCorners.h"
#import "../ApplifierImpact.h"

@interface ApplifierImpactImageViewRoundedCorners ()
  @property (nonatomic, strong) NSURLConnection* connection;
  @property (nonatomic, strong) NSMutableData* data;
  @property (nonatomic, strong) UIImage *roundedImage;
@end

@implementation ApplifierImpactImageViewRoundedCorners

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      [self setBackgroundColor:[UIColor clearColor]];
      self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
  AILOG_DEBUG(@"");
  
  UIBezierPath *clipPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(12, 12)];
  
  UIColor *firstColor = [UIColor blueColor];
  const CGFloat *firstColorComponents = CGColorGetComponents(firstColor.CGColor);
  
  CGFloat colors [] = {
    firstColorComponents[0] + 0.3f, firstColorComponents[1] + 0.8f, firstColorComponents[2] + 0.8f, 1.0,
    firstColorComponents[0], firstColorComponents[1] , firstColorComponents[2] + 0.2, 1.0
  };
  
  CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
  CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
  CGColorSpaceRelease(baseSpace), baseSpace = NULL;
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGContextSaveGState(context);
  CGContextAddPath(context, [clipPath CGPath]);
  CGContextClip(context);
  
  CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
  CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
  
  CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
  CGGradientRelease(gradient), gradient = NULL;
  
  if (self.roundedImage != nil) {
    [self.roundedImage drawInRect:rect];
  }
}

- (void)loadImageFromURL:(NSURL*)url {
  NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
  self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
  AILOG_DEBUG(@"");
  
  if (self.data == nil) {
    self.data = [[NSMutableData alloc] initWithCapacity:2048];
  }
  
  [self.data appendData:incrementalData];
}


- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
  AILOG_DEBUG(@"");
  self.connection = nil;
  self.roundedImage = [UIImage imageWithData:self.data];
  [self setNeedsDisplay];
  self.data = nil;
}

@end
