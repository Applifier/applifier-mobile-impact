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

@required
- (void)campaignManager:(ApplifierImpactCampaignManager *)campaignManager updatedWithCampaigns:(NSArray *)campaigns rewardItem:(ApplifierImpactRewardItem *)rewardItem gamerID:(NSString *)gamerID;
//- (void)campaignManager:(ApplifierImpactCampaignManager *)campaignManager campaignData:(NSDictionary *)data;
- (void)campaignManagerCampaignDataReceived;

@end

@interface ApplifierImpactCampaignManager : NSObject

@property (nonatomic, assign) id<ApplifierImpactCampaignManagerDelegate> delegate;
//@property (nonatomic, strong) NSString *queryString;
@property (nonatomic, strong) NSArray *campaigns;
@property (nonatomic, strong) NSDictionary *campaignData;
@property (nonatomic, strong) ApplifierImpactCampaign *selectedCampaign;
//@property (nonatomic, strong) id campaignData;

- (void)updateCampaigns;
- (NSURL *)getVideoURLForCampaign:(ApplifierImpactCampaign *)campaign;
- (void)cancelAllDownloads;
- (ApplifierImpactCampaign *)getCampaignWithId:(NSString *)campaignId;

+ (id)sharedInstance;

@end
