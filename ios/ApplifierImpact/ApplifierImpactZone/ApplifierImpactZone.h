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

- (BOOL)noWebView;
- (BOOL)noOfferScreen;
- (BOOL)openAnimated;
- (BOOL)muteVideoSounds;
- (BOOL)useDeviceOrientationForVideo;

- (BOOL)allowsOverride:(NSString *)option;
- (void)mergeOptions:(NSDictionary *)options;

@end
