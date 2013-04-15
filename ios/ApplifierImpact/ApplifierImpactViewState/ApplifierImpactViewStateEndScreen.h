//
//  ApplifierImpactViewStateEndScreen.h
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/5/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactViewState.h"
#import "../ApplifierImpactData/ApplifierImpactAnalyticsUploader.h"
#import "../ApplifierImpactView/ApplifierImpactMainViewController.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaignManager.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaign.h"
#import "../ApplifierImpactWebView/ApplifierImpactWebAppController.h"

#import "../ApplifierImpact.h"

@interface ApplifierImpactViewStateEndScreen : ApplifierImpactViewState
- (void)openAppStoreWithData:(NSDictionary *)data inViewController:(UIViewController *)targetViewController;
@end
