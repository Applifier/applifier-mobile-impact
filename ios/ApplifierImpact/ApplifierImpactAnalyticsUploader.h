//
//  ApplifierImpactAnalyticsUploader.h
//  ImpactProto
//
//  Created by Johan Halin on 13.9.2012.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ApplifierImpactCampaign;

@interface ApplifierImpactAnalyticsUploader : NSObject

- (void)sendViewReportForCampaign:(ApplifierImpactCampaign *)campaign positionString:(NSString *)positionString;
- (void)retryFailedUploads;

@end
