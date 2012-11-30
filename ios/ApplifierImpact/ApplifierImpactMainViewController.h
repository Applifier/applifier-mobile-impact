//
//  ApplifierImpactAdViewController.h
//  ApplifierImpact
//
//  Created by bluesun on 11/21/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApplifierImpactWebView/ApplifierImpactWebAppController.h"
#import "ApplifierImpactVideo/ApplifierImpactVideoViewController.h"

@protocol ApplifierImpactMainViewControllerDelegate <NSObject>

@required
- (void)mainControllerStartedPlayingVideo;
- (void)mainControllerVideoEnded;
- (void)mainControllerWillCloseAdView;
- (void)mainControllerWebViewInitialized;
@end

@interface ApplifierImpactMainViewController : UIViewController <ApplifierImpactVideoControllerDelegate, ApplifierImpactWebAppControllerDelegate>

@property (nonatomic, assign) id<ApplifierImpactMainViewControllerDelegate> delegate;
//@property (nonatomic) BOOL webViewInitialized;

+ (id)sharedInstance;

- (BOOL)openImpact;
- (BOOL)closeImpact:(BOOL)forceMainThread;
- (BOOL)mainControllerVisible;
- (void)showPlayerAndPlaySelectedVideo:(BOOL)checkIfWatched;
- (void)openAppStoreWithData:(NSDictionary *)data;

@end
