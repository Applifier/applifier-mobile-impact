//
//  ApplifierImpactViewManager.h
//  ImpactProto
//
//  Created by Johan Halin on 9/20/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ApplifierImpactVideo/ApplifierImpactVideo.h"

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

@interface ApplifierImpactViewManager : NSObject <ApplifierImpactVideoDelegate>

@property (nonatomic, assign) id<ApplifierImpactViewManagerDelegate> delegate;
@property (nonatomic, strong) NSString *machineName;
@property (nonatomic, strong) NSString *md5AdvertisingIdentifier;
@property (nonatomic, strong) NSString *md5MACAddress;
@property (nonatomic, strong) NSString *md5OpenUDID;
@property (nonatomic, strong) NSString *md5DeviceId;
@property (nonatomic, strong) NSDictionary *campaignJSON;
@property (nonatomic, strong) ApplifierImpactCampaign *selectedCampaign;
@property (nonatomic, assign, readonly) BOOL adViewVisible;

+ (id)sharedInstance;
- (void)handleWebEvent:(NSString *)type data:(NSDictionary *)data;
- (UIView *)adView;
- (void)loadWebView;

@end
