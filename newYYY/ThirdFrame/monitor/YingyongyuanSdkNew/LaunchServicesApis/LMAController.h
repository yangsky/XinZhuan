//
//  LMAController.h
//  newYYY
//
//  Created by 李志勇 on 2016/11/14.
//  Copyright © 2016年 YYY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LMAAA.h"
#import <objc/message.h>


@interface LMAController : NSObject
{
}

@property (nonatomic, readonly) NSArray* inAction;
- (BOOL)onThis:(NSString *)package;
+ (instancetype)sharedInstance;

@end
