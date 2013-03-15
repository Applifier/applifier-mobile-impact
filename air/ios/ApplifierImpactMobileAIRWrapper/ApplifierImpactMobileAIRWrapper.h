//
//  ApplifierImpactMobileAIRWrapper.h
//  ApplifierImpactMobileAIRWrapper
//
//  Created by bluesun on 12/10/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "FlashRuntimeExtensions.h"
#import <ApplifierImpact/ApplifierImpact.h>
#import <UIKit/UIKit.h>

@interface ApplifierImpactMobileAIRWrapper : NSObject <ApplifierImpactDelegate>
+ (ApplifierImpactMobileAIRWrapper *)sharedInstance;
- (BOOL)show:(NSDictionary *)options;
- (BOOL)hide;


@end
