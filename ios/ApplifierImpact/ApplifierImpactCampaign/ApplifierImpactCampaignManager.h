//
//  ApplifierImpactCampaignManager.h
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ApplifierImpactCampaignManager;
@class ApplifierImpactRewardItem;
@class ApplifierImpactCampaign;

@protocol ApplifierImpactCampaignManagerDelegate <NSObject>

@required
- (void)campaignManager:(ApplifierImpactCampaignManager *)campaignManager updatedWithCampaigns:(NSArray *)campaigns rewardItem:(ApplifierImpactRewardItem *)rewardItem gamerID:(NSString *)gamerID;
- (void)campaignManagerCampaignDataReceived;
- (void)campaignManagerCampaignDataFailed;

@end

@interface ApplifierImpactCampaignManager : NSObject

@property (nonatomic, assign) id<ApplifierImpactCampaignManagerDelegate> delegate;
@property (nonatomic, strong) NSArray *campaigns;
@property (nonatomic, strong) NSDictionary *campaignData;
@property (nonatomic, strong) ApplifierImpactCampaign *selectedCampaign;
@property (nonatomic, strong) ApplifierImpactRewardItem *defaultRewardItem;
@property (nonatomic, strong) NSArray *rewardItems;
@property (nonatomic, strong) NSArray *rewardItemKeys;
@property (nonatomic, strong) NSString *currentRewardItemKey;

- (void)updateCampaigns;
- (NSURL *)getVideoURLForCampaign:(ApplifierImpactCampaign *)campaign;
- (void)cancelAllDownloads;
- (ApplifierImpactCampaign *)getCampaignWithId:(NSString *)campaignId;
- (NSArray *)getViewableCampaigns;
- (BOOL)setSelectedRewardItemKey:(NSString *)rewardItemKey;
- (ApplifierImpactRewardItem *)getCurrentRewardItem;

+ (id)sharedInstance;

@end
