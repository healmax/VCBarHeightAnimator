//
//  VCBarHeightAnimator.h
//  VCBarHeightAnimator
//
//  Created by healmax healmax on 2019/1/24.
//  Copyright © 2019 com.healmax. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const VCBarHeightAnimatorNavigationBarHeightChanged;
extern NSString * const VCBarHeightAnimatorNavigationBarHeightAnimatedChanged;

@protocol VCBarHeightAnimating <NSObject>

- (UIScrollView *)scrollView;
- (UIViewController *)viewController;

@end

@class VCBarHeightAnimator;

@protocol VCBarHeightAnimatorDelegate <NSObject>

@optional
- (void)barHeightAnimator:(VCBarHeightAnimator *)barHeightAnimator barHeightDidChangedWithVisiableHeight:(CGFloat)height;

@end

@interface VCBarHeightAnimator : UIScrollView

- (instancetype)initWithBarHeightAnimating:(id<VCBarHeightAnimating>)barHeightAnimating
                 barHeightAnimatorDelegate:(id<VCBarHeightAnimatorDelegate>)delegate;

- (void)showBarWithAnimated:(BOOL)animated;
- (void)hideBarWithAnimated:(BOOL)animated;
//- (instancetype)initWithBarHeightAnimatingWithViewController:(UIViewController *)viewController scrollView:(UIScrollView *)scrollView;


@end

NS_ASSUME_NONNULL_END
