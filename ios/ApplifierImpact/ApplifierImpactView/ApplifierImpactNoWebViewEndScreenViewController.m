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
  @property (nonatomic, strong) ApplifierImpactNativeButton *closeButton;
  @property (nonatomic, strong) ApplifierImpactNativeButton *rewatchButton;
  @property (nonatomic, strong) ApplifierImpactNativeButton *downloadButton;
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
    }
    return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self createBackgroundImage];
  [self createBottomBar];
  [self createCloseButton];
  [self createRewatchButton];
  [self createBottomBarContent];
  
  [self updateViewData];  
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  self.bottomBarContent.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
  [self checkRotation];
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
  
  CGRect size = [self calcBottomBarContentSize];
  
  if (!CGRectIsNull(size)) {
    [self.bottomBarContent setFrame:size];
  }
  else {
    AILOG_DEBUG(@"CGRect is NULL");
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

- (CGRect)calcBottomBarContentSize {
  ApplifierImpactCampaign *selectedCampaign = [[ApplifierImpactCampaignManager sharedInstance] selectedCampaign];
  
  if (selectedCampaign != nil) {
    int bottomBarContentHeight = 109;
    int gameIconSize = 65;
    int margin = 15;
    int downloadButtonWidth = 200;
    
    CGRect refRect = CGRectNull;
    
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
      refRect = CGRectMake(0, 0, fmin(self.view.frame.size.height, self.view.frame.size.width), fmax(self.view.frame.size.height, self.view.frame.size.width));
    }
    else {
      refRect = CGRectMake(0, 0, fmax(self.view.frame.size.height, self.view.frame.size.width), fmin(self.view.frame.size.height, self.view.frame.size.width));
    }
    
    NSString *testString = [NSString stringWithFormat:@"%@", selectedCampaign.gameName];
    CGSize size = [testString sizeWithFont:[UIFont boldSystemFontOfSize:20]];
    
    int requiredWidth = gameIconSize + margin + size.width;
    int minWidth = gameIconSize + margin + downloadButtonWidth;
    int usedWidth = fmax(requiredWidth, minWidth);
    int minSize = refRect.size.width;
    
    if (usedWidth > minSize - (margin * 2)) {
      usedWidth = minSize - (margin * 2);
    }
    
    return CGRectMake((refRect.size.width / 2) - (usedWidth / 2), refRect.size.height - bottomBarContentHeight, usedWidth, bottomBarContentHeight);
  }
  
  return CGRectNull;
}

- (void)createBottomBarContent {
  AILOG_DEBUG(@"");
  ApplifierImpactCampaign *selectedCampaign = [[ApplifierImpactCampaignManager sharedInstance] selectedCampaign];
  
  if (self.bottomBarContent == nil && self.bottomBar != nil && selectedCampaign != nil) {
    CGRect size = [self calcBottomBarContentSize];
    
    if (!CGRectIsNull(size)) {
      self.bottomBarContent = [[ApplifierImpactNoWebViewEndScreenBottomBarContent alloc] initWithFrame:size];
      self.bottomBarContent.autoresizingMask = UIViewAutoresizingNone;
      [self.view addSubview:self.bottomBarContent];
    }
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


#pragma mark - View clearing

- (void)destroyView {
  
  if (self.closeButton != nil) {
    if (self.closeButton.superview != nil) {
      [self.closeButton removeFromSuperview];
    }
    [self.closeButton destroyView];
    self.closeButton = nil;
  }
  
  if (self.rewatchButton != nil) {
    if (self.rewatchButton.superview != nil) {
      [self.rewatchButton removeFromSuperview];
    }
    [self.rewatchButton destroyView];
    self.rewatchButton = nil;
  }
  
  if (self.downloadButton != nil) {
    if (self.downloadButton.superview != nil) {
      [self.downloadButton removeFromSuperview];
    }
    [self.downloadButton destroyView];
    self.downloadButton = nil;
  }
  
  if (self.landScapeImage != nil) {
    if (self.landScapeImage.superview != nil) {
      [self.landScapeImage removeFromSuperview];
    }
    [self.landScapeImage destroyView];
    self.landScapeImage = nil;
  }
  
  if (self.portraitImage != nil) {
    if (self.portraitImage.superview != nil) {
      [self.portraitImage removeFromSuperview];
    }
    [self.portraitImage destroyView];
    self.portraitImage = nil;
  }
  
  if (self.bottomBarContent != nil) {
    if (self.bottomBarContent.superview != nil) {
      [self.bottomBarContent removeFromSuperview];
    }
    [self.bottomBarContent destroyView];
    self.bottomBarContent = nil;
  }
  
  if (self.bottomBar != nil) {
    if (self.bottomBar.superview != nil) {
      [self.bottomBar removeFromSuperview];
    }
    [self.bottomBar destroyView];
    self.bottomBar = nil;
  }
}

@end
