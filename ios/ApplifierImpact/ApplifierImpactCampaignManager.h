//
//  ApplifierImpactCampaignManager.h
//  ImpactProto
//
//  Created by Johan Halin on 5.9.2012.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ApplifierImpactCampaignManager;
@class ApplifierImpactRewardItem;
@class ApplifierImpactCampaign;

@protocol ApplifierImpactCampaignManagerDelegate <NSObject>

- (void)campaignManager:(ApplifierImpactCampaignManager *)campaignManager updatedWithCampaigns:(NSArray *)campaigns rewardItem:(ApplifierImpactRewardItem *)rewardItem;
- (void)campaignManager:(ApplifierImpactCampaignManager *)campaignManager downloadedJSON:(NSString *)json;

@end

@interface ApplifierImpactCampaignManager : NSObject

@property (nonatomic, assign) id<ApplifierImpactCampaignManagerDelegate> delegate;

- (void)updateCampaigns;
- (NSURL *)videoURLForCampaign:(ApplifierImpactCampaign *)campaign;
- (void)cancelAllDownloads;

@end
