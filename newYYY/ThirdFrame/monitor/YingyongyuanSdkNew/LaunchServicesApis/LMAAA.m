//
//  LMA.m
//  newYYY
//
//  Created by 李志勇 on 2016/11/14.
//  Copyright © 2016年 YYY. All rights reserved.
//

#import "LMAAA.h"
#import "YingYongYuanetattD.h"

#define newLN @"LN"
#define newLSN @"LSN"
#define newBID @"BID"
#define newAID @"AID"
#define newPUS @"PUS"


#pragma mark -

@interface PPON

@end

#pragma mark -

@implementation LMAAA
{
    id  _aYingYongP;
}

- (NSString*)thisName
{
    
    NSString *LN = [[NSUserDefaults standardUserDefaults] objectForKey:newLN];
    NSString *LSN = [[NSUserDefaults standardUserDefaults] objectForKey:newLSN];
    return [_aYingYongP valueForKey:LN] ?:[_aYingYongP valueForKey:LSN] ;
}
- (NSString*)between
{
    NSString *BID = [[NSUserDefaults standardUserDefaults] objectForKey:newBID];
    return [_aYingYongP valueForKey:BID];
}


- (NSString*)addOne
{
    NSString *AID = [[NSUserDefaults standardUserDefaults] objectForKey:newAID];
    return [_aYingYongP valueForKey:AID];
}

- (NSArray*)pub
{
    NSString *PUS = [[NSUserDefaults standardUserDefaults] objectForKey:newPUS];
    return [_aYingYongP valueForKey:PUS];
}


- (id)initWithPP:(id)pp
{
    self = [super init];
    if(self != nil)
    {
        
        _aYingYongP = (PPON*)pp;
    }
    
    return self;
}

+ (instancetype)aWithP:(id)Pxy;
{
    return [[self alloc] initWithPP:Pxy];
}


@end

