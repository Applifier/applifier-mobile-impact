//
//  ApplifierImpactVideoMuteButton.h
//  ApplifierImpact
//
//  Created by Matti Savolainen on 5/3/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface ApplifierImpactVideoMuteButton : UIButton

@property CGFloat fullWidth;
@property CGFloat iconWidth;
@property BOOL alwaysFullSize;

- (id)initWithFrame:(CGRect)frame icon:(UIImage *)img title:(NSString *)title;
- (id)initWithIcon:(UIImage *)img title:(NSString *)title;
- (void) hideButtonAfter:(CGFloat)seconds;
- (void)showButton;
- (void)hideButton;
@end
