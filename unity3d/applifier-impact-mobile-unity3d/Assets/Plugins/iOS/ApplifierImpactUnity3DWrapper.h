#import <Foundation/Foundation.h>
#import <ApplifierImpact/ApplifierImpact.h>

extern UIViewController* UnityGetGLViewController();

@interface ApplifierImpactUnity3DWrapper : NSObject <ApplifierImpactDelegate> {
}

- (id)initWithGameId:(NSString*)gameId testModeOn:(bool)testMode debugModeOn:(bool)debugMode withGameObjectName:(NSString*)gameObjectName;

@end
