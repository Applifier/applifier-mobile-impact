//
//  ApplifierImpactVideoMuteButton.m
//  ApplifierImpact
//
//  Created by Matti Savolainen on 5/3/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactVideoMuteButton.h"

@implementation ApplifierImpactVideoMuteButton


@synthesize fullWidth;
@synthesize iconWidth;
@synthesize alwaysFullSize;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame icon:(UIImage *)img title:(NSString *)title {
  self = [super initWithFrame:frame];
  if (self) {
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    [self setImage:img forState:UIControlStateNormal];
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize: 12];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.adjustsFontSizeToFitWidth = NO;
    
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    self.fullWidth = frame.size.width;
    self.iconWidth = img.size.width;
    
    //Debug color
    //[self setBackgroundColor:[UIColor redColor]];
  }
  return self;
}

- (id)initWithIcon:(UIImage *)img title:(NSString *)title {
  self = [self initWithFrame:CGRectMake(0, 0, 64, 64) icon:img title:title];
  
  return self;
}

- (void) showButton {
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:1.0];
  [self setAlpha:1.0f];
  [UIView commitAnimations];
}

- (void) hideButton {
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:1.0];
  [self setAlpha:0.0f];
  [UIView commitAnimations];
}

- (void) hideButtonAfter:(CGFloat)seconds {
  [self performSelector:@selector(hideButton) withObject:nil afterDelay:seconds];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
