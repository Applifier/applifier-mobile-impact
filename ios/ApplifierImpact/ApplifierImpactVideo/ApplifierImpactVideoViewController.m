//
//  ApplifierImpactVideoViewController.m
//  ApplifierImpact
//
//  Created by bluesun on 11/26/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "../ApplifierImpact.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaignManager.h"
#import "ApplifierImpactVideoViewController.h"
#import "ApplifierImpactVideoPlayer.h"
#import "ApplifierImpactVideoView.h"
#import "../ApplifierImpactProperties/ApplifierImpactShowOptionsParser.h"
#import "../ApplifierImpactProperties/ApplifierImpactProperties.h"
#import "ApplifierImpactVideoMuteButton.h"
#import "../ApplifierImpactBundle/ApplifierImpactBundle.h"
#import "../ApplifierImpactView/ApplifierImpactMainViewController.h"

@interface ApplifierImpactVideoViewController ()
  @property (nonatomic, strong) ApplifierImpactVideoView *videoView;
  @property (nonatomic, strong) ApplifierImpactVideoPlayer *videoPlayer;
  @property (nonatomic, assign) ApplifierImpactCampaign *campaignToPlay;
  @property (nonatomic, strong) UILabel *progressLabel;
  @property (nonatomic, strong) UIButton *skipLabel;
  @property (nonatomic, strong) UIView *videoOverlayView;
  @property (nonatomic, assign) dispatch_queue_t videoControllerQueue;
  @property (nonatomic, strong) NSURL *currentPlayingVideoUrl;
  @property (nonatomic, strong) ApplifierImpactVideoMuteButton *muteButton;
  @property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation ApplifierImpactVideoViewController

@synthesize muteButton = _muteButton;
@synthesize isMuted = _isMuted;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      self.videoControllerQueue = dispatch_queue_create("com.applifier.impact.videocontroller", NULL);
      self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
      self.isPlaying = NO;
      self.isMuted = NO;
    }
    return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.view setBackgroundColor:[UIColor blackColor]];
  self.view.clipsToBounds = true;
  
  if (self.delegate != nil) {
    [self.delegate videoPlayerReady];
  }
  self.tapGestureRecognizer.cancelsTouchesInView = NO;
  [self.view addGestureRecognizer:self.tapGestureRecognizer];
  self.tapGestureRecognizer.delegate = self;
  self.muteButton = [[ApplifierImpactVideoMuteButton alloc] initWithIcon:[ApplifierImpactBundle imageWithName:@"audio_on" ofType:@"png"] title:@""];
  [self.muteButton setImage:[ApplifierImpactBundle imageWithName:@"audio_mute" ofType:@"png"] forState:UIControlStateSelected];

  [self.muteButton addTarget:self action:@selector(muteVideoButtonPressed:) forControlEvents:UIControlEventTouchDown];  
  [self _attachVideoView];
}

- (void)dealloc {
  AILOG_DEBUG(@"dealloc");
  dispatch_release(self.videoControllerQueue);
}

- (void) handleTapFrom: (UITapGestureRecognizer *)recognizer
{
  // TODO: Show controlls
    [self showOverlay];
  AILOG_DEBUG(@"SHOW CONTROLLS");
}

- (void)viewDidDisappear:(BOOL)animated {
  [self _detachVideoPlayer];
  [self _detachVideoView];
  [self _destroyVideoPlayer];
  [self _destroyVideoView];
  
  [self destroyProgressLabel];
  [self destroyVideoSkipLabel];
  [self destroyVideoOverlayView];
  
  [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self _makeOrientation];
  
  [self createVideoOverlayView];
  [self createProgressLabel];
  [self createVideoSkipLabel];
  
  [self.view bringSubviewToFront:self.videoOverlayView];
}

-(void)muteVideoButtonPressed:(id)sender {
    AVPlayerItem *item = [self.videoPlayer currentItem];
    AVMutableAudioMix *audioZeroMix = nil;
    NSArray *audioTracks = [item.asset tracksWithMediaType:AVMediaTypeAudio];
    NSMutableArray *allAudioParams = [NSMutableArray array];

    for (AVAssetTrack *track in audioTracks) {
      AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParameters];
      [audioInputParams setVolume:!self.isMuted ? 0.0f : 1.0f atTime:kCMTimeZero];
      [audioInputParams setTrackID:[track trackID]];
      [allAudioParams addObject:audioInputParams];
    }

    audioZeroMix = [AVMutableAudioMix audioMix];
    [audioZeroMix setInputParameters:allAudioParams];
    [item setAudioMix:audioZeroMix];
    self.isMuted = !self.isMuted;
    self.muteButton.selected = self.isMuted;
}

- (void)_makeOrientation {
  if (![[ApplifierImpactShowOptionsParser sharedInstance] useDeviceOrientationForVideo]) {
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
      double maxValue = fmax(self.view.superview.bounds.size.width, self.view.superview.bounds.size.height);
      double minValue = fmin(self.view.superview.bounds.size.width, self.view.superview.bounds.size.height);
      self.view.bounds = CGRectMake(0, 0, maxValue, minValue);
      self.view.transform = CGAffineTransformMakeRotation(M_PI / 2);
      AILOG_DEBUG(@"NEW DIMENSIONS: %f, %f", minValue, maxValue);
    }
  }
  [self.muteButton setFrame:CGRectMake(0.0f, self.view.bounds.size.height - self.muteButton.bounds.size.height + 16, self.muteButton.frame.size.width, self.muteButton.frame.size.height)];
  AILOG_DEBUG("Mutebutton frame: %f x %f - %f x %f",self.muteButton.frame.size.height,self.muteButton.frame.size.width,self.muteButton.frame.origin.x,self.muteButton.frame.origin.y);
  
  // Position in lower left corner.

  if (self.videoView != nil) {
    [self.videoView setFrame:self.view.bounds];
  }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  if ([[ApplifierImpactShowOptionsParser sharedInstance] useDeviceOrientationForVideo]) {
    return YES;
  }
  return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
  if ([[ApplifierImpactShowOptionsParser sharedInstance] useDeviceOrientationForVideo]) {
    return YES;
  }
  return NO;
}


#pragma mark - Public

- (void)playCampaign:(ApplifierImpactCampaign *)campaignToPlay {
  AILOG_DEBUG(@"");
  NSURL *videoURL = [[ApplifierImpactCampaignManager sharedInstance] getVideoURLForCampaign:campaignToPlay];
  
	if (videoURL == nil) {
		AILOG_DEBUG(@"Video not found!");
		return;
	}
  
  self.campaignToPlay = campaignToPlay;
  self.currentPlayingVideoUrl = videoURL;
  
  AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.currentPlayingVideoUrl options:nil];
  AVMutableAudioMix *audioZeroMix = nil;
  
  if ([[ApplifierImpactShowOptionsParser sharedInstance] muteVideoSounds]) {
    NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    NSMutableArray *allAudioParams = [NSMutableArray array];
    
    for (AVAssetTrack *track in audioTracks) {
      AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParameters];
      [audioInputParams setVolume:0.0 atTime:kCMTimeZero];
      [audioInputParams setTrackID:[track trackID]];
      [allAudioParams addObject:audioInputParams];
    }
    
    audioZeroMix = [AVMutableAudioMix audioMix];
    [audioZeroMix setInputParameters:allAudioParams];
  }
  
  AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
  
  if ([[ApplifierImpactShowOptionsParser sharedInstance] muteVideoSounds]) {
    [item setAudioMix:audioZeroMix];
  }
  
  [self _createVideoView];
  [self _createVideoPlayer];
  [self _attachVideoPlayer];
  [self.videoPlayer preparePlayer];
  
  dispatch_async(self.videoControllerQueue, ^{
    [self.videoPlayer replaceCurrentItemWithPlayerItem:item];
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.videoPlayer playSelectedVideo];
    });
  });
}


#pragma mark - Video View

- (void)_createVideoView {
  if (self.videoView == nil) {
    self.videoView = [[ApplifierImpactVideoView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.videoView setVideoFillMode:AVLayerVideoGravityResizeAspect];
    self.videoView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  }
}

- (void)_attachVideoView {
  if (self.videoView != nil && ![self.videoView.superview isEqual:self.view]) {
    [self.view addSubview:self.videoView];
  }
}

- (void)_detachVideoView {
  if (self.videoView != nil && self.videoView.superview != nil) {
    [self.videoView removeFromSuperview];
  }
}

- (void)_destroyVideoView {
  if (self.videoView != nil) {
    [self _detachVideoView];
    self.videoView = nil;
  }
}


#pragma mark - Video player

- (void)forceStopVideoPlayer {
  AILOG_DEBUG(@"");
  // FIX: Wrong order?
  [self _detachVideoPlayer];
  [self _destroyVideoPlayer];
}

- (void)_createVideoPlayer {
  if (self.videoPlayer == nil) {
    AILOG_DEBUG(@"");
    self.videoPlayer = [[ApplifierImpactVideoPlayer alloc] initWithPlayerItem:nil];
    self.videoPlayer.delegate = self;
  }
}

- (void)_attachVideoPlayer {
  if (self.videoView != nil) {
    [self.videoView setPlayer:self.videoPlayer];
  }
}

- (void)_destroyVideoPlayer {
  if (self.videoPlayer != nil) {
    AILOG_DEBUG(@"");
    self.currentPlayingVideoUrl = nil;
    [self.videoPlayer clearPlayer];
    self.videoPlayer.delegate = nil;
    self.videoPlayer = nil;
  }
}

- (void)_detachVideoPlayer {
  [self.videoView setPlayer:nil];
}

- (void)videoPositionChanged:(CMTime)time {
  [self updateLabelsWithCMTime:time];
}

- (void)videoPlaybackStarted {
  AILOG_DEBUG(@"");
}

- (void)videoStartedPlaying {
  AILOG_DEBUG(@"");
  self.isPlaying = YES;
  [self.delegate videoPlayerStartedPlaying];
}

- (void)videoPlaybackEnded {
  AILOG_DEBUG(@"");
  //self.campaignToPlay.viewed = YES;
  
  if (self.delegate == nil) {
    AILOG_DEBUG(@"ALERT DELEGATE IS NIL");
  }
  
  [self.delegate videoPlayerPlaybackEnded];
  self.isPlaying = NO;
  self.campaignToPlay = nil;
}

- (void)videoPlaybackError {
  AILOG_DEBUG(@"");
  [self.delegate videoPlayerEncounteredError];
  self.isPlaying = NO;
}


#pragma mark - Video Overlay View

- (void)createVideoOverlayView {
  if (self.videoOverlayView == nil) {
    self.videoOverlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.videoOverlayView setBackgroundColor:[UIColor clearColor]];
    self.videoOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.videoOverlayView];
    [self.view bringSubviewToFront:self.videoOverlayView];
  }
}

- (void)destroyVideoOverlayView {
  if (self.videoOverlayView != nil) {
    [self.videoOverlayView removeFromSuperview];
    self.videoOverlayView = nil;
  }
}


#pragma mark - Video Skip Label

- (void)createVideoSkipLabel {
  if (self.skipLabel == nil && self.videoOverlayView != nil && [[ApplifierImpactProperties sharedInstance] allowVideoSkipInSeconds] > 0) {
    AILOG_DEBUG(@"Create video skip label");
    self.skipLabel = [[UIButton alloc] initWithFrame:CGRectMake(3, 0, 205, 20)];
    self.skipLabel.backgroundColor = [UIColor clearColor];
    self.skipLabel.titleLabel.textColor = [UIColor whiteColor];
    self.skipLabel.titleLabel.font = [UIFont systemFontOfSize:12.0];
    self.skipLabel.titleLabel.textAlignment = UITextAlignmentLeft;
    [self.skipLabel setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.skipLabel setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    self.skipLabel.titleLabel.shadowColor = [UIColor blackColor];
    self.skipLabel.titleLabel.shadowOffset = CGSizeMake(0, 1.0);
    //self.skipLabel.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width - 303, self.view.bounds.size.height - 23);
    
    [self.videoOverlayView addSubview:self.skipLabel];
    [self.videoOverlayView bringSubviewToFront:self.skipLabel];
    self.videoOverlayView.hidden = NO;
  }
}

- (void)destroyVideoSkipLabel {
  if (self.skipLabel != nil) {
    [self.skipLabel removeFromSuperview];
    self.skipLabel = nil;
  }
}



- (void)skipButtonPressed {
  AILOG_DEBUG(@"");
  [self videoPlaybackEnded];
  [[ApplifierImpactMainViewController sharedInstance] applyOptionsToCurrentState:@{@"sendAbortInstrumentation":@true, @"type":kApplifierImpactGoogleAnalyticsEventVideoAbortSkip}];
}


#pragma mark - Video Progress Label

- (void)createProgressLabel {
  AILOG_DEBUG(@"");

  if (self.progressLabel == nil && self.videoOverlayView != nil) {
    self.progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 303, self.view.bounds.size.height - 23, 300, 20)];
    self.progressLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    self.progressLabel.backgroundColor = [UIColor clearColor];
    self.progressLabel.textColor = [UIColor whiteColor];
    self.progressLabel.font = [UIFont systemFontOfSize:12.0];
    self.progressLabel.textAlignment = UITextAlignmentRight;
    self.progressLabel.shadowColor = [UIColor blackColor];
    self.progressLabel.shadowOffset = CGSizeMake(0, 1.0);
    

    
    [self.videoOverlayView addSubview:self.progressLabel];
    [self.videoOverlayView bringSubviewToFront:self.progressLabel];
    [self.videoOverlayView addSubview:self.muteButton];
    [self.videoOverlayView bringSubviewToFront:self.muteButton];

    self.videoOverlayView.hidden = NO;
  }
}

- (void)destroyProgressLabel {
  if (self.progressLabel != nil) {
    [self.progressLabel removeFromSuperview];
    self.progressLabel = nil;
  }
}

- (void)updateLabelsWithCMTime:(CMTime)currentTime {
	Float64 duration = [self _currentVideoDuration];
	Float64 current = CMTimeGetSeconds(currentTime);
  Float64 timeLeft = duration - current;
  Float64 timeUntilSkip = -1;
  if ([[ApplifierImpactProperties sharedInstance] allowVideoSkipInSeconds] > 0) {
    timeUntilSkip = [[ApplifierImpactProperties sharedInstance] allowVideoSkipInSeconds] - current;
  }
  
  if (timeLeft < 0)
    timeLeft = 0;
  
  if (timeUntilSkip > -1) {
    if (timeUntilSkip < 0)
      timeUntilSkip = 0;
    
    NSString *skipText = [NSString stringWithFormat:NSLocalizedString(@"You can skip this video in %.0f seconds.", nil), timeUntilSkip];
    
    if (timeUntilSkip == 0) {
      skipText = [NSString stringWithFormat:@"Skip Video"];
      NSArray *actions = [self.skipLabel actionsForTarget:self forControlEvent:UIControlEventTouchUpInside];
      
      BOOL actionAdded = false;
      
      for (NSString *action in actions) {
        if ([action isEqualToString:@"skipButtonPressed"]) {
          actionAdded = true;
          break;
        }
      }
      
      if (!actionAdded) {
        [self hideOverlayAfter:3.0f];
        [self.skipLabel addTarget:self action:@selector(skipButtonPressed) forControlEvents:UIControlEventTouchUpInside];
      }
    }
    
    if (self.skipLabel != nil) {
      [self.skipLabel setTitle:skipText forState:UIControlStateNormal];
    }
  } else {
    [self hideOverlayAfter:3.0f];
  }
  
	NSString *descriptionText = [NSString stringWithFormat:NSLocalizedString(@"This video ends in %.0f seconds.", nil), timeLeft];
	self.progressLabel.text = descriptionText;
}

- (Float64)_currentVideoDuration {
  CMTime durationTime = self.videoPlayer.currentItem.asset.duration;
	Float64 duration = CMTimeGetSeconds(durationTime);
	
	return duration;
}

- (NSValue *)_valueWithDuration:(Float64)duration {
  CMTime time = CMTimeMakeWithSeconds(duration, NSEC_PER_SEC);
	return [NSValue valueWithCMTime:time];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
  if ([touch.view isKindOfClass:[UIControl class]]) {
    return NO; // ignore the touch
  }
  return YES; // handle the touch
}


- (void) showOverlay {
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:1.0];
  [self.videoOverlayView setAlpha:1.0f];
  [UIView commitAnimations];
}

- (void) hideOverlay {
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:1.0];
  [self.videoOverlayView setAlpha:0.0f];
  [UIView commitAnimations];
}

- (void) hideOverlayAfter:(CGFloat)seconds {
  // do not double fire.
  if(self.videoOverlayView.alpha == 1.0f) {
    self.videoOverlayView.alpha = 0.99999f;
    [self performSelector:@selector(hideOverlay) withObject:nil afterDelay:seconds];
  }
}


@end