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
  @property (nonatomic, strong) NSArray *viewStateHandlers;
  @property (nonatomic, strong) ApplifierImpactViewState *currentViewState;
  @property (nonatomic, assign) BOOL isOpen;
@end

@implementation ApplifierImpactMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  
    if (self) {
      // Add notification listener
      NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
      [notificationCenter addObserver:self selector:@selector(notificationHandler:) name:UIApplicationDidEnterBackgroundNotification object:nil];
      
      // Start WebAppController
      [ApplifierImpactWebAppController sharedInstance];
      [[ApplifierImpactWebAppController sharedInstance] setDelegate:self];
    }
  
    return self;
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
    if (self.currentViewState != nil) {
      [self.currentViewState exitState:options];
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

- (BOOL)closeImpact:(BOOL)forceMainThread withAnimations:(BOOL)animated withOptions:(NSDictionary *)options {
  AILOG_DEBUG(@"");
  
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
  
  // FIX: TEST, DO NOT GENERATE LIST OF MANAGERS HERE
  if (self.viewStateHandlers == nil) {
    ApplifierImpactViewStateDefaultOffers *defaultOffers = [[ApplifierImpactViewStateDefaultOffers alloc] init];
    defaultOffers.delegate = self;
    ApplifierImpactViewStateDefaultVideoPlayer *defaultVideoPlayer = [[ApplifierImpactViewStateDefaultVideoPlayer alloc] init];
    defaultVideoPlayer.delegate = self;
    ApplifierImpactViewStateDefaultEndScreen *defaultEndScreen = [[ApplifierImpactViewStateDefaultEndScreen alloc] init];
    defaultEndScreen.delegate = self;
    ApplifierImpactViewStateDefaultSpinner *defaultSpinner = [[ApplifierImpactViewStateDefaultSpinner alloc] init];
    defaultSpinner.delegate = self;
    self.viewStateHandlers = [[NSArray alloc] initWithObjects:defaultOffers, defaultVideoPlayer, defaultEndScreen, defaultSpinner, nil];
  }
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [self selectState:requestedState];
    if (self.currentViewState != nil) {
      [self.delegate mainControllerWillOpen];
      [self.currentViewState willBeShown];
      [self changeState:requestedState withOptions:options];
      //[viewStateManager enterState];
      
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
      else {
        [self.delegate mainControllerDidOpen];
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
  if ([self.currentViewState getStateType] == kApplifierImpactViewStateTypeVideoPlayer) {
    [self dismissViewControllerAnimated:NO completion:nil];
  }
  
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
    // FIX: Find a better way to re-initialize when needed
    //[[ApplifierImpactWebAppController sharedInstance] setWebViewInitialized:NO];

    [self applyOptionsToCurrentState:@{kApplifierImpactNativeEventForceStopVideoPlayback:@true}];

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


#pragma mark - WebAppController

- (void)webAppReady {
  [self.delegate mainControllerWebViewInitialized];
  dispatch_async(dispatch_get_main_queue(), ^{
    [self checkForVersionAndShowAlertDialog];
    
    [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:kApplifierImpactWebViewViewTypeNone data:@{kApplifierImpactWebViewAPIActionKey:kApplifierImpactWebViewAPIInitComplete, kApplifierImpactItemKeyKey:[[ApplifierImpactCampaignManager sharedInstance] getCurrentRewardItem].key}];
  });
}

- (void)checkForVersionAndShowAlertDialog {
  if ([[ApplifierImpactProperties sharedInstance] expectedSdkVersion] != nil && ![[[ApplifierImpactProperties sharedInstance] expectedSdkVersion] isEqualToString:[[ApplifierImpactProperties sharedInstance] impactVersion]]) {
    AILOG_DEBUG(@"Got different sdkVersions, checking further.");
    
    if (![ApplifierImpactDevice isEncrypted]) {
      if ([ApplifierImpactDevice isJailbroken]) {
        AILOG_DEBUG(@"Build is not encrypted, but device seems to be jailbroken. Not showing version alert");
        return;
      }
      else {
        // Build is not encrypted and device is not jailbroken, alert dialog is shown that SDK is not the latest version.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Applifier Impact SDK"
                                                        message:@"The Applifier Impact SDK you are running is not the current version, please update your SDK"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
      }
    }
  }
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