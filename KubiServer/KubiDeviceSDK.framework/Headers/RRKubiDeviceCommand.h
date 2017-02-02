//
//  RRKubiDeviceCommand.h
//  KubiDeviceSDK
//
//  Created by Oliver on 19/11/2015.
//  Copyright © 2015 Revolve Robotics Inc. All rights reserved.
//

#import "RRDeviceCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface RRKubiDeviceCommand : RRDeviceCommand

+(instancetype) kubiCommandReturnToZero;

+(instancetype) kubiCommandSetPanAngle:(NSNumber *)pan;
+(instancetype) kubiCommandSetTiltAngle:(NSNumber *)tilt;
+(instancetype) kubiCommandAddPanAngle:(NSNumber *)pan;
+(instancetype) kubiCommandAddTiltAngle:(NSNumber *)tilt;

+(instancetype) kubiCommandSetPanAngle:(NSNumber *)pan andPanSpeed:(NSNumber *)panSpeed;
+(instancetype) kubiCommandAddPanAngle:(NSNumber *)pan andSetPanSpeed:(NSNumber *)panSpeed;

+(instancetype) kubiCommandSetTiltAngle:(NSNumber *)tilt andTiltSpeed:(NSNumber *)tiltSpeed;
+(instancetype) kubiCommandAddTiltAngle:(NSNumber *)tilt andSetTiltSpeed:(NSNumber *)tiltSpeed;

+(instancetype) kubiCommandSetPanAngle:(NSNumber *)pan andTiltAngle:(NSNumber *)tilt;

+(instancetype) kubiCommandSetPanAngle:(NSNumber *)pan andAddTiltAngle:(NSNumber *)tilt;
+(instancetype) kubiCommandAddPanAngle:(NSNumber *)pan andSetTiltAngle:(NSNumber *)tilt;

// Create a kubi command object and validate the command
+(nullable instancetype) kubiCommandWithCommand:(RRDeviceCommand *)command error:(NSError * _Nullable * _Nullable)err;

@end

NS_ASSUME_NONNULL_END
