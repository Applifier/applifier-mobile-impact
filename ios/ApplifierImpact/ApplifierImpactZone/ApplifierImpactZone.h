//
//  ApplifierImpactZone.h
//  ApplifierImpact
//
//  Created by Ville Orkas on 9/17/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplifierImpactZone : NSObject

- (id)initWithData:(NSDictionary *)options;

- (NSString *)getZoneId;
- (NSDictionary *)getZoneOptions;

- (BOOL)isIncentivized;
- (BOOL)isDefault;

- (BOOL)noWebView;
- (BOOL)noOfferScreen;
- (BOOL)openAnimated;
- (BOOL)muteVideoSounds;
- (BOOL)useDeviceOrientationForVideo;

- (NSString *)getGamerSid;
- (void)setGamerSid:(NSString *)gamerSid;

- (void)setNoOfferScreen:(BOOL)noOfferScreen;

- (int)allowVideoSkipInSeconds;

- (BOOL)allowsOverride:(NSString *)option;
- (void)mergeOptions:(NSDictionary *)options;

@end
