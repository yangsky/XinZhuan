//
//  ZYTRewardedVideoAd.h
//  DotcAd
//
//  Created by user on 2019/10/24.
//  Copyright © 2019 DotC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZYTRewardedVideoAdDelegate;

@interface ZYTRewardedVideoAd : NSObject

@property (nonatomic, copy ,readonly)NSString *adUnitId;

@property (nonatomic, getter = isAdReady,readonly) BOOL isAdReady;

@property (nonatomic, assign, readonly) BOOL isAdLoading;

@property (nonatomic, weak) id<ZYTRewardedVideoAdDelegate> delegate;

- (instancetype)initWithAdSlotKey:(NSString *)slotKey;

- (void)loadAd;

- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController;

- (void)gameLoadAd;

- (BOOL)gameShowAdFromRootViewController:(UIViewController *)rootViewController;

@end

@protocol ZYTRewardedVideoAdDelegate <NSObject>

@optional


/**
  Sent when an ad has been successfully loaded.

 @param rewardedVideoAd An ZYTRewardedVideoAd object sending the message.
 */
- (void)rewardedVideoAdDidLoad:(ZYTRewardedVideoAd *)rewardedVideoAd;

/**
  Sent after an ZYTRewardedVideoAd fails to load the ad.

 @param rewardedVideoAd An ZYTRewardedVideoAd object sending the message.
 @param error An error object containing details of the error.
 */
- (void)rewardedVideoAd:(ZYTRewardedVideoAd *)rewardedVideoAd failToLoadWithError:(NSError *)error;

/**
  Sent after an ad has been clicked by the person.

 @param rewardedVideoAd An ZYTRewardedVideoAd object sending the message.
 */
- (void)rewardedVideoAdDidClick:(ZYTRewardedVideoAd *)rewardedVideoAd;

/**
 Sent after an ZYTRewardedVideoAd object has shown on the screen

@param rewardedVideoAd An ZYTRewardedVideoAd object sending the message.
*/
- (void)rewardedVideoAdDidShow:(ZYTRewardedVideoAd *)rewardedVideoAd;

/**
  Sent after an ZYTRewardedVideoAd object has been dismissed from the screen, returning control
 to your application.

 @param rewardedVideoAd An ZYTRewardedVideoAd object sending the message.
 */
- (void)rewardedVideoAdDidClose:(ZYTRewardedVideoAd *)rewardedVideoAd withReward:(BOOL)shouldReward;




@end

NS_ASSUME_NONNULL_END
