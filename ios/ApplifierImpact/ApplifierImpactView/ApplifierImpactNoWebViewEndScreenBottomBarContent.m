//
//  ApplifierImpactNoWebViewEndScreenBottomBarContent.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/18/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactNoWebViewEndScreenBottomBarContent.h"
#import "ApplifierImpactMainViewController.h"
#import "ApplifierImpactImageView.h"
#import "ApplifierImpactImageViewRoundedCorners.h"

#import "../ApplifierImpact.h"
#import "../ApplifierImpactProperties/ApplifierImpactConstants.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaignManager.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaign.h"


@interface ApplifierImpactNoWebViewEndScreenBottomBarContent ()
  @property (nonatomic, strong) ApplifierImpactImageViewRoundedCorners *gameIcon;
  @property (nonatomic, strong) UILabel *gameName;
@end

@implementation ApplifierImpactNoWebViewEndScreenBottomBarContent

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
      [self createGameIcon];
      [self createGameNameLabel];
      [self createDownloadButton];
      
      [self updateViewData];
      [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}


#pragma mark - Data update

- (void)updateViewData {
  AILOG_DEBUG(@"");
  
  ApplifierImpactCampaign *selectedCampaign = [[ApplifierImpactCampaignManager sharedInstance] selectedCampaign];
  
  if (self.gameIcon != nil && selectedCampaign != nil) {
    [self.gameIcon loadImageFromURL:selectedCampaign.gameIconURL];
  }
  if (self.gameName != nil && selectedCampaign != nil) {
    [self.gameName setText:selectedCampaign.gameName];
  }
}


#pragma mark - View creation

- (void)createGameNameLabel {
  if (self.gameName == nil && [[ApplifierImpactCampaignManager sharedInstance] selectedCampaign] != nil) {
    self.gameName = [[UILabel alloc] initWithFrame:CGRectMake(0, 11, self.frame.size.width - 65 - 15, 25)];
    self.gameName.transform = CGAffineTransformMakeTranslation(65 + 15, 11);
    self.gameName.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    [self.gameName setBackgroundColor:[UIColor clearColor]];
    [self.gameName setTextColor:[UIColor whiteColor]];
    UIColor *myShadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [self.gameName setShadowColor:myShadowColor];
    [self.gameName setShadowOffset:CGSizeMake(0, 2)];
    [self.gameName setFont:[UIFont boldSystemFontOfSize:20]];
    
    [self addSubview:self.gameName];
  }
}

- (void)createGameIcon {
  if (self.gameIcon == nil && [[ApplifierImpactCampaignManager sharedInstance] selectedCampaign] != nil) {
    int gameIconSize = 65;
    ApplifierImpactCampaign *selectedCampaign = [[ApplifierImpactCampaignManager sharedInstance] selectedCampaign];
    
    if (selectedCampaign.gameIconURL != nil) {
      self.gameIcon = [[ApplifierImpactImageViewRoundedCorners alloc] initWithFrame:CGRectMake(0, 0, gameIconSize, gameIconSize)];
      self.gameIcon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
      
      [self addSubview:self.gameIcon];
    }
  }
}

- (void)createDownloadButton {
  AILOG_DEBUG(@"");
  
  int buttonWidth = 200;
  int buttonHeight = 40;
  
  CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
  [[UIColor greenColor] getRed:&red green:&green blue:&blue alpha:&alpha];
  UIColor *myColor = [UIColor colorWithRed:red / 2 green:green / 2 blue:blue / 2 alpha:alpha];
  NSArray *gradientArray = [[NSArray alloc] initWithObjects:[UIColor greenColor], myColor, nil];
  
  UILabel *downloadButtonIcon = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 19, 25)];
  downloadButtonIcon.font = [UIFont boldSystemFontOfSize:26];
  [downloadButtonIcon setBackgroundColor:[UIColor clearColor]];
  [downloadButtonIcon setTextColor:[UIColor whiteColor]];
  [downloadButtonIcon setText:@"\u21ea"];
  downloadButtonIcon.transform = CGAffineTransformMakeRotation((180 / 180.0 * M_PI));
  
  self.downloadButton = [[ApplifierImpactNativeButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight) andBaseColors:gradientArray strokeColor:[UIColor clearColor] withCorner:UIRectCornerAllCorners withCornerRadius:10 withIcon:downloadButtonIcon];
  self.downloadButton.transform = CGAffineTransformMakeTranslation(65 + 10, 65 - 6);
  self.downloadButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
  
  UIColor *myShadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
  [downloadButtonIcon setShadowColor:myShadowColor];
  [downloadButtonIcon setShadowOffset:CGSizeMake(0, 1)];
  
  [self.downloadButton.titleLabel setShadowColor:myShadowColor];
  [self.downloadButton.titleLabel setShadowOffset:CGSizeMake(0, -1)];
  [self.downloadButton setTitle:@"    Download Free" forState:UIControlStateNormal];
  [self.downloadButton setUserInteractionEnabled:true];
  [self.downloadButton addTarget:self action:@selector(downloadButtonClicked) forControlEvents:UIControlEventTouchUpInside];
  
  [self addSubview:self.downloadButton];
  [self bringSubviewToFront:self.downloadButton];
}

- (void)downloadButtonClicked {
  AILOG_DEBUG(@"");
  NSDictionary *data = @{kApplifierImpactCampaignStoreIDKey:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].itunesID,
                         kApplifierImpactWebViewEventDataClickUrlKey:[[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].clickURL absoluteString],
                         kApplifierImpactCampaignIDKey:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].id};
  
  [[ApplifierImpactMainViewController sharedInstance] applyOptionsToCurrentState:data];
}

- (void)destroyView {
  
  if (self.gameIcon != nil) {
    if (self.gameIcon.superview != nil) {
      [self.gameIcon removeFromSuperview];
    }
    
    [self.gameIcon destroyView];
    self.gameIcon = nil;
  }
  
  if (self.downloadButton != nil) {
    if (self.downloadButton.superview != nil) {
      [self.downloadButton removeFromSuperview];
    }
    
    [self.downloadButton destroyView];
    self.downloadButton = nil;
  }

  if (self.gameName != nil) {
    if (self.gameName.superview != nil) {
      [self.gameName removeFromSuperview];
    }
    
    self.gameName = nil;
  }
}

@end
