//
//  VCScrollViewContentOffsetObserver.h
//  VCBarHeightAnimator
//
//  Created by healmax healmax on 2019/1/26.
//  Copyright © 2019 com.healmax. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VCScrollViewContentOffsetObserver : NSObject

- (instancetype)initWithScrollView:(UIScrollView *)scrollView;

@property (strong, nonatomic, readonly) UIScrollView *scrollView;
@property (copy, nonatomic) void(^didChangeContentOffset)(void);

@end

NS_ASSUME_NONNULL_END
