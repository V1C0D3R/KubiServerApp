//
//  RRTiltServoPropertyGroup.h
//  KubiDeviceSDK
//
//  Created by Oliver on 19/11/2015.
//  Copyright © 2015 Revolve Robotics Inc. All rights reserved.
//

#import "RRServoPropertyGroup.h"

typedef NS_ENUM(NSInteger, RRTiltDirection)
{
	RRTiltDirectionNone=2,
	RRTiltDirectionStop=0,
	RRTiltDirectionUp=1,
	RRTiltDirectionDown=-1,
};

@interface RRTiltServoPropertyGroup : RRServoPropertyGroup

@property (nonatomic, readonly, nonnull) NSNumber *	direction;

@end