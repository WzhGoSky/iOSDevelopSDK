//
//  HHIPAddress.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/13.
//  Copyright © 2019 Hayder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HHIPAddressTool : NSObject

+ (NSString *)deviceIPAdress;

+ (NSString *)getNetworkIPAddress;

@end

NS_ASSUME_NONNULL_END
