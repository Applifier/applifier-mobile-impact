//
//  ApplifierImpactAdViewController.h
//  ApplifierImpact
//
//  Created by bluesun on 11/21/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "../ApplifierImpactProperties/ApplifierImpactConstants.h"
#import "../ApplifierImpactViewState/ApplifierImpactViewState.h"

@protocol ApplifierImpactMainViewControllerDelegate <NSObject>

@required
- (void)mainControllerWillOpen;
- (void)mainControllerDidOpen;
- (void)mainControllerWillClose;
- (void)mainControllerDidClose;
- (void)mainControllerStartedPlayingVideo;
- (void)mainControllerVideoEnded;
- (void)mainControllerVideoSkipped;
- (void)mainControllerWillLeaveApplication;
@end

@interface ApplifierImpactMainViewController : UIViewController <ApplifierImpactViewStateDelegate>

@property (nonatomic, assign) id<ApplifierImpactMainViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL isClosing;
@property (nonatomic, assign) BOOL isOpen;


+ (id)sharedInstance;

- (BOOL)openImpact:(BOOL)animated inState:(ApplifierImpactViewStateType)requestedState withOptions:(NSDictionary *)options;
- (BOOL)closeImpact:(BOOL)forceMainThread withAnimations:(BOOL)animated withOptions:(NSDictionary *)options;
- (BOOL)changeState:(ApplifierImpactViewStateType)requestedState withOptions:(NSDictionary *)options;

- (BOOL)mainControllerVisible;
- (void)applyOptionsToCurrentState:(NSDictionary *)options;
- (void)applyViewStateHandler:(ApplifierImpactViewState *)viewState;
- (ApplifierImpactViewState *)getCurrentViewState;
- (ApplifierImpactViewState *)getPreviousViewState;
@end
