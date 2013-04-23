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

@interface ApplifierImpactVideoPlayer ()
  @property (nonatomic, assign) id timeObserver;
  @property (nonatomic, assign) id analyticsTimeObserver;
  @property (nonatomic, assign) NSTimer *timeOutTimer;
  @property (nonatomic) VideoAnalyticsPosition videoPosition;
  @property (nonatomic, assign) BOOL isPlaying;
  @property (nonatomic, assign) BOOL hasPlayed;
@end

@implementation ApplifierImpactVideoPlayer

- (void)preparePlayer {
  self.isPlaying = false;
  self.hasPlayed = false;
  [self _addObservers];
}

- (void)clearPlayer {
  self.isPlaying = false;
  self.hasPlayed = false;
  [self _removeObservers];
}


#pragma mark Video Playback

- (void)playSelectedVideo {
  self.videoPosition = kVideoAnalyticsPositionUnplayed;
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.delegate videoPlaybackStarted];
  });
}

- (void)_videoPlaybackEnded:(NSNotification *)notification {
  AILOG_DEBUG(@"");
  if ([ApplifierImpactDevice isSimulator]) {
    self.videoPosition = kVideoAnalyticsPositionThirdQuartile;
  }
  
  [self _logVideoAnalytics];

  dispatch_async(dispatch_get_main_queue(), ^{
    self.hasPlayed = true;
    self.isPlaying = false;
    [self.delegate videoPlaybackEnded];
  });
}


#pragma mark Video Observers

- (void)checkIfPlayed {
  AILOG_DEBUG(@"");
  
  if (!self.hasPlayed && !self.isPlaying) {
    AILOG_DEBUG(@"Video hasn't played and video is not playing! Seems that video is timing out.");
    [self.timeOutTimer invalidate];
    self.timeOutTimer = nil;
    [self.delegate videoPlaybackError];
  }
}

- (void)_addObservers {
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [self addObserver:self forKeyPath:@"self.currentItem.status" options:0 context:nil];
    [self addObserver:self forKeyPath:@"self.currentItem.error" options:0 context:nil];
    [self addObserver:self forKeyPath:@"self.currentItem.asset.duration" options:0 context:nil];
  });
 
  __block ApplifierImpactVideoPlayer *blockSelf = self;
  if (![ApplifierImpactDevice isSimulator]) {
    self.timeObserver = [self addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC) queue:nil usingBlock:^(CMTime time) {
      [blockSelf _videoPositionChanged:time];
    }];
  }
  
  self.timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(checkIfPlayed) userInfo:nil repeats:false];
  
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoPlaybackEnded:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentItem];
}

- (void)_removeObservers {
  AILOG_DEBUG(@"");
  [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
  
  if (self.timeObserver != nil) {
    [self removeTimeObserver:self.timeObserver];
    self.timeObserver = nil;
  }
	
  if (self.analyticsTimeObserver != nil) {
    [self removeTimeObserver:self.analyticsTimeObserver];
    self.analyticsTimeObserver = nil;
  }
  
  if (self.timeOutTimer != nil) {
    [self.timeOutTimer invalidate];
    self.timeOutTimer = nil;
  }

  [self removeObserver:self forKeyPath:@"self.currentItem.status"];
  [self removeObserver:self forKeyPath:@"self.currentItem.error"];
  [self removeObserver:self forKeyPath:@"self.currentItem.asset.duration"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if ([keyPath isEqual:@"self.currentItem.error"] && self.currentItem.error != nil) {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.isPlaying = false;
      self.hasPlayed = false;
      [self.delegate videoPlaybackError];
    });
    AILOG_DEBUG(@"VIDEOPLAYER_ERROR: %@", self.currentItem.error);
  }
  else if ([keyPath isEqual:@"self.currentItem.asset.duration"]) {
    AILOG_DEBUG(@"VIDEOPLAYER_DURATION: %f", CMTimeGetSeconds(self.currentItem.asset.duration));
  }
  else if ([keyPath isEqual:@"self.currentItem.status"]) {
    AILOG_DEBUG(@"VIDEOPLAYER_STATUS: %i", self.currentItem.status);
    
    AVPlayerStatus playerStatus = self.currentItem.status;
    if (playerStatus == AVPlayerStatusReadyToPlay) {
      AILOG_DEBUG(@"videostartedplaying");
      __block ApplifierImpactVideoPlayer *blockSelf = self;
      
      Float64 duration = [self _currentVideoDuration];
      NSMutableArray *analyticsTimeValues = [NSMutableArray array];
      [analyticsTimeValues addObject:[self _valueWithDuration:duration * .25]];
      [analyticsTimeValues addObject:[self _valueWithDuration:duration * .5]];
      [analyticsTimeValues addObject:[self _valueWithDuration:duration * .75]];
      
      if (![ApplifierImpactDevice isSimulator]) {
        self.analyticsTimeObserver = [self addBoundaryTimeObserverForTimes:analyticsTimeValues queue:nil usingBlock:^{
          AILOG_DEBUG(@"Log position");
          [blockSelf _logVideoAnalytics];
        }];
      }
      
      dispatch_async(dispatch_get_main_queue(), ^{
        self.hasPlayed = false;
        self.isPlaying = true;
        [self.delegate videoStartedPlaying];
        [self _logVideoAnalytics];
      });
      
      [self play];
    }
    else if (playerStatus == AVPlayerStatusFailed) {
      AILOG_DEBUG(@"Player failed");
      dispatch_async(dispatch_get_main_queue(), ^{
        self.hasPlayed = false;
        self.isPlaying = false;
        [self.delegate videoPlaybackError];
      });
    }
    else if (playerStatus == AVPlayerStatusUnknown) {
      AILOG_DEBUG(@"Player in unknown state");
    }
  }
}


#pragma mark Video Duration

- (void)_videoPositionChanged:(CMTime)time {
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
  AILOG_DEBUG(@"_logVideoAnalytics");
	self.videoPosition++;
  [[ApplifierImpactAnalyticsUploader sharedInstance] logVideoAnalyticsWithPosition:self.videoPosition campaign:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign]];
}

@end