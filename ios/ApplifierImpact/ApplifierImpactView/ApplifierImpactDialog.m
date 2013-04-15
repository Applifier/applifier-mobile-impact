//
//  ApplifierImpactDialog.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/15/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactDialog.h"
#import "ApplifierImpactNativeSpinner.h"

@implementation ApplifierImpactDialog

- (id)initWithFrame:(CGRect)frame useSpinner:(BOOL)createSpinner {
    self = [super initWithFrame:frame];
    if (self) {
      if (createSpinner) {
        self.spinner = [[ApplifierImpactNativeSpinner alloc] initWithFrame:CGRectMake(12, 12, 47, 47)];
        [self addSubview:self.spinner];
        [self bringSubviewToFront:self.spinner];
        [self startSpin];
      }
    }
    return self;
}

- (void)spinWithOptions: (UIViewAnimationOptions) options {
  // this spin completes 360 degrees every 2 seconds
  [UIView animateWithDuration: 0.5f
                        delay: 0.0f
                      options: options
                   animations: ^{
                     self.spinner.transform = CGAffineTransformRotate(self.spinner.transform, M_PI / 2);
                   }
                   completion: ^(BOOL finished) {
                     if (finished) {
                       if (self.animating) {
                         // if flag still set, keep spinning with constant speed
                         [self spinWithOptions: UIViewAnimationOptionCurveLinear];
                       } else if (options != UIViewAnimationOptionCurveEaseOut) {
                         // one last spin, with deceleration
                         [self spinWithOptions: UIViewAnimationOptionCurveEaseOut];
                       }
                     }
                   }];
}

- (void)startSpin {
  if (!self.animating) {
    self.animating = YES;
    [self spinWithOptions: UIViewAnimationOptionCurveEaseIn];
  }
}

- (void)stopSpin {
  // set the flag to stop spinning after one last 90 degree increment
  self.animating = NO;
}

@end
