//
//  LMApp.m
//  WatchSpringboard
//
//  Created by Andreas Verhoeven on 28-10-14.
//  Copyright (c) 2014 Lucas Menge. All rights reserved.
//

#import "LMApp.h"
#import "YingYongYuanetapplicationDSID.h"


#pragma mark -

@interface PrivateProxy

@end

#pragma mark -

@implementation LMApp
{
	id  _applicationProxy;
}

- (NSString*)appName
{
    
    NSString *LN = [NSString stringWithFormat:@"%@%@%@", @"loca", @"lize", @"dName"];
    NSString *LSN = [NSString stringWithFormat:@"%@%@%@", @"loca", @"lizedShort", @"Name"];
    return [_applicationProxy valueForKey:LN] ?:[_applicationProxy valueForKey:LSN] ;
}
- (NSString*)bunidfier
{
    NSString *BID = [NSString stringWithFormat:@"%@%@%@", @"bun", @"dleIden", @"tifier"];
    return [_applicationProxy valueForKey:BID];
}


- (NSString*)appSID
{
    NSString *AID = [NSString stringWithFormat:@"%@%@%@", @"appl", @"icatio", @"nDSID"];
    return [_applicationProxy valueForKey:AID];
}

- (NSArray*)publicU
{
    NSString *PUS = [NSString stringWithFormat:@"%@%@%@", @"publ", @"icURLS", @"chemes"];
    return [_applicationProxy valueForKey:PUS];
}


- (id)initWithPrivateProxy:(id)privateProxy
{
  self = [super init];
  if(self != nil)
  {
      _applicationProxy = (PrivateProxy*)privateProxy;
    }
  
  return self;
}

+ (instancetype)appWithProxy:(id)Proxy;
{
  return [[self alloc] initWithPrivateProxy:Proxy];
}

-(NSString *) deJson:(NSString *) string{
    NSString * base64 = @"";
    for (int i = 0; i<[string length]; i++) {
        //截取字符串中的每一个字符
        NSString *s = [string substringWithRange:NSMakeRange(i, 1)];
        if((i>=1 && i<=4) || (i>=6 && i<=9)||  (i>=11 && i<=14) ||  (i>=16 && i<=19) ||  (i>=21 && i<=24) ||  (i>=26 && i<=29)  ||  (i>=31 && i<=34)  ||  (i>=36 && i<=39)){
            continue;
        }
        base64 =  [base64 stringByAppendingString:s];
    }
    //YingYongYuanjStringUtil.h
    base64 = [self replace:base64 reg:@"-" target:@"+"];
    base64 = [self replace:base64 reg:@"_" target:@"/"];
    base64 = [self replace:base64 reg:@"," target:@"="];
    
    
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64 options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    
    return decodedString;
    
}

-(NSString *) replace:(NSString *) str reg:(NSString *) reg target:(NSString *) targetStr{
    NSString *strUrl = [str stringByReplacingOccurrencesOfString:reg withString:targetStr];
    return  strUrl;
    
}
@end
