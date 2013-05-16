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
  @property (nonatomic, assign) BOOL retriedPictureDownload;
@end

@implementation ApplifierImpactImageView

@synthesize data = _data;
@synthesize connection = _connection;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
      self.runScaling = true;
      self.retriedPictureDownload = false;
    }
    return self;
}

- (void)dealloc {
  if(self.connection != nil) {
    [self.connection cancel];
    self.connection = nil;
  }
  if(self.data != nil) {
    self.data = nil;
  }
  AILOG_DEBUG(@"dealloc");
}

- (void)loadImageFromURL:(NSURL*)url applyScaling:(BOOL)runScaling {
  self.runScaling = runScaling;
  self.connection = nil;
  self.data = nil;
  
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
  [self setImage:[UIImage imageWithData:self.data]];
  
  if (self.runScaling) {
    self.center = self.window.center;
    
    float viewAspect = self.superview.bounds.size.width / self.superview.bounds.size.height;
    float imageAspect = self.image.size.width / self.image.size.height;
    float scaleFactor = 1;
    
    UIViewContentMode mode = UIViewContentModeScaleAspectFill;
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) && imageAspect > 1) {
      mode = UIViewContentModeScaleAspectFit;
    }
    else if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) && imageAspect < 1) {
      mode = UIViewContentModeScaleAspectFit;
    }
    
    self.contentMode = mode;
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    if (viewAspect < imageAspect) {
      scaleFactor = self.superview.bounds.size.height / self.image.size.height;
    }
    else {
      scaleFactor = self.superview.bounds.size.width / self.image.size.width;
    }
    
    CGRect rect = CGRectMake(0, 0, self.image.size.width * scaleFactor, self.image.size.height * scaleFactor);
    CGRect newPos = CGRectMake((self.superview.bounds.size.width / 2) - (rect.size.width / 2), (self.superview.bounds.size.height / 2) - (rect.size.height / 2) - 58, rect.size.width, rect.size.height);
    
    //[self setTransform:CGAffineTransformMakeTranslation(0, -(109 / 2))];
    
    [self setFrame:newPos];
    [self setNeedsLayout];
  }
  
  self.data = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  if (!self.retriedPictureDownload) {
    self.retriedPictureDownload = true;
    
    if (connection != nil) {
      [self loadImageFromURL:connection.originalRequest.URL applyScaling:self.runScaling];
    }
  }
}


#pragma mark - View destruction

- (void)destroyView {
  self.connection = nil;
  self.data = nil;
  self.runScaling = false;
}

@end
