//
//  ApplifierImpactVideo.h
//  ApplifierImpact
//
//  Created by bluesun on 10/22/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

typedef enum
{
	kVideoAnalyticsPositionUnplayed = -1,
	kVideoAnalyticsPositionStart = 0,
	kVideoAnalyticsPositionFirstQuartile = 1,
	kVideoAnalyticsPositionMidPoint = 2,
	kVideoAnalyticsPositionThirdQuartile = 3,
	kVideoAnalyticsPositionEnd = 4,
} VideoAnalyticsPosition;

@protocol ApplifierImpactVideoDelegate <NSObject>

@required
- (void)videoPlaybackStarted;
- (void)videoStartedPlaying;
- (void)videoPlaybackEnded;
- (void)videoPositionChanged:(CMTime)time;
@end

@interface ApplifierImpactVideo : AVPlayer
@property (nonatomic, assign) id<ApplifierImpactVideoDelegate> delegate;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
- (void)playSelectedVideo;
- (void)preparePlayer;
- (void)clearPlayer;
//- (void)createPlayerLayer;
//- (void)destroyPlayer;
@end
