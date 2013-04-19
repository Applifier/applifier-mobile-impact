//
//  ApplifierImpactCampaign.h
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplifierImpactCampaign : NSObject

@property (nonatomic, strong) NSURL *endScreenURL;
@property (nonatomic, strong) NSURL *endScreenPortraitURL;
@property (nonatomic, strong) NSURL *clickURL;
@property (nonatomic, strong) NSURL *pictureURL;
@property (nonatomic, strong) NSURL *trailerDownloadableURL;
@property (nonatomic, strong) NSURL *trailerStreamingURL;
@property (nonatomic, strong) NSURL *gameIconURL;
@property (nonatomic, strong) NSString *gameID;
@property (nonatomic, strong) NSString *gameName;
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *tagLine;
@property (nonatomic, strong) NSString *itunesID;
@property (nonatomic, assign) BOOL shouldCacheVideo;
@property (nonatomic, assign) BOOL viewed;
@property (nonatomic, assign) BOOL bypassAppSheet;
@property (nonatomic, assign) long long expectedTrailerSize;
@property (nonatomic, assign) BOOL isValidCampaign;

- (id)initWithData:(NSDictionary *)data;

@end
