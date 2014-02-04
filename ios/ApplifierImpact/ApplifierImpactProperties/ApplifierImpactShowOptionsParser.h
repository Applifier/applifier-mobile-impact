//
//  ApplifierImpactShowOptionsParser.h
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/4/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplifierImpactShowOptionsParser : NSObject

@property (nonatomic, assign) BOOL openAnimated;
@property (nonatomic, assign) BOOL noOfferScreen;
@property (nonatomic, strong) NSString *gamerSID;
@property (nonatomic, assign) BOOL muteVideoSounds;
@property (nonatomic, assign) BOOL useDeviceOrientationForVideo;

+ (ApplifierImpactShowOptionsParser *)sharedInstance;
- (void)parseOptions:(NSDictionary *)options;
- (void)resetToDefaults;
- (NSDictionary *)getOptionsAsJson;
@end
