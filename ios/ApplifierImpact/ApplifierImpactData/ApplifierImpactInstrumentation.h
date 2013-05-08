//
//  ApplifierImpactInstrumentation.h
//  ApplifierImpact
//
//  Created by Pekka Palmu on 5/7/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../ApplifierImpactCampaign/ApplifierImpactCampaign.h"

@interface ApplifierImpactInstrumentation : NSObject

+ (void)gaInstrumentationVideoPlay:(ApplifierImpactCampaign *)campaign withValuesFrom:(NSDictionary *)additionalValues;
+ (void)gaInstrumentationVideoError:(ApplifierImpactCampaign *)campaign withValuesFrom:(NSDictionary *)additionalValues;
+ (void)gaInstrumentationVideoAbort:(ApplifierImpactCampaign *)campaign withValuesFrom:(NSDictionary *)additionalValues;
+ (void)gaInstrumentationVideoCaching:(ApplifierImpactCampaign *)campaign withValuesFrom:(NSDictionary *)additionalValues;

@end
