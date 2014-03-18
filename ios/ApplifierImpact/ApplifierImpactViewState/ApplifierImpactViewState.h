//
//  ApplifierImpactViewState.h
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/4/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../ApplifierImpactProperties/ApplifierImpactConstants.h"
#import "../ApplifierImpact.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaignManager.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaign.h"
#import "../ApplifierImpactWebView/ApplifierImpactWebAppController.h"

@protocol ApplifierImpactViewStateDelegate <NSObject>

@required
- (void)stateNotification:(ApplifierImpactViewStateAction)action;
@end

@interface ApplifierImpactViewState : NSObject

@property (nonatomic, weak) id<ApplifierImpactViewStateDelegate> delegate;
@property (nonatomic, assign) BOOL waitingToBeShown;

- (ApplifierImpactViewStateType)getStateType;

- (void)enterState:(NSDictionary *)options;
- (void)exitState:(NSDictionary *)options;

- (void)willBeShown;
- (void)wasShown;

- (void)applyOptions:(NSDictionary *)options;
- (void)openAppStoreWithData:(NSDictionary *)data inViewController:(UIViewController *)targetViewController;
@end
