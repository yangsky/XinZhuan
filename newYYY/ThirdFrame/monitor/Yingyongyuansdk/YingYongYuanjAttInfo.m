//
//  WjAppInfo.m
//  IosAdSdk
//
//  Created by xqzhang on 16/2/22.
//  Copyright © 2016年 IosAdSdk. All rights reserved.
//

#import "YingYongYuanjAttInfo.h"

@implementation YingYongYuanjAttInfo static YingYongYuanjAttInfo *instance = nil;

+ (YingYongYuanjAttInfo *) getInstance{
    
    @synchronized (self)
    {
        if (instance == nil)
        {
            Class clazz = NSClassFromString(@"YingYongYuanjAttInfoTest");
            instance  = [[clazz alloc] init];
        }
    }
    return instance;
}
@end
