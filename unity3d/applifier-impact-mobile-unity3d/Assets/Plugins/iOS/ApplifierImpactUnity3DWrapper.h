//
//  ApplifierImpactUnity3DWrapper.h
//  ApplifierImpactUnity
//
//  Created by Pekka Palmu on 3/8/13.
//  Copyright (c) 2013 Pekka Palmu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ApplifierImpact/ApplifierImpact.h>

extern UIViewController* UnityGetGLViewController();

@interface ApplifierImpactUnity3DWrapper : NSObject <ApplifierImpactDelegate> {
}

- (id)initWithGameId:(NSString*)gameId testModeOn:(bool)testMode debugModeOn:(bool)debugMode withGameObjectName:(NSString*)gameObjectName useNativeUI:(bool)useNativeWhenPossible;

@end