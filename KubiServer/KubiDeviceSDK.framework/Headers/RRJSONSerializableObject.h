//
//  RRJSONObject.h
//  KubiDeviceSDK
//
//  Created by Oliver on 30/10/2015.
//  Copyright © 2015 Revolve Robotics Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RRJSONSerializableObject : NSObject

+(nullable id) createWithData:(id)data;
@property (nullable, nonatomic, readonly)	NSData *		jsonData;

// Override these methods to create a JSON serializable object
-(instancetype _Nullable) initWithJSONDictionary:(NSDictionary* _Nonnull)jsonObj;
-(nullable NSDictionary *) dictionaryForJSONSerialization;

@end

NS_ASSUME_NONNULL_END
