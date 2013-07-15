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
#import "../ApplifierImpactData/ApplifierImpactInstrumentation.h"
#import "../ApplifierImpactProperties/ApplifierImpactConstants.h"

@interface ApplifierImpactVideoPlayer ()
  @property (nonatomic, assign) id timeObserver;
  @property (nonatomic, assign) id analyticsTimeObserver;
  @property (nonatomic, assign) NSTimer *timeOutTimer;
  @property (nonatomic) VideoAnalyticsPosition videoPosition;
  @property (nonatomic, assign) BOOL isPlaying;
  @property (nonatomic, assign) BOOL hasPlayed;
  @property (nonatomic, assign) BOOL hasMoved;
  @property (nonatomic, strong) NSTimer *videoProgressMonitor;
  @property (nonatomic, assign) CMTime lastUpdate;
@end

@implementation ApplifierImpactVideoPlayer

@synthesize timeOutTimer = _timeOutTimer;

- (void)preparePlayer {
  self.isPlaying = false;
  self.hasPlayed = false;
  self.hasMoved = false;
  [self _addObservers];
}

- (void)clearPlayer {
  self.isPlaying = false;
  self.hasPlayed = false;
  self.hasMoved = false;
  [self _removeObservers];
}



- (void)dealloc {
  AILOG_DEBUG(@"dealloc");
}

#pragma mark Video Playback

- (void) muteVideo {
}

- (void)playSelectedVideo {
  self.videoPosition = kVideoAnalyticsPositionUnplayed;
  [[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].videoBufferingStartTime = [[NSDate date] timeIntervalSince1970] * 1000;
}

- (void)_videoPlaybackEnded:(NSNotification *)notification {
  AILOG_DEBUG(@"");
  if ([ApplifierImpactDevice isSimulator]) {
    self.videoPosition = kVideoAnalyticsPositionThirdQuartile;
  }
  
  [self _logVideoAnalytics];
  [self clearVideoProgressMonitor];

  dispatch_async(dispatch_get_main_queue(), ^{
    self.hasPlayed = true;
    self.isPlaying = false;
    [self.delegate videoPlaybackEnded:FALSE];
  });
}


#pragma mark Video Observers

- (void)checkIfPlayed {
  AILOG_DEBUG(@"");
  
  if (!self.hasPlayed && !self.isPlaying) {
    AILOG_DEBUG(@"Video hasn't played and video is not playing! Seems that video is timing out.");
    [self clearTimeOutTimer];
    [self clearVideoProgressMonitor];
    [self.delegate videoPlaybackError];
    [ApplifierImpactInstrumentation gaInstrumentationVideoError:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign] withValuesFrom:nil];
  }
}

- (void)_addObservers {
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [self addObserver:self forKeyPath:@"currentItem.status" options:0 context:nil];
  });
 
  __block ApplifierImpactVideoPlayer *blockSelf = self;
    self.timeObserver = [self addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC) queue:nil usingBlock:^(CMTime time) {
      [blockSelf _videoPositionChanged:time];
    }];  
  
  self.timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:25 target:self selector:@selector(checkIfPlayed) userInfo:nil repeats:false];
  
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoPlaybackEnded:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentItem];
}

- (void)clearTimeOutTimer {
  if (self.timeOutTimer != nil) {
    [self.timeOutTimer invalidate];
    self.timeOutTimer = nil;
  }
}

- (void)clearVideoProgressMonitor {
  if(self.videoProgressMonitor != nil) {
    [self.videoProgressMonitor invalidate];
    self.videoProgressMonitor = nil;
  }
}

- (void)_removeObservers {
  AILOG_DEBUG(@"");
  AIAssert([NSThread isMainThread]);
  [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
  
  if (self.timeObserver != nil) {
    [self removeTimeObserver:self.timeObserver];
    self.timeObserver = nil;
  }
	
  if (self.analyticsTimeObserver != nil) {
    [self removeTimeObserver:self.analyticsTimeObserver];
    self.analyticsTimeObserver = nil;
  }
  
  [self clearTimeOutTimer];
  [self clearVideoProgressMonitor];

  [self removeObserver:self forKeyPath:@"currentItem.status"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if ([keyPath isEqual:@"currentItem.status"]) {
    AILOG_DEBUG(@"VIDEOPLAYERITEM_STATUS: %i", self.currentItem.status);
    
    AVPlayerItemStatus playerItemStatus = self.currentItem.status;
    if (playerItemStatus == AVPlayerItemStatusReadyToPlay) {
      AILOG_DEBUG(@"videostartedplaying");
      __block ApplifierImpactVideoPlayer *blockSelf = self;
      
      self.lastUpdate = kCMTimeInvalid;
      self.videoProgressMonitor = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(_videoProgressMonitor:) userInfo:nil repeats:YES];
      
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
        self.isPlaying = false;
        [self.delegate videoStartedPlaying];
        [self _logVideoAnalytics];
      });
      
      [self play];
      
      [[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].videoBufferingEndTime = [[NSDate date] timeIntervalSince1970] * 1000;
      long long bufferingCompleted = [[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].videoBufferingEndTime - [[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].videoBufferingStartTime;
      
      [ApplifierImpactInstrumentation gaInstrumentationVideoPlay:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign] withValuesFrom:@{kApplifierImpactGoogleAnalyticsEventBufferingDurationKey:@(bufferingCompleted)}];
    }
    else if (playerItemStatus == AVPlayerItemStatusFailed) {
      AILOG_DEBUG(@"Player failed");
      dispatch_async(dispatch_get_main_queue(), ^{
        self.hasPlayed = false;
        self.isPlaying = false;
        [self.delegate videoPlaybackError];
        [ApplifierImpactInstrumentation gaInstrumentationVideoError:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign] withValuesFrom:nil];
        [self clearTimeOutTimer];
        [self clearVideoProgressMonitor];
      });
    }
    else if (playerItemStatus == AVPlayerItemStatusUnknown) {
      AILOG_DEBUG(@"Player in unknown state");
    }
  } else {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

#pragma mark Video progress

- (void)_videoProgressMonitor:(NSTimer *)timer {
  if(CMTIME_IS_INVALID(self.lastUpdate)) {
    self.lastUpdate = self.currentTime;
  } else {
    Float64 difference = CMTimeGetSeconds(CMTimeSubtract(self.currentTime, self.lastUpdate));
    AILOG_DEBUG(@"VIDEO MOVED: %f", difference);
    if(difference <= 0.001) {
      AILOG_DEBUG(@"VIDEO STALLED!");
      [self.delegate videoPlaybackStalled];
    } else {
      if(!self.hasMoved) {
        [self clearTimeOutTimer];
        self.hasMoved = true;
        self.isPlaying = true;
      }
      [self.delegate videoPlaybackStarted];
    }
    self.lastUpdate = self.currentTime;
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