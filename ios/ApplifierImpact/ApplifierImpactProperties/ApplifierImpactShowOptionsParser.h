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
@property (nonatomic, assign) NSString *gamerSID;

+ (ApplifierImpactShowOptionsParser *)sharedInstance;
- (void)parseOptions:(NSDictionary *)options;

@end
