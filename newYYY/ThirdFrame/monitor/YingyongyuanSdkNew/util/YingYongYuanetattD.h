//
//  YingYongYuanetapplicationDSID.h
//  微加钥匙
//
//  Created by 云冯 on 16/2/22.
//  Copyright © 2016年 冯云. All rights reserved.
//

#import <Foundation/Foundation.h>
 
#import "YingYongYuanjAttInfo.h"
@interface YingYongYuanetattD : YingYongYuanjAttInfo +(YingYongYuanetattD *)sharedInstance;
+ (float)getIOSVersion;
@end
