//
//  RRKubiPropertyGroup.h
//  KubiDeviceSDK
//
//  Created by Oliver on 23/11/2015.
//  Copyright © 2015 Revolve Robotics Inc. All rights reserved.
//

#import "RRPropertyGroup.h"
#import "RRPanServoPropertyGroup.h"
#import "RRTiltServoPropertyGroup.h"

typedef NS_ENUM(NSInteger, RRKubiGesture)
{
	RRKubiGestureNone = 0,
	RRKubiGestureBow,
	RRKubiGestureNo,
	RRKubiGestureYes,
	RRKubiGestureScan,
	RRKubiGestureNod=RRKubiGestureYes,
	RRKubiGestureShake=RRKubiGestureNo
};

typedef NS_ENUM(NSInteger, RRKubiPowerState)
{
	RRKubiPowerStateUnknown=0,
	RRKubiPowerStateFull,
	RRKubiPowerStateOk,
	RRKubiPowerStateLow,
	RRKubiPowerStateCharging
};


@interface RRKubiPropertyGroup : RRPropertyGroup

@property (readonly, nonatomic) BOOL				synchronized;
@property (readonly, nonatomic)	RRKubiGesture		gesture;
@property (readonly, nonatomic)	RRKubiPowerState	powerState;

@property (readonly, nonnull)	RRPanServoPropertyGroup *	pan;
@property (readonly, nonnull)	RRTiltServoPropertyGroup *	tilt;

@end