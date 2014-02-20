//
//  ApplifierImpactItem.h
//  ApplifierImpact
//
//  Created by Ville Orkas on 10/1/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplifierImpactRewardItem : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSURL *pictureURL;

- (id)initWithData:(NSDictionary *)data;

- (NSDictionary *)getDetails;

@end
