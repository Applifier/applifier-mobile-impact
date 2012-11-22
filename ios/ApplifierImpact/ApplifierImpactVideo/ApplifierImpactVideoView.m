//
//  ApplifierImpactVideoView.m
//  ApplifierImpact
//
//  Created by bluesun on 11/21/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactVideoView.h"
#import "../ApplifierImpact.h"

@implementation ApplifierImpactVideoView

- (id)initWithFrame:(CGRect)frame {
  AILOG_DEBUG(@"");
  self = [super initWithFrame:frame];
  if (self) {
    [self setBackgroundColor:[UIColor blackColor]];
    // Initialization code
  }
  return self;
}

+ (Class)layerClass {
  return [AVPlayerLayer class];
}

- (AVPlayer*)player {
  return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
  [(AVPlayerLayer *)[self layer] setPlayer:player];
}

/* Specifies how the video is displayed within a player layer’s bounds.
 (AVLayerVideoGravityResizeAspect is default) */
- (void)setVideoFillMode:(NSString *)fillMode {
  AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
  playerLayer.videoGravity = fillMode;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end