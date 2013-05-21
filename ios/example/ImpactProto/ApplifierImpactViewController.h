//
//  ApplifierImpactViewController.h
//  ImpactProto
//
//  Created by bluesun on 7/30/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ApplifierImpactViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIButton *startButton;
@property (nonatomic, retain) IBOutlet UIButton *openButton;
@property (nonatomic, retain) IBOutlet UIButton *optionsButton;
@property (nonatomic, retain) IBOutlet UIView *optionsView;
@property (nonatomic, retain) IBOutlet UITextField *developerId;
@property (nonatomic, retain) IBOutlet UITextField *optionsId;
@property (nonatomic, retain) IBOutlet UILabel *instructionsText;

@property (nonatomic, retain) IBOutlet UIImageView *loadingImage;
@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) IBOutlet UISwitch *webviewSwitch;

@end
