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

- (id)initWithFrame:(CGRect)frame useSpinner:(BOOL)createSpinner useLabel:(BOOL)createLabel useButton:(BOOL)createButton {
    self = [super initWithFrame:frame];
    if (self) {
      if (createSpinner) {
        int spinnerSize = 47;
        self.spinner = [[ApplifierImpactNativeSpinner alloc] initWithFrame:CGRectMake(12, (frame.size.height / 2) - (spinnerSize / 2), spinnerSize, spinnerSize)];
        [self addSubview:self.spinner];
        [self bringSubviewToFront:self.spinner];
        [self startSpin];
      }
      if (createLabel) {
        CGRect rect = CGRectMake(9, 9, frame.size.width - 18, frame.size.height - 18);
        
        if (createButton) {
          rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height - 29);
        }
        else if (createSpinner) {
          rect = CGRectMake(rect.origin.x + 51, rect.origin.y, rect.size.width - 51, rect.size.height);
        }
        
        self.label = [[UILabel alloc] initWithFrame:rect];
        [self.label setBackgroundColor:[UIColor clearColor]];
        [self.label setTextColor:[UIColor whiteColor]];
        [self.label setUserInteractionEnabled:false];
        [self.label setTextAlignment:NSTextAlignmentCenter];
        [self.label setNumberOfLines:2];
        [self.label setText:@"Buffering..."];
        [self addSubview:self.label];
      }
      if (createButton) {
        int buttonWidth = 110;
        int buttonHeight = 25;
        
        CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
        [[UIColor greenColor] getRed:&red green:&green blue:&blue alpha:&alpha];
        UIColor *myColor = [UIColor colorWithRed:red / 2 green:green / 2 blue:blue / 2 alpha:alpha];
        NSArray *gradientArray = [[NSArray alloc] initWithObjects:[UIColor greenColor], myColor, nil];
        
        self.button = [[ApplifierImpactNativeButton alloc] initWithFrame:CGRectMake((frame.size.width / 2) - (buttonWidth / 2), frame.size.height - buttonHeight - 9, buttonWidth, buttonHeight) andBaseColors:gradientArray strokeColor:[UIColor greenColor]];
        [self.button setTitle:@"OK" forState:UIControlStateNormal];
        [self addSubview:self.button];
      }
    }
  
    return self;
}

- (void)spinWithOptions: (UIViewAnimationOptions) options {
  [UIView animateWithDuration: 0.5f
                        delay: 0.0f
                      options: options
                   animations: ^{
                     self.spinner.transform = CGAffineTransformRotate(self.spinner.transform, M_PI / 2);
                   }
                   completion: ^(BOOL finished) {
                     if (finished) {
                       if (self.animating) {
                         [self spinWithOptions: UIViewAnimationOptionCurveLinear];
                       } else if (options != UIViewAnimationOptionCurveEaseOut) {
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
  self.animating = NO;
}

- (void)destroyView {
  [super destroyView];

  if (self.spinner != nil) {
    if (self.spinner.superview != nil) {
      [self.spinner removeFromSuperview];
    }
    self.spinner = nil;
  }
  
  if (self.label != nil) {
    if (self.label.superview != nil) {
      [self.label removeFromSuperview];
    }
    [self.label setText:@""];
    self.label = nil;
  }
  
  if (self.button != nil) {
    if (self.button.superview != nil) {
      [self.button removeFromSuperview];
    }
    [self.button.titleLabel setText:@""];
    [self.button destroyView];
    self.button = nil;
  }
}

@end
