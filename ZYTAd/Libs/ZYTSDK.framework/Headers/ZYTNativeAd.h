//
//  ZYTNativeAd.h
//  DotcAd
//
//  Created by user on 2019/12/2.
//  Copyright © 2019 DotC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZYTNativeAdMaterial.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZYTNativeAdDelegate;

@interface ZYTNativeAd : NSObject

@property (nonatomic, copy, readonly) NSString *adUnitId;

@property (nonatomic, assign, readonly) BOOL adReady;

@property (nonatomic, assign, readonly) BOOL isLoading;

@property (nonatomic, weak) id<ZYTNativeAdDelegate> delegate;

- (instancetype)initWithSlotKey:(NSString *)slotKey size:(CGSize)size;

- (void)loadNativeAd:(NSInteger)count;

- (void)registerViewForAdView:(UIView *)adView
               viewController:(UIViewController *)viewController
               clickableViews:(nullable NSArray<UIView *> *)clickableViews;

@end

@class ZYTNativeAdView;
@protocol ZYTNativeAdDelegate <NSObject>

/**
 * 拉取原生模板广告成功
 */
- (void)nativeExpressAdSuccessToLoad:(ZYTNativeAd *)nativeExpressAd views:(NSArray<__kindof ZYTNativeAdView *> *)views;

/**
 * 拉取原生广告成功
*/
- (void)nativeAdSuccessToLoad:(ZYTNativeAd *)nativeExpressAd nativeAds:(NSArray<ZYTNativeAdMaterial *> *)nativeAds;

/**
 * 拉取原生模板广告失败
 */
- (void)nativeExpressAdFailToLoad:(ZYTNativeAd *)nativeExpressAd error:(NSError *)error;

/**
 * 原生模板广告渲染成功, 此时的 nativeExpressAdView.size.height 根据 size.width 完成了动态更新。
 */
- (void)nativeExpressAdViewRenderSuccess:(ZYTNativeAd *)nativeExpressAdView;

/**
 * 原生模板广告渲染失败
 */
- (void)nativeExpressAdViewRenderFail:(ZYTNativeAd *)nativeExpressAdView;

/**
 * 原生模板广告点击回调
 */
- (void)nativeExpressAdViewClicked:(ZYTNativeAd *)nativeExpressAdView;

/**
* 原生模板详情页 WillPresent 回调
*/
- (void)nativeExpressAdViewWillPresentVC:(ZYTNativeAd *)nativeExpressAdView;

/**
 * 原生模板详情页 DidDismiss 回调
 */
- (void)nativeExpressAdViewDidDismissVC:(ZYTNativeAd *)nativeExpressAdView;

/**
* Sent when a user clicked dislike reasons.
*/
- (void)nativeExpressAdViewDislikeAd:(ZYTNativeAd *)nativeExpressAdView;

@end


NS_ASSUME_NONNULL_END
