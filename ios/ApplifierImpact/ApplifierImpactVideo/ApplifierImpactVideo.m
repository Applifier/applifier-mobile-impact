//
//  ApplifierImpactVideo.m
//  ApplifierImpact
//
//  Created by bluesun on 10/22/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactVideo.h"
#import "../ApplifierImpact.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaign.h"
#import "../ApplifierImpactDevice/ApplifierImpactDevice.h"

id timeObserver;
id analyticsTimeObserver;
VideoAnalyticsPosition videoPosition;
ApplifierImpactCampaign *selectedCampaign;

@implementation ApplifierImpactVideo

- (void)createPlayerLayer {
	self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self];
	self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
}

- (void)playSelectedVideo {
  __block ApplifierImpactVideo *blockSelf = self;
  if (![[ApplifierImpactDevice analyticsMachineName] isEqualToString:@"iosUnknown"]) {
    timeObserver = [self addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC) queue:nil usingBlock:^(CMTime time) {
      [blockSelf _videoPositionChanged:time];
    }];
  }
	
  videoPosition = kVideoAnalyticsPositionUnplayed;
	Float64 duration = [self _currentVideoDuration];
	NSMutableArray *analyticsTimeValues = [NSMutableArray array];
	[analyticsTimeValues addObject:[self _valueWithDuration:duration * .25]];
	[analyticsTimeValues addObject:[self _valueWithDuration:duration * .5]];
	[analyticsTimeValues addObject:[self _valueWithDuration:duration * .75]];
  
  if (![[ApplifierImpactDevice analyticsMachineName] isEqualToString:@"iosUnknown"]) {
    analyticsTimeObserver = [self addBoundaryTimeObserverForTimes:analyticsTimeValues queue:nil usingBlock:^{
      [blockSelf _logVideoAnalytics];
    }];
  }
    
	[self play];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoPlaybackEnded:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];  
  [self.delegate videoPlaybackStarted];
	[self _logVideoAnalytics];
}

- (void)_videoPlaybackEnded:(NSNotification *)notification
{
	AILOG_DEBUG(@"");
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

  if ([[ApplifierImpactDevice analyticsMachineName] isEqualToString:@"iosUnknown"]) {
    videoPosition = kVideoAnalyticsPositionThirdQuartile;
  }
  
  [self _logVideoAnalytics];
	[self removeTimeObserver:timeObserver];
	timeObserver = nil;
	[self removeTimeObserver:analyticsTimeObserver];
	analyticsTimeObserver = nil;
  
  [self.delegate videoPlaybackEnded];
}

- (void)_videoPositionChanged:(CMTime)time {
  [self.delegate videoPositionChanged:time];
}

- (void)_logVideoAnalytics
{
	videoPosition++;
	[self.delegate videoAnalyticsPositionReached:videoPosition];
}

- (Float64)_currentVideoDuration
{
	CMTime durationTime = self.currentItem.asset.duration;
	Float64 duration = CMTimeGetSeconds(durationTime);
	
	return duration;
}

- (NSValue *)_valueWithDuration:(Float64)duration
{
	CMTime time = CMTimeMakeWithSeconds(duration, NSEC_PER_SEC);
	return [NSValue valueWithCMTime:time];
}


@end
