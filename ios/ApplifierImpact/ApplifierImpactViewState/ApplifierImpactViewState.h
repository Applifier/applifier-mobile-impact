//
//  ApplifierImpactViewState.h
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/4/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../ApplifierImpactProperties/ApplifierImpactConstants.h"

@protocol ApplifierImpactViewStateDelegate <NSObject>

@required
- (void)stateNotification:(ApplifierImpactViewStateAction)action;
@end

@interface ApplifierImpactViewState : NSObject

@property (nonatomic, assign) id<ApplifierImpactViewStateDelegate> delegate;

- (ApplifierImpactViewStateType)getStateType;

- (void)enterState:(NSDictionary *)options;
- (void)exitState:(NSDictionary *)options;

- (void)willBeShown;
- (void)wasShown;

- (void)applyOptions:(NSDictionary *)options;
@end
