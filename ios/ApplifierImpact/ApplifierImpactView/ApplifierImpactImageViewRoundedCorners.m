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
  @property (nonatomic, assign) BOOL retriedPictureDownload;
@end

@implementation ApplifierImpactImageViewRoundedCorners

@synthesize data = _data;
@synthesize connection = _connection;
@synthesize roundedImage = _roundedImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      [self setBackgroundColor:[UIColor clearColor]];
      self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (void) dealloc {
  if(self.connection != nil) {
    [self.connection cancel];
    self.connection = nil;
  }
  if(self.data != nil) {
    self.data = nil;
  }
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


#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  AILOG_DEBUG(@"");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  AILOG_DEBUG(@"");
  
  if (self.data == nil) {
    self.data = [[NSMutableData alloc] initWithCapacity:2048];
  }
  
  [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  AILOG_DEBUG(@"");
  self.connection = nil;
  self.roundedImage = [UIImage imageWithData:self.data];
  [self setNeedsDisplay];
  self.data = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  if (!self.retriedPictureDownload) {
    self.retriedPictureDownload = true;
    
    if (connection != nil) {
      [self loadImageFromURL:connection.originalRequest.URL];
    }
  }
}


- (void)destroyView {
  self.connection = nil;
  self.data = nil;
  self.roundedImage = nil;
}
@end
