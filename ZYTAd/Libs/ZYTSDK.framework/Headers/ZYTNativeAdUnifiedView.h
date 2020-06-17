//
//  ZYTNativeAdUnifiedView.h
//  DotcAd
//
//  Created by user on 2020/4/23.
//  Copyright © 2020 ZYT. All rights reserved.
//

#import "ZYTNativeAdView.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZYTNativeAdUnifiedView : ZYTNativeAdView

@property (nonatomic, strong) ZYTNativeAdMaterial *material;

- (instancetype)initWithAdMaterial:(ZYTNativeAdMaterial *)material;
@end

NS_ASSUME_NONNULL_END
