//
//  ApplifierImpactAdViewController.h
//  ApplifierImpact
//
//  Created by bluesun on 11/21/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "../ApplifierImpactWebView/ApplifierImpactWebAppController.h"
#import "../ApplifierImpactProperties/ApplifierImpactConstants.h"
#import "../ApplifierImpactViewState/ApplifierImpactViewState.h"

@protocol ApplifierImpactMainViewControllerDelegate <NSObject>

@required
- (void)mainControllerWebViewInitialized;
- (void)mainControllerWillOpen;
- (void)mainControllerDidOpen;
- (void)mainControllerWillClose;
- (void)mainControllerDidClose;
- (void)mainControllerStartedPlayingVideo;
- (void)mainControllerVideoEnded;
- (void)mainControllerWillLeaveApplication;
@end

@interface ApplifierImpactMainViewController : UIViewController <ApplifierImpactWebAppControllerDelegate, ApplifierImpactViewStateDelegate>

@property (nonatomic, assign) id<ApplifierImpactMainViewControllerDelegate> delegate;

+ (id)sharedInstance;

- (BOOL)openImpact:(BOOL)animated inState:(ApplifierImpactViewStateType)requestedState withOptions:(NSDictionary *)options;
- (BOOL)closeImpact:(BOOL)forceMainThread withAnimations:(BOOL)animated withOptions:(NSDictionary *)options;
- (BOOL)changeState:(ApplifierImpactViewStateType)requestedState withOptions:(NSDictionary *)options;

- (BOOL)mainControllerVisible;
- (void)applyOptionsToCurrentState:(NSDictionary *)options;

@end
