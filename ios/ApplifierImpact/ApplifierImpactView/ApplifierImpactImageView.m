//
//  ApplifierImpactImageView.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/17/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactImageView.h"
#import "../ApplifierImpact.h"

@interface ApplifierImpactImageView ()
  @property (nonatomic, strong) NSURLConnection* connection;
  @property (nonatomic, strong) NSMutableData* data;
  @property (nonatomic, assign) BOOL runScaling;
@end

@implementation ApplifierImpactImageView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
      self.runScaling = true;
    }
    return self;
}

- (void)loadImageFromURL:(NSURL*)url applyScaling:(BOOL)runScaling {
  self.runScaling = runScaling;
  self.connection = nil;
  self.data = nil;
  
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
  [self setImage:[UIImage imageWithData:self.data]];
  
  if (self.runScaling) {
    self.center = self.window.center;
    
    UIViewContentMode mode = UIViewContentModeScaleAspectFill;
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
      mode = UIViewContentModeScaleAspectFit;
    }
    
    self.contentMode = mode;
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    float viewAspect = self.superview.bounds.size.width / self.superview.bounds.size.height;
    float imageAspect = self.image.size.width / self.image.size.height;
    
    float scaleFactor = 1;
    
    if (viewAspect < imageAspect) {
      scaleFactor = self.superview.bounds.size.height / self.image.size.height;
    }
    else {
      scaleFactor = self.superview.bounds.size.width / self.image.size.width;
    }
    
    CGRect rect = CGRectMake(0, 0, self.image.size.width * scaleFactor, self.image.size.height * scaleFactor);
    CGRect newPos = CGRectMake((self.superview.bounds.size.width / 2) - (rect.size.width / 2), (self.superview.bounds.size.height / 2) - (rect.size.height / 2), rect.size.width, rect.size.height);
    
    [self setFrame:newPos];
    [self setNeedsLayout];
  }

  self.data = nil;
}

@end
