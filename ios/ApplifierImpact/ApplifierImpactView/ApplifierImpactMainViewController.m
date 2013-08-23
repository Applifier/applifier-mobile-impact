//
//  ApplifierImpactAdViewController.m
//  ApplifierImpact
//
//  Created by bluesun on 11/21/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactMainViewController.h"

#import "../ApplifierImpactCampaign/ApplifierImpactCampaignManager.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaign.h"
#import "../ApplifierImpactDevice/ApplifierImpactDevice.h"
#import "../ApplifierImpactData/ApplifierImpactAnalyticsUploader.h"
#import "../ApplifierImpactProperties/ApplifierImpactProperties.h"

#import "../ApplifierImpactViewState/ApplifierImpactViewStateDefaultOffers.h"
#import "../ApplifierImpactViewState/ApplifierImpactViewStateDefaultVideoPlayer.h"
#import "../ApplifierImpactViewState/ApplifierImpactViewStateDefaultEndScreen.h"
#import "../ApplifierImpactViewState/ApplifierImpactViewStateDefaultSpinner.h"

#import "../ApplifierImpact.h"

@interface ApplifierImpactMainViewController ()
  @property (nonatomic, strong) ApplifierImpactViewState *currentViewState;
  @property (nonatomic, strong) ApplifierImpactViewState *previousViewState;
  @property (nonatomic, strong) NSMutableArray *viewStateHandlers;
@end

@implementation ApplifierImpactMainViewController

@synthesize currentViewState = _currentViewState;
@synthesize previousViewState = _previousViewState;
@synthesize viewStateHandlers = _viewStateHandlers;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  
    if (self) {
      // Add notification listener
      NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
      [notificationCenter addObserver:self selector:@selector(notificationHandler:) name:UIApplicationDidEnterBackgroundNotification object:nil];
      self.isClosing = false;
    }
  
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  if (self.isClosing && [[ApplifierImpactProperties sharedInstance] statusBarWasVisible]) {
    AILOG_DEBUG(@"Statusbar was originally visible. Bringing it back.");
    [[ApplifierImpactProperties sharedInstance] setStatusBarWasVisible:false];
    [[UIApplication sharedApplication] setStatusBarHidden:false];
  }
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  self.isClosing = false;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (![UIApplication sharedApplication].statusBarHidden) {
    AILOG_DEBUG(@"Hiding statusbar");
    [[ApplifierImpactProperties sharedInstance] setStatusBarWasVisible:true];
    [[UIApplication sharedApplication] setStatusBarHidden:true];
  }
}

- (BOOL)prefersStatusBarHidden {
  return YES;
}

#pragma mark - Orientation handling

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
  return YES;
}


#pragma mark - Public

- (void)applyViewStateHandler:(ApplifierImpactViewState *)viewState {
  if (viewState != nil) {
    viewState.delegate = self;
    if (self.viewStateHandlers == nil) {
      self.viewStateHandlers = [[NSMutableArray alloc] init];
    }
    [self.viewStateHandlers addObject:viewState];
  }
}

- (void)applyOptionsToCurrentState:(NSDictionary *)options {
  if (self.currentViewState != nil)
    [self.currentViewState applyOptions:options];
}

- (BOOL)hasState:(ApplifierImpactViewStateType)requestedState {
  for (ApplifierImpactViewState *currentState in self.viewStateHandlers) {
    if ([currentState getStateType] == requestedState) {
      return YES;
    }
  }
  
  return NO;
}

- (ApplifierImpactViewState *)selectState:(ApplifierImpactViewStateType)requestedState {
  self.currentViewState = nil;
  ApplifierImpactViewState *viewStateManager = nil;
  
  for (ApplifierImpactViewState *currentState in self.viewStateHandlers) {
    if ([currentState getStateType] == requestedState) {
      viewStateManager = currentState;
      break;
    }
  }
  
  if (viewStateManager != nil) {
    self.currentViewState = viewStateManager;
  }
  
  return self.currentViewState;
}

- (BOOL)changeState:(ApplifierImpactViewStateType)requestedState withOptions:(NSDictionary *)options {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self.currentViewState != nil && [[self currentViewState] getStateType] != requestedState) {
      [self.currentViewState exitState:options];
      self.previousViewState = self.currentViewState;
    }
    
    [self selectState:requestedState];
    
    if (self.currentViewState != nil) {
      [self.currentViewState enterState:options];
    }
  });
  
  if ([self hasState:requestedState]) {
    return YES;
  }
  
  return NO;
}

- (ApplifierImpactViewState *)getCurrentViewState {
  return self.currentViewState;
}

- (ApplifierImpactViewState *)getPreviousViewState {
  return self.previousViewState;
}

- (BOOL)closeImpact:(BOOL)forceMainThread withAnimations:(BOOL)animated withOptions:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  self.isClosing = true;
  
  if ([[ApplifierImpactProperties sharedInstance] currentViewController] == nil) return NO;
  
  if (forceMainThread) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self _dismissMainViewController:forceMainThread withAnimations:animated];
    });
  }
  else {
    [self _dismissMainViewController:forceMainThread withAnimations:animated];
  }
  
  
  return YES;
}

- (BOOL)openImpact:(BOOL)animated inState:(ApplifierImpactViewStateType)requestedState withOptions:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  if ([[ApplifierImpactProperties sharedInstance] currentViewController] == nil) return NO;

  [self selectState:requestedState];

  dispatch_async(dispatch_get_main_queue(), ^{
    if ([self hasState:requestedState]) {
      [self.currentViewState willBeShown];
      [self.delegate mainControllerWillOpen];
      [self changeState:requestedState withOptions:options];
      [[[ApplifierImpactProperties sharedInstance] currentViewController] presentViewController:self animated:animated completion:^{
        AILOG_DEBUG(@"Running openhandler after opening view");
        if (self.currentViewState != nil) {
          [self.currentViewState wasShown];
        }
        [self.delegate mainControllerDidOpen];
      }];
    };    
  });
  
  if (self.currentViewState != nil) {
    self.isOpen = YES;
  }
  
  return self.isOpen;
}

- (BOOL)mainControllerVisible {
  if (self.view.superview != nil || self.isOpen) {
    return YES;
  }
  
  return NO;
}


#pragma mark - Private

- (void)_dismissMainViewController:(BOOL)forcedToMainThread withAnimations:(BOOL)animated {

  if (!forcedToMainThread) {
    if (self.currentViewState != nil) {
      [self.currentViewState exitState:nil];
    }
  }

  [self.delegate mainControllerWillClose];

  [[[ApplifierImpactProperties sharedInstance] currentViewController] dismissViewControllerAnimated:animated completion:^{
    if (self.currentViewState != nil) {
      [self.currentViewState exitState:nil];
    }
    self.isOpen = NO;
    [self.delegate mainControllerDidClose];
  }];
}


#pragma mark - Notification receivers

- (void)notificationHandler: (id) notification {
  NSString *name = [notification name];

  AILOG_DEBUG(@"Notification: %@", name);
  
  if ([name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
    [self applyOptionsToCurrentState:@{kApplifierImpactNativeEventForceStopVideoPlayback:@true, @"sendAbortInstrumentation":@true, @"type":kApplifierImpactGoogleAnalyticsEventVideoAbortExit}];
    
    
    if (self.isOpen)
      [self closeImpact:NO withAnimations:NO withOptions:nil];
  }
}

- (void)stateNotification:(ApplifierImpactViewStateAction)action {
  AILOG_DEBUG(@"Got state action: %i", action);
  
  if (action == kApplifierImpactStateActionWillLeaveApplication) {
    if (self.delegate != nil) {
      [self.delegate mainControllerWillLeaveApplication];
    }
  }
  else if (action == kApplifierImpactStateActionVideoStartedPlaying) {
    if (self.delegate != nil) {
      [self.delegate mainControllerStartedPlayingVideo];
    }
  }
  else if (action == kApplifierImpactStateActionVideoPlaybackEnded) {
    if (self.delegate != nil) {
      [self.delegate mainControllerVideoEnded];
    }
  } else if (action == kApplifierImpactStateActionVideoPlaybackSkipped) {
    if (self.delegate != nil) {
      [self.delegate mainControllerVideoSkipped];
    }
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}


#pragma mark - Shared Instance

static ApplifierImpactMainViewController *sharedImpactMainViewController = nil;

+ (id)sharedInstance {
	@synchronized(self) {
		if (sharedImpactMainViewController == nil) {
      sharedImpactMainViewController = [[ApplifierImpactMainViewController alloc] initWithNibName:nil bundle:nil];
		}
	}
	
	return sharedImpactMainViewController;
}


#pragma mark - Lifecycle

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self applyOptionsToCurrentState:@{kApplifierImpactNativeEventForceStopVideoPlayback:@true}];
}

- (void)viewDidLoad {
  [self.view setBackgroundColor:[UIColor blackColor]];
  [super viewDidLoad];
}

@end