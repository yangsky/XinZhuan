//
//  ZYTBannerAd.h
//  DotcAd
//
//  Created by user on 2018/12/20.
//  Copyright © 2018年 DotC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZYTBannerAdDelegate;

@interface ZYTBannerAd : NSObject

@property (nonatomic, copy, readonly) NSString  *unitId;
@property (nonatomic, strong) UIView *bannerView;
/**
 初始化广告

 @param slotKey 广告Id
 @param controller 显示广告的VC
 @param delegate 代理
 @return ZYTBannerAd
 */
- (instancetype)initWithSlotKey:(NSString *)slotKey
             rootViewController:(UIViewController *)controller
                       delegate:(id<ZYTBannerAdDelegate>)delegate;


- (void)showBanner;

- (void)destroyBanner;


@end

@protocol ZYTBannerAdDelegate <NSObject>

@optional

/// Sent when an ad has been successfully loaded.
- (void)bannerAdLoadSuccess;

/// Sent after an ZYTBannerAd fails to load the ad.
/// @param error An error object containing details of the error.
- (void)bannerAdShowError:(NSError *)error;

/// Sent after an ad has been clicked by the person.
- (void)bannerAdDidClicked;

/// Sent after an ZYTBannerAd object has been removed from the screen
- (void)bannerAdDidClosed;

@end


NS_ASSUME_NONNULL_END
