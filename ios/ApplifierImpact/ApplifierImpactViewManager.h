//
//  ApplifierImpactViewManager.h
//  ImpactProto
//
//  Created by Johan Halin on 9/20/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum
{
	kVideoAnalyticsPositionUnplayed = -1,
	kVideoAnalyticsPositionStart = 0,
	kVideoAnalyticsPositionFirstQuartile = 1,
	kVideoAnalyticsPositionMidPoint = 2,
	kVideoAnalyticsPositionThirdQuartile = 3,
	kVideoAnalyticsPositionEnd = 4,
} VideoAnalyticsPosition;

@class ApplifierImpactCampaign;
@class ApplifierImpactViewManager;
@class SKStoreProductViewController;

@protocol ApplifierImpactViewManagerDelegate <NSObject>

@required
- (ApplifierImpactCampaign *)viewManager:(ApplifierImpactViewManager *)viewManager campaignWithID:(NSString *)campaignID;
- (NSURL *)viewManager:(ApplifierImpactViewManager *)viewManager videoURLForCampaign:(ApplifierImpactCampaign *)campaign;
- (void)viewManagerStartedPlayingVideo:(ApplifierImpactViewManager *)viewManager;
- (void)viewManagerVideoEnded:(ApplifierImpactViewManager *)viewManager;
- (void)viewManager:(ApplifierImpactViewManager *)viewManager loggedVideoPosition:(VideoAnalyticsPosition)videoPosition campaign:(ApplifierImpactCampaign *)campaign;
- (UIViewController *)viewControllerForPresentingViewControllersForViewManager:(ApplifierImpactViewManager *)viewManager;
- (void)viewManagerWillCloseAdView:(ApplifierImpactViewManager *)viewManager;
- (void)viewManagerWebViewInitialized:(ApplifierImpactViewManager *)viewManager;

@end

@interface ApplifierImpactViewManager : NSObject

@property (nonatomic, assign) id<ApplifierImpactViewManagerDelegate> delegate;
@property (nonatomic, strong) NSString *machineName;
@property (nonatomic, strong) NSString *md5AdvertisingIdentifier;
@property (nonatomic, strong) NSString *md5MACAddress;
@property (nonatomic, strong) NSString *md5OpenUDID;
@property (nonatomic, strong) NSString *campaignJSON;
@property (nonatomic, strong) ApplifierImpactCampaign *selectedCampaign;
@property (nonatomic, assign, readonly) BOOL adViewVisible;

- (void)loadWebView;
- (UIView *)adView;

@end
