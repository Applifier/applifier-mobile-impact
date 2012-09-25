//
//  ApplifierImpactCampaign.h
//  ImpactProto
//
//  Created by Johan Halin on 9/6/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplifierImpactCampaign : NSObject

@property (nonatomic, strong) NSURL *endScreenURL;
@property (nonatomic, strong) NSURL *clickURL;
@property (nonatomic, strong) NSURL *pictureURL;
@property (nonatomic, strong) NSURL *trailerDownloadableURL;
@property (nonatomic, strong) NSURL *trailerStreamingURL;
@property (nonatomic, strong) NSString *gameID;
@property (nonatomic, strong) NSString *gameName;
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *tagline;
@property (nonatomic, strong) NSString *itunesID;
@property (nonatomic, assign) BOOL viewed;

@end
