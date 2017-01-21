//
//  RRKubi.h
//  KubiDeviceSDK
//
//  Created by Oliver on 28/10/2015.
//  Copyright © 2015 Revolve Robotics Inc. All rights reserved.
//

#import "RRDevice.h"

#import <UIKit/UIColor.h>
#import "RRPanServoPropertyGroup.h"
#import "RRTiltServoPropertyGroup.h"
#import "RRKubiPropertyGroup.h"


NS_ASSUME_NONNULL_BEGIN

@interface RRKubi : RRDevice

// Local Kubi Interface
-(BOOL) absoluteMoveToPan:(NSNumber * _Nullable)pan
			   atPanSpeed:(NSNumber * _Nullable)panSpeed
				  andTilt:(NSNumber * _Nullable)tilt
			  atTiltSpeed:(NSNumber * _Nullable)tiltSpeed
					error:(NSError * _Nullable * _Nullable)error;


-(BOOL) incrementalMoveWithPanDelta:(NSNumber * _Nullable)pan
						 atPanSpeed:(NSNumber * _Nullable)panSpeed
					   andTiltDelta:(NSNumber * _Nullable)tilt
						atTiltSpeed:(NSNumber * _Nullable)tiltSpeed
							  error:(NSError * _Nullable * _Nullable)error;


-(BOOL) moveInPanDirection:(RRPanDirection)panDirection
				atPanSpeed:(NSNumber * _Nullable)panSpeed
					 error:(NSError * _Nullable * _Nullable)error;


-(BOOL) moveInTiltDirection:(RRTiltDirection)tiltDirection
				atTiltSpeed:(NSNumber * _Nullable)tiltSpeed
					  error:(NSError * _Nullable * _Nullable)error;


//-(BOOL) performGesture:(RRKubiGesture)gesture
//				 error:(NSError * _Nullable * _Nullable)error;
//
//
//-(BOOL) performGestureWithName:(NSString *)name
//						 error:(NSError * _Nullable * _Nullable)error;


//-(BOOL) setPanEnabled:(NSNumber *)enablePan error:(NSError * _Nullable * _Nullable)error;
-(BOOL) setPanEnabled:(BOOL)enablePan		error:(NSError * _Nullable * _Nullable)error;
-(BOOL) setTiltEnabled:(BOOL)enableTilt		error:(NSError * _Nullable * _Nullable)error;

//-(BOOL) setIndicatorColor:(uint32_t)color
//					error:(NSError * _Nullable * _Nullable)error;

@property (nonatomic)				BOOL						synchronized;

@property (readonly, nonnull)		RRPanServoPropertyGroup *	pan;
@property (readonly, nonnull)		RRTiltServoPropertyGroup *	tilt;

//@property (nonatomic, readonly)	RRKubiPowerState	powerState;
//@property (nonatomic, readonly)	UIColor*			indicatorColor;
@property (nonatomic, readonly)		RRKubiGesture				gesture;
@property (nonatomic, readonly)		BOOL						buttonIsPressed;


/********************************************************************************
  Saved Positions
 
  Position is an NSDictionary with keys "pan" and "tilt", each with a value of 
  type NSNumber.
 
  "pan" is a double value between -150.0 and 150.0.
 
  "tilt" is a double value between -45.0 and 45.0.
 
********************************************************************************/
- (NSArray *) allSavedPositions;
- (NSDictionary *) savedPositionAtIndex: (NSInteger)index;

- (void) addSavedPosition: (NSDictionary *)positionInfo;
- (void) removeSavedPositionsAtIndex: (NSInteger)index;

- (void) goToSavedPositionAtIndex: (NSInteger)index;
 

NS_ASSUME_NONNULL_END

@end
