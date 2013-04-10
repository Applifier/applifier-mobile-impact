//
//  ApplifierImpactInitializer.h
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/5/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../ApplifierImpactDevice/ApplifierImpactDevice.h"
#import "../ApplifierImpactProperties/ApplifierImpactConstants.h"
#import "../ApplifierImpactProperties/ApplifierImpactProperties.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaignManager.h"
#import "../ApplifierImpactView/ApplifierImpactMainViewController.h"
#import "../ApplifierImpactData/ApplifierImpactAnalyticsUploader.h"

@protocol ApplifierImpactInitializerDelegate <NSObject>

@required
- (void)initComplete;
- (void)initFailed;
@end

@interface ApplifierImpactInitializer : NSObject
  @property (nonatomic, assign) id<ApplifierImpactInitializerDelegate> delegate;
  @property (nonatomic, strong) NSThread *backgroundThread;
  @property (nonatomic, assign) dispatch_queue_t queue;

- (void)initImpact:(NSDictionary *)options;
- (BOOL)initWasSuccessfull;
- (void)checkForVersionAndShowAlertDialog;
- (void)reInitialize;
- (void)deInitialize;

- (void)initCampaignManager;
- (void)refreshCampaignManager;
- (void)initAnalyticsUploader;

@end
