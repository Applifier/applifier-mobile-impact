//
//  ApplifierImpactViewController.h
//  ImpactProto
//
//  Created by bluesun on 7/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ApplifierImpactViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIButton *buttonView;
@property (nonatomic, retain) IBOutlet UIImageView *loadingImage;
@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic) int currentPhase;
@property (nonatomic, retain) AVPlayer *avPlayer;
@property (nonatomic, retain) AVPlayerLayer *avPlayerLayer;
@property (nonatomic, retain) AVAsset *avAsset;
@property (nonatomic, retain) AVPlayerItem *avPlayerItem;

@end
