//
//  ApplifierImpactDialog.h
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/15/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactUIView.h"

@interface ApplifierImpactDialog : ApplifierImpactUIView
  @property (nonatomic, assign) BOOL animating;
  @property (nonatomic, strong) UIView *spinner;
  @property (nonatomic, strong) UILabel *label;
  @property (nonatomic, strong) UIButton *button;

- (id)initWithFrame:(CGRect)frame useSpinner:(BOOL)createSpinner useLabel:(BOOL)createLabel useButton:(BOOL)createButton;
@end
