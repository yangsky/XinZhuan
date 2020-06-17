//
//  ZYTNativeAdView.h
//  DotcAd
//
//  Created by user on 2019/12/2.
//  Copyright © 2019 DotC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYTNativeAdMaterial.h"
#import "ZYTNativeAd.h"
typedef NS_ENUM(NSUInteger, ZYTNativeAdViewType) {
    ZYTNativeAdViewExpress,
    ZYTNativeAdViewUnified,
};

NS_ASSUME_NONNULL_BEGIN
@interface ZYTNativeAdView : UIView

@property (nonatomic, weak) UIViewController *controller;
@property (nonatomic, assign) CGFloat height;

/// 原生自渲染广告需要将视图放置本容器
- (void)registerViewForNativeAd:(ZYTNativeAd *)nativeAd
               nativeMaterial:(ZYTNativeAdMaterial *)nativeMaterial
                 viewController:(UIViewController *)controller
                 clickableViews:(nullable NSArray<UIView *> *)clickableViews;

@end

NS_ASSUME_NONNULL_END
