//
//  ZYTLogLevel.h
//  ZYTSDK
//
//  Created by chenXu on 2019/1/6.
//  Copyright © 2019 DotC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ZYTLogLevel) {
    ZYTLogLevelAll   = 0,
    ZYTLogLevelTrace = 10,
    ZYTLogLevelDebug = 20,
    ZYTLogLevelInfo  = 30,
    ZYTLogLevelWarn  = 40,
    ZYTLogLevelError = 50,
    ZYTLogLevelOff   = 70
};


