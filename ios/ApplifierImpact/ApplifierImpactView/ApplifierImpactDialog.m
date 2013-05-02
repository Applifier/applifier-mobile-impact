//
//  ApplifierImpactDialog.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/15/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactDialog.h"
#import "ApplifierImpactNativeSpinner.h"
#import "../ApplifierImpact.h"
#import "../ApplifierImpactDevice/ApplifierImpactDevice.h"

@interface ApplifierImpactDialog ()
  @property (nonatomic, assign) BOOL useSpinner;
  @property (nonatomic, assign) BOOL useButton;
  @property (nonatomic, assign) BOOL useLabel;
@end

@implementation ApplifierImpactDialog

- (id)initWithFrame:(CGRect)frame useSpinner:(BOOL)createSpinner useLabel:(BOOL)createLabel useButton:(BOOL)createButton {
    self = [super initWithFrame:frame];
    if (self) {
      self.useSpinner = createSpinner;
      self.useLabel = createLabel;
      self.useButton = createButton;
      [self createView];
    }
  
    return self;
}

- (void)createView {
  AILOG_DEBUG(@"");
  
  if (self.useSpinner) {
    int spinnerSize = 47;
    self.spinner = [[ApplifierImpactNativeSpinner alloc] initWithFrame:CGRectMake(12, (self.frame.size.height / 2) - (spinnerSize / 2), spinnerSize, spinnerSize)];
    [self addSubview:self.spinner];
    [self bringSubviewToFront:self.spinner];
    
    if (![ApplifierImpactDevice isSimulator]) {
      [self startSpin];
    }
  }
  if (self.useLabel) {
    CGRect rect = CGRectMake(9, 9, self.frame.size.width - 18, self.frame.size.height - 18);
    
    if (self.useButton) {
      rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height - 29);
    }
    else if (self.useSpinner) {
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
  if (self.useButton) {
    int buttonWidth = 110;
    int buttonHeight = 25;
    
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    [[UIColor greenColor] getRed:&red green:&green blue:&blue alpha:&alpha];
    UIColor *myColor = [UIColor colorWithRed:red / 2 green:green / 2 blue:blue / 2 alpha:alpha];
    NSArray *gradientArray = [[NSArray alloc] initWithObjects:[UIColor greenColor], myColor, nil];
    
    self.button = [[ApplifierImpactNativeButton alloc] initWithFrame:CGRectMake((self.frame.size.width / 2) - (buttonWidth / 2), self.frame.size.height - buttonHeight - 9, buttonWidth, buttonHeight) andBaseColors:gradientArray strokeColor:[UIColor greenColor]];
    [self.button setTitle:@"OK" forState:UIControlStateNormal];
    [self addSubview:self.button];
  }
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
  dispatch_async(dispatch_get_main_queue(), ^{
    if (!self.animating) {
      self.animating = YES;
      [self spinWithOptions: UIViewAnimationOptionCurveEaseIn];
    }
  });
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
