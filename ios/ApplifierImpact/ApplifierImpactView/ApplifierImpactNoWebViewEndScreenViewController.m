//
//  ApplifierImpactNoWebViewEndScreenViewController.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/11/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactNoWebViewEndScreenViewController.h"
#import "ApplifierImpactMainViewController.h"
#import "ApplifierImpactImageView.h"
#import "ApplifierImpactNoWebViewEndScreenBottomBar.h"
#import "ApplifierImpactNativeButton.h"

#import "../ApplifierImpact.h"
#import "../ApplifierImpactProperties/ApplifierImpactConstants.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaignManager.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaign.h"
#import "../ApplifierImpactView/ApplifierImpactNoWebViewEndScreenBottomBarContent.h"

@interface ApplifierImpactNoWebViewEndScreenViewController ()
  @property (nonatomic, strong) UIButton *closeButton;
  @property (nonatomic, strong) UIButton *rewatchButton;
  @property (nonatomic, strong) UIButton *downloadButton;
  @property (nonatomic, strong) ApplifierImpactImageView *landScapeImage;
  @property (nonatomic, strong) ApplifierImpactImageView *portraitImage;
  @property (nonatomic, strong) ApplifierImpactNoWebViewEndScreenBottomBarContent *bottomBarContent;
  @property (nonatomic, strong) ApplifierImpactNoWebViewEndScreenBottomBar *bottomBar;
@end

@implementation ApplifierImpactNoWebViewEndScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      [self.view setBackgroundColor:[UIColor blackColor]];
      [self createBackgroundImage];
      [self createBottomBar];
      [self createCloseButton];
      [self createRewatchButton];
      [self createBottomBarContent];
      
      [self updateViewData];
    }
    return self;
}

- (void)initController {

}

- (void)viewDidLoad {
  [super viewDidLoad];

}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  [self checkRotation];
  return true;
}

- (BOOL)shouldAutorotate {
  [self checkRotation];
  return true;
}

- (void)checkRotation {
  if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) && self.portraitImage != nil) {
    [UIView beginAnimations:@"fade in" context:nil];
    [UIView setAnimationDuration:0.3];
    self.portraitImage.alpha = 1;
    [UIView commitAnimations];
  }
  else if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) && self.portraitImage != nil) {
    [UIView beginAnimations:@"fade out" context:nil];
    [UIView setAnimationDuration:0.3];
    self.portraitImage.alpha = 0;
    [UIView commitAnimations];
  }
}

#pragma mark - Data update

- (void)updateViewData {
  AILOG_DEBUG(@"");
  ApplifierImpactCampaign *selectedCampaign = [[ApplifierImpactCampaignManager sharedInstance] selectedCampaign];
  
  if (self.closeButton != nil) {
    [self.closeButton setTitle:[NSString stringWithFormat:@"\u00d7"] forState:UIControlStateNormal];
  }
  if (self.rewatchButton != nil) {
    [self.rewatchButton setTitle:[NSString stringWithFormat:@"\u21bb"] forState:UIControlStateNormal];
  }
  if (self.bottomBarContent != nil) {
    [self.bottomBarContent updateViewData];
  }
  if (self.landScapeImage != nil && selectedCampaign != nil && selectedCampaign.endScreenURL != nil) {
    [self.landScapeImage loadImageFromURL:selectedCampaign.endScreenURL applyScaling:true];
  }
  if (self.portraitImage != nil && selectedCampaign != nil && selectedCampaign.endScreenPortraitURL != nil) {
    [self.portraitImage loadImageFromURL:selectedCampaign.endScreenPortraitURL applyScaling:true];
  }
}


#pragma mark - Button actions

- (void)rewatchButtonClicked {
  AILOG_DEBUG(@"");
  
  if ([[ApplifierImpactCampaignManager sharedInstance] selectedCampaign] != nil) {
    NSDictionary *data = @{kApplifierImpactWebViewEventDataRewatchKey:@true,
                           kApplifierImpactWebViewEventDataCampaignIdKey:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].id};
    [[ApplifierImpactMainViewController sharedInstance] changeState:kApplifierImpactViewStateTypeVideoPlayer withOptions:data];
  }
}

- (void)closeButtonClicked {
  AILOG_DEBUG(@"");
  [[ApplifierImpactMainViewController sharedInstance] closeImpact:YES withAnimations:YES withOptions:nil];
}


#pragma mark - View creation

- (void)createBottomBarContent {
  if (self.bottomBarContent == nil && self.bottomBar != nil) {
    int bottomBarContentHeight = 109;
    CGRect refRect = [[ApplifierImpactMainViewController sharedInstance] view].window.frame;

    self.bottomBarContent = [[ApplifierImpactNoWebViewEndScreenBottomBarContent alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - (refRect.size.width / 2), self.view.frame.size.height - bottomBarContentHeight, refRect.size.width, bottomBarContentHeight)];

    self.bottomBarContent.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.bottomBarContent];
  }
}

- (void)createBottomBar {
  if (self.bottomBar == nil) {
    int bottomBarHeight = 100;
    int bottomBarWidth = self.view.frame.size.height;
    if (self.view.frame.size.width > bottomBarWidth)
      bottomBarWidth = self.view.frame.size.width;
    
    self.bottomBar = [[ApplifierImpactNoWebViewEndScreenBottomBar alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - (bottomBarWidth / 2),
                                                                                                  self.view.frame.size.height - bottomBarHeight,
                                                                                                  bottomBarWidth,
                                                                                                  bottomBarHeight)];
    self.bottomBar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.bottomBar];
  }
}

- (void)createBackgroundImage {
  if ([[ApplifierImpactCampaignManager sharedInstance] selectedCampaign] != nil) {
    ApplifierImpactCampaign *selectedCampaign = [[ApplifierImpactCampaignManager sharedInstance] selectedCampaign];
    
    if (self.landScapeImage == nil) {
      self.landScapeImage = [[ApplifierImpactImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.window.frame.size.width, self.view.window.frame.size.height)];
      
      [self.view addSubview:self.landScapeImage];
    }
    
    if (self.portraitImage == nil && selectedCampaign.endScreenPortraitURL != nil) {
      self.portraitImage = [[ApplifierImpactImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.window.frame.size.width, self.view.window.frame.size.height)];
      
      [self.view addSubview:self.portraitImage];
      self.portraitImage.alpha = 0;
      
      if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        self.portraitImage.alpha = 1;
      }
    }
  }
}

- (void)createCloseButton {
  AILOG_DEBUG(@"");
  
  int buttonWidth = 50;
  int buttonHeight = 50;
  
  UIColor *myColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
  NSArray *gradientArray = [[NSArray alloc] initWithObjects:myColor, myColor, nil];
  
  self.closeButton = [[ApplifierImpactNativeButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight) andBaseColors:gradientArray strokeColor:[UIColor whiteColor] withCorner:UIRectCornerBottomLeft withCornerRadius:23];
  
  self.closeButton.transform = CGAffineTransformMakeTranslation(0, 0);
  self.closeButton.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width - 47, -3);
  self.closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
  
  [self.closeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:33]];
  [self.view addSubview:self.closeButton];
  [self.closeButton addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)createRewatchButton {
  AILOG_DEBUG(@"");
  
  int buttonWidth = 50;
  int buttonHeight = 50;
  
  UIColor *myColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
  NSArray *gradientArray = [[NSArray alloc] initWithObjects:myColor, myColor, nil];
  
  self.rewatchButton = [[ApplifierImpactNativeButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight) andBaseColors:gradientArray strokeColor:[UIColor whiteColor] withCorner:UIRectCornerBottomRight withCornerRadius:23];
  
  self.rewatchButton.transform = CGAffineTransformMakeTranslation(0, 0);
  self.rewatchButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
  self.rewatchButton.transform = CGAffineTransformMakeTranslation(-3, -3);
  
  [self.rewatchButton.titleLabel setFont:[UIFont boldSystemFontOfSize:30]];
  [self.view addSubview:self.rewatchButton];
  [self.rewatchButton addTarget:self action:@selector(rewatchButtonClicked) forControlEvents:UIControlEventTouchUpInside];
}

@end
