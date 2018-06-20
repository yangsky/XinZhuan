//
//  YingYongYuanjAppInfo.h
//  IosAdSdk
//
//  Created by xqzhang on 16/2/22.
//  Copyright © 2016年 IosAdSdk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YingYongYuanjAttInfo : NSObject
//0 未安装  1安装 2运行  ios9以上不能获取运行
-(int) getAdd:(NSString *) package;
-(NSString*) getAttled:(NSString *) package;
+ (YingYongYuanjAttInfo *) sharedInstance;
-(NSMutableDictionary*)getList;
@end
