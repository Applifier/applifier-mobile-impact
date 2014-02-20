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
- (void)campaignManager:(ApplifierImpactCampaignManager *)campaignManager updatedWithCampaigns:(NSArray *)campaigns gamerID:(NSString *)gamerID;
- (void)campaignManagerCampaignDataReceived;
- (void)campaignManagerCampaignDataFailed;

@end

@interface ApplifierImpactCampaignManager : NSObject

@property (nonatomic, weak) id<ApplifierImpactCampaignManagerDelegate> delegate;
@property (nonatomic, strong) NSArray *campaigns;
@property (nonatomic, strong) NSDictionary *campaignData;
@property (nonatomic, strong) ApplifierImpactCampaign *selectedCampaign;

- (void)updateCampaigns;
- (NSURL *)getVideoURLForCampaign:(ApplifierImpactCampaign *)campaign;
- (void)cancelAllDownloads;
- (ApplifierImpactCampaign *)getCampaignWithId:(NSString *)campaignId;
- (ApplifierImpactCampaign *)getCampaignWithITunesId:(NSString *)iTunesId;
- (ApplifierImpactCampaign *)getCampaignWithClickUrl:(NSString *)clickUrl;
- (NSArray *)getViewableCampaigns;

+ (id)sharedInstance;

@end
