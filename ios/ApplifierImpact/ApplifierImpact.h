//
//  ApplifierImpact.h
//  ApplifierImpact
//
//  Created by Johan Halin on 9/4/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>

//
//  All delegate methods and public methods in this header are based on the tentative iOS specification document,
//  and will probably change during development.
//

@class ApplifierImpact;

@protocol ApplifierImpactDelegate <NSObject>

@optional
- (void)applifierImpactWillOpen:(ApplifierImpact *)applifierImpact;
- (void)applifierImpactWillClose:(ApplifierImpact *)applifierImpact;
- (void)applifierImpactVideoStarted:(ApplifierImpact *)applifierImpact;
- (void)applifierImpactVideoCompleted:(ApplifierImpact *)applifierImpact;
- (void)applifierImpactCampaignsAreAvailable:(ApplifierImpact *)applifierImpact;

@end

@interface ApplifierImpact : NSObject

@property (nonatomic, assign) id<ApplifierImpactDelegate> delegate;

+ (id)sharedInstance;

- (void)startWithApplifierID:(NSString *)applifierID;
- (BOOL)showImpact;
- (BOOL)hasCampaigns;
- (void)stopAll;

@end
