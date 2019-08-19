//
//  HHNetworkAPI.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/27.
//  Copyright © 2019 Hayder. All rights reserved.
//

#ifndef HHNetworkAPI_h
#define HHNetworkAPI_h

#import "Const.h"

#define HHBaseURL(APIName) SFDEBUG==0?[NSString stringWithFormat:@"http://47.92.210.235/api/%@",APIName]:[NSString stringWithFormat:@"https://api.jiangyinqixi.com/api/%@",APIName]

#endif
