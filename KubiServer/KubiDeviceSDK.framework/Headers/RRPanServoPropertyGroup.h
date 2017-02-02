//
//  RRPanServoPropertyGroup.h
//  KubiDeviceSDK
//
//  Created by Oliver on 19/11/2015.
//  Copyright © 2015 Revolve Robotics Inc. All rights reserved.
//

#import "RRServoPropertyGroup.h"

typedef NS_ENUM(NSInteger, RRPanDirection)
{
	RRPanDirectionNone=2,
	RRPanDirectionStop=0,
	RRPanDirectionLeft=1,
	RRPanDirectionRight=-1
};

@interface RRPanServoPropertyGroup : RRServoPropertyGroup

@property (nonatomic, readonly, nonnull) NSNumber *	direction;

@end
