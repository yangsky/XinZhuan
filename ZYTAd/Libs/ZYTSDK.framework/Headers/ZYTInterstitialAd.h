//
//  ZYTInterstitialAd.h
//  DotcAd
//
//  Created by user on 2018/8/2.
//  Copyright © 2018年 DotC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ZYTInterstitialAdDelegate;

@interface ZYTInterstitialAd : NSObject

@property (nonatomic, copy, readonly) NSString *adUnitId;

@property (nonatomic, assign, readonly) BOOL adReady;

@property (nonatomic, assign, readonly) BOOL isLoading;

@property (nonatomic, weak) id<ZYTInterstitialAdDelegate> delegate;

- (instancetype)initWithAdSlotKey:(NSString *)slotKey;

- (void)loadInterstitalAd;

- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController;


@end

@protocol ZYTInterstitialAdDelegate <NSObject>

/// Sent when an ad has been successfully loaded.
/// @param interstitialAd An ZYTInterstitialAd object sending the message.
- (void)interstitialAdDidLoad:(ZYTInterstitialAd *)interstitialAd;

/// Sent after an ZYTRewardedVideoAd fails to load the ad.
/// @param interstitialAd An ZYTInterstitialAd object sending the message.
/// @param error An error object containing details of the error.
- (void)interstitialAd:(ZYTInterstitialAd *)interstitialAd
 failedToLoadWithError:(NSError *)error;

/// Sent after an ZYTRewardedVideoAd object has shown on the screen
/// @param interstitialAd An ZYTInterstitialAd object sending the message.
- (void)interstitialAdDidOpen:(ZYTInterstitialAd *)interstitialAd;

/// Sent after an ZYTInterstitialAd object has been dismissed from the screen, returning control
/// @param interstitialAd An ZYTInterstitialAd object sending the message.
- (void)interstitialAdDidClose:(ZYTInterstitialAd *)interstitialAd;

/// Sent after an ad has been clicked by the person.
/// @param interstitialAd An ZYTInterstitialAd object sending the message.
- (void)interstitialAdDidClickAd:(ZYTInterstitialAd *)interstitialAd;

/// Sent when an ad failed to show on the screen
/// @param interstitialAd An ZYTInterstitialAd object sending the message.
/// @param error An error object containing details of the error.
- (void)interstitialAd:(ZYTInterstitialAd *)interstitialAd
 failedToOpenWithError:(NSError *)error;

@end
