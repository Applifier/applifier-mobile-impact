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

- (id)initWithFrame:(CGRect)frame useSpinner:(BOOL)createSpinner;
@end
