//
//  YingYongYuanmpPreventer.h
//  微加钥匙
//
//  Created by lb_work on 16/5/13.
//  Copyright © 2016年 冯云. All rights reserved.
//

#import <Foundation/Foundation.h>



#pragma mark -
#pragma mark MMPLog


#ifndef MMPDLog
#ifdef DEBUG
#define MMPDLog(format, ...) NSLog((@"%s [Line %d] " format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define MMPDLog(...) do { } while (0)
#endif
#endif

#ifndef MMPALog
#define MMPALog(format, ...) NSLog((@"%s [Line %d] " format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#endif


#pragma mark -
#pragma mark Imports and Forward Declarations


@class AVAudioPlayer;


#pragma mark -
#pragma mark Public Interface

@interface YingYongYuanmpPreventer : NSObject
{
    BOOL       isError;
}


#pragma mark -
#pragma mark Properties

@property (nonatomic, retain) AVAudioPlayer *audioPlayer;
@property (nonatomic, retain) NSTimer       *preventSleepTimer;
@property (nonatomic, assign) BOOL       isError;


#pragma mark -
#pragma mark Public Methods

- (void)setPath:(NSString *) path;
- (void)startPreventSleep;
- (void)stopPreventSleep;
-(void)mmp_playPreventSleepSound;
@end

