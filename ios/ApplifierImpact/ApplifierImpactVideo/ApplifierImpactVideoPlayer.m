//
//  ApplifierImpactVideo.m
//  ApplifierImpact
//
//  Created by bluesun on 10/22/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactVideoPlayer.h"
#import "../ApplifierImpact.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaign.h"
#import "../ApplifierImpactDevice/ApplifierImpactDevice.h"
#import "../ApplifierImpactData/ApplifierImpactAnalyticsUploader.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaignManager.h"
#import "../ApplifierImpactWebView/ApplifierImpactWebAppController.h"

@interface ApplifierImpactVideoPlayer ()
  @property (nonatomic, assign) id timeObserver;
  @property (nonatomic, assign) id analyticsTimeObserver;
  @property (nonatomic) VideoAnalyticsPosition videoPosition;
@end

@implementation ApplifierImpactVideoPlayer

- (void)preparePlayer {
  [self _addObservers];
}

- (void)clearPlayer {
  [self _removeObservers];
}


#pragma mark Video Playback

- (void)playSelectedVideo {
  self.videoPosition = kVideoAnalyticsPositionUnplayed;
  [self.delegate videoPlaybackStarted];
	[self _logVideoAnalytics];
}

- (void)_videoPlaybackEnded:(NSNotification *)notification {
  AILOG_DEBUG(@"");
  if ([[ApplifierImpactDevice analyticsMachineName] isEqualToString:kApplifierImpactDeviceIosUnknown]) {
    self.videoPosition = kVideoAnalyticsPositionThirdQuartile;
  }
  
  [self _logVideoAnalytics];
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:@"videoCompleted" data:@{@"campaignId":[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].id}];
  [self.delegate videoPlaybackEnded];
}


#pragma mark Video Observers

- (void)_addObservers {
  [self addObserver:self forKeyPath:@"self.currentItem.status" options:0 context:nil];
  [self addObserver:self forKeyPath:@"self.currentItem.error" options:0 context:nil];
  [self addObserver:self forKeyPath:@"self.currentItem.asset.duration" options:0 context:nil];
  
  __block ApplifierImpactVideoPlayer *blockSelf = self;
  if (![[ApplifierImpactDevice analyticsMachineName] isEqualToString:kApplifierImpactDeviceIosUnknown]) {
    AILOG_DEBUG(@"ADDING POSITION OBSERVER");
    self.timeObserver = [self addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC) queue:nil usingBlock:^(CMTime time) {
      [blockSelf _videoPositionChanged:time];
    }];
  }
  
	Float64 duration = [self _currentVideoDuration];
	NSMutableArray *analyticsTimeValues = [NSMutableArray array];
	[analyticsTimeValues addObject:[self _valueWithDuration:duration * .25]];
	[analyticsTimeValues addObject:[self _valueWithDuration:duration * .5]];
	[analyticsTimeValues addObject:[self _valueWithDuration:duration * .75]];
  
  if (![[ApplifierImpactDevice analyticsMachineName] isEqualToString:kApplifierImpactDeviceIosUnknown]) {
    self.analyticsTimeObserver = [self addBoundaryTimeObserverForTimes:analyticsTimeValues queue:nil usingBlock:^{
      [blockSelf _logVideoAnalytics];
    }];
  }
  
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoPlaybackEnded:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentItem];
}

- (void)_removeObservers {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
  
  if (self.timeObserver != nil) {
    [self removeTimeObserver:self.timeObserver];
    self.timeObserver = nil;
  }
	
  if (self.analyticsTimeObserver != nil) {
    [self removeTimeObserver:self.analyticsTimeObserver];
    self.analyticsTimeObserver = nil;
  }
  
  [self removeObserver:self forKeyPath:@"self.currentItem.status"];
  [self removeObserver:self forKeyPath:@"self.currentItem.error"];
  [self removeObserver:self forKeyPath:@"self.currentItem.asset.duration"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if ([keyPath isEqual:@"self.currentItem.error"]) {
    AILOG_DEBUG(@"VIDEOPLAYER_ERROR: %@", self.currentItem.error);
  }
  else if ([keyPath isEqual:@"self.currentItem.asset.duration"]) {
    AILOG_DEBUG(@"VIDEOPLAYER_DURATION: %f", CMTimeGetSeconds(self.currentItem.asset.duration));
  }
  else if ([keyPath isEqual:@"self.currentItem.status"]) {
    AILOG_DEBUG(@"VIDEOPLAYER_STATUS: %i", self.currentItem.status);
    
    AVPlayerStatus playerStatus = self.currentItem.status;
    if (playerStatus == AVPlayerStatusReadyToPlay) {
      [self.delegate videoStartedPlaying];
      [self play];
    }
    else if (playerStatus == AVPlayerStatusFailed) {
      AILOG_DEBUG(@"Player failed");
    }
    else if (playerStatus == AVPlayerStatusUnknown) {
      AILOG_DEBUG(@"Player in unknown state");
    }
  }
}


#pragma mark Video Duration

- (void)_videoPositionChanged:(CMTime)time {
  AILOG_DEBUG(@"");
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.delegate videoPositionChanged:time];
  });
}

- (Float64)_currentVideoDuration {
	CMTime durationTime = self.currentItem.asset.duration;
	Float64 duration = CMTimeGetSeconds(durationTime);
	
	return duration;
}

- (NSValue *)_valueWithDuration:(Float64)duration {
	CMTime time = CMTimeMakeWithSeconds(duration, NSEC_PER_SEC);
	return [NSValue valueWithCMTime:time];
}


#pragma mark Analytics

- (void)_logVideoAnalytics {
	self.videoPosition++;
  [[ApplifierImpactAnalyticsUploader sharedInstance] logVideoAnalyticsWithPosition:self.videoPosition campaign:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign]];
}

@end