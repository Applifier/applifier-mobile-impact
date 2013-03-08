//
//  ApplifierImpactUnity3DWrapper.h
//  ApplifierImpactUnity
//
//  Created by Pekka Palmu on 3/8/13.
//  Copyright (c) 2013 Pekka Palmu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ApplifierImpact/ApplifierImpact.h>

void UnityPause(bool pause);

@interface ApplifierImpactUnity3DWrapper : NSObject <ApplifierImpactDelegate> {
    NSString *gameObjectName;
}
- (BOOL)initWithGameId:(const char *)gameId andWithGameObjectName:(const char *)gameObjectName;
@end