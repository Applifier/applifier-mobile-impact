//
//  ApplifierImpactNoWebViewEndScreenBottomBarContent.h
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/18/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApplifierImpactNativeButton.h"

@interface ApplifierImpactNoWebViewEndScreenBottomBarContent : UIView
@property (nonatomic, strong) ApplifierImpactNativeButton *downloadButton;
- (void)updateViewData;
- (void)destroyView;
@end
