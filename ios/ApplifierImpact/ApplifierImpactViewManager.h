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
#import "ApplifierImpactWebView/ApplifierImpactWebAppController.h"

@class ApplifierImpactCampaign;
@class ApplifierImpactViewManager;
@class SKStoreProductViewController;

@protocol ApplifierImpactViewManagerDelegate <NSObject>

@required
- (void)viewManagerStartedPlayingVideo;
- (void)viewManagerVideoEnded;
- (UIViewController *)viewControllerForPresentingViewControllersForViewManager:(ApplifierImpactViewManager *)viewManager;
- (void)viewManagerWillCloseAdView;
- (void)viewManagerWebViewInitialized;
@end

@interface ApplifierImpactViewManager : NSObject <ApplifierImpactVideoDelegate, ApplifierImpactWebAppControllerDelegate>

@property (nonatomic, assign) id<ApplifierImpactViewManagerDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL adViewVisible;
@property (nonatomic) BOOL webViewInitialized;

+ (ApplifierImpactViewManager *)sharedInstance;
- (UIView *)adView;
- (void)initWebApp;
- (void)openAppStoreWithGameId:(NSString *)gameId;
- (void)showPlayerAndPlaySelectedVideo;
- (void)hidePlayer;
- (void)closeAdView;

@end
