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
  @property (nonatomic, strong) void (^closeHandler)(void);
  @property (nonatomic, strong) void (^openHandler)(void);
  @property (nonatomic, strong) ApplifierImpactViewState *currentViewState;
  @property (nonatomic, strong) ApplifierImpactViewState *previousViewState;
  @property (nonatomic, strong) NSMutableArray *viewStateHandlers;
  @property (nonatomic, assign) BOOL simulatorOpeningSupportCallSent;
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
      self.simulatorOpeningSupportCallSent = false;
      self.isClosing = false;
    }
  
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if ([ApplifierImpactDevice isSimulator] && !self.simulatorOpeningSupportCallSent) {
    AILOG_DEBUG(@"");
    self.simulatorOpeningSupportCallSent = true;
    [self.currentViewState wasShown];
    [self.delegate mainControllerDidOpen];
  }
}

- (void)viewDidDisappear:(BOOL)animated {
  self.isClosing = false;
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
  
  if ([ApplifierImpactDevice isSimulator]) {
    self.simulatorOpeningSupportCallSent = false;
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
      
      if (![ApplifierImpactDevice isSimulator]) {
        if (self.openHandler == nil) {
          __unsafe_unretained typeof(self) weakSelf = self;
          
          self.openHandler = ^(void) {
            AILOG_DEBUG(@"Running openhandler after opening view");
            if (weakSelf != NULL) {
              if (weakSelf.currentViewState != nil) {
                [weakSelf.currentViewState wasShown];
              }
              [weakSelf.delegate mainControllerDidOpen];
            }
          };
        }
      }
      
      [[[ApplifierImpactProperties sharedInstance] currentViewController] presentViewController:self animated:animated completion:self.openHandler];
    }
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
  
  if (![ApplifierImpactDevice isSimulator]) {
    if (self.closeHandler == nil) {
      __unsafe_unretained typeof(self) weakSelf = self;
      self.closeHandler = ^(void) {
        if (weakSelf != NULL) {
          if (weakSelf.currentViewState != nil) {
            [weakSelf.currentViewState exitState:nil];
          }
          weakSelf.isOpen = NO;
          [weakSelf.delegate mainControllerDidClose];
        }
      };
    }
  }
  else {
    self.isOpen = NO;
    [self.delegate mainControllerDidClose];
  }
  
  [[[ApplifierImpactProperties sharedInstance] currentViewController] dismissViewControllerAnimated:animated completion:self.closeHandler];
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