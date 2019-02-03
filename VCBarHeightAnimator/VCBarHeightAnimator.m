//
//  VCBarHeightAnimator.m
//  VCBarHeightAnimator
//
//  Created by healmax healmax on 2019/1/24.
//  Copyright © 2019 com.healmax. All rights reserved.
//

#import "VCBarHeightAnimator.h"
#import "VCScrollViewContentOffsetObserver.h"


NSString * const VCBarHeightAnimatorNavigationBarHeightChanged = @"VCBarHeightAnimatorNavigationBarHeightChanged";
NSString * const VCBarHeightAnimatorNavigationBarHeightAnimatedChanged = @"VCBarHeightAnimatorNavigationBarHeightAnimatedChanged";

static NSString * const kContentOffsetKeyPath = @"contentOffset";
static NSTimeInterval const kCollapseAnimationDuration = 0.3f;

@interface VCBarHeightAnimator()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, weak) UIViewController<VCBarHeightAnimatorDelegate> *viewController;

@property (nonatomic, strong) VCScrollViewContentOffsetObserver *contentOffsetObserver;
@property (nonatomic, assign) CGFloat lastContentOffsetY;
@property (nonatomic, assign) CGFloat scrollDistance;
@property (nonatomic, assign) BOOL didEndGesture;

@end

// Init
// Navigation Bar translucent == flase, adjustedContentInset top == 0
// Navigation Bar translucent == true, adjustedContentInset top == 64

@implementation VCBarHeightAnimator

- (instancetype)initWithBarHeightAnimatingWithViewController:(UIViewController<VCBarHeightAnimatorDelegate> *)viewController scrollView:(UIScrollView *)scrollView {
    if (self = [super init]) {
        _viewController = viewController;
        _scrollView = scrollView;
        _scrollDistance = 0;
        [self commonInit];
    }

    return self;

}

- (void)dealloc {
    [self.scrollView.panGestureRecognizer removeTarget:self action:@selector(scrollViewEndPanning:)];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.scrollView.delegate = nil;
}

#pragma mark - public

- (void)showBarWithAnimated:(BOOL)animated {
    [self adjustBarHeightWithPercentage:1 animated:animated];
}

- (void)hideBarWithAnimated:(BOOL)animated {
    [self adjustBarHeightWithPercentage:0 animated:animated];
}

#pragma mark - private

- (void)commonInit {
    [self.scrollView.panGestureRecognizer addTarget:self action:@selector(scrollViewEndPanning:)];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusBarDidChangeFrame:)
                                                 name:UIApplicationWillChangeStatusBarFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    self.contentOffsetObserver = [[VCScrollViewContentOffsetObserver alloc] initWithScrollView:self.scrollView];
    __weak typeof(self) weakSelf = self;
    self.contentOffsetObserver.didChangeContentOffset = ^{
        [weakSelf contentOffsetDidChange];
    };
}

- (void)contentOffsetDidChange {
    CGFloat delta = self.lastContentOffsetY - self.scrollView.contentOffset.y;
    if ([self shouldAdjustBarHeight:delta]) {
        [self adjustBarHeight:delta];
    }
    
    self.lastContentOffsetY = self.scrollView.contentOffset.y;
}

- (BOOL)shouldAdjustBarHeight:(CGFloat)offset {

    // 1. offset為0
    BOOL isContentOffsetNotChanged = offset == 0;
    
    // 2. contentOffset Y < 0 的時候不調整NavigationBar Height (isTreanslucent == ture)
    BOOL isContentOffsetYLessThanZero = self.scrollView.contentOffset.y <= 0;

    if (!self.navigationBar.isTranslucent) {
        // 2.1 如果navigationBar沒有完全顯示, 改變Navigation Bar的高度
        if (!self.isNavigationBarShowComplete) {
            isContentOffsetYLessThanZero = NO;
        }
    }
    
    // 3. 由上往下滑並且NavigationBar已經完全顯示
    BOOL isNavigationBarShowAndSrollDown = self.isNavigationBarShowComplete && offset > 0;
    
    // 4. 由上往下滑並且NavigationBar已經完全顯示
    BOOL isNavigationBarHideAndSrollUp = self.isNavigationBarHideComplete && offset < 0;
    
    // 5. 由上往下滑時如果滑倒最底部或超過底部, 不用去改變Navigation Bar的高度
    BOOL contentViewBottomHigherThanFrameBottom = self.scrollView.contentOffset.y + CGRectGetHeight(self.scrollView.frame) >= self.scrollView.contentSize.height;
    
    
    if (isContentOffsetNotChanged ||
        isContentOffsetYLessThanZero ||
        isNavigationBarShowAndSrollDown ||
        isNavigationBarHideAndSrollUp ||
        contentViewBottomHigherThanFrameBottom) {
        return NO;
    }
    
    return YES;
}

- (void)adjustBarHeight:(CGFloat)offset {
    CGRect frame = self.navigationBar.frame;
    CGFloat positionY;
    
    //計算移動後navigationBar position Y位置
    positionY = frame.origin.y + offset >= self.statusBarHeight ? self.statusBarHeight : frame.origin.y + offset;
    positionY = frame.origin.y + offset <= -self.navigationBarHeight + self.statusBarHeight ? -self.navigationBarHeight + self.statusBarHeight : positionY;
    
    // navigationBar可見的百分比
    CGFloat percentage = (self.navigationBarHeight + positionY - self.statusBarHeight) / self.navigationBarHeight;
    // 如果navigationBar isTranslucent為flase, 更新ScrollView contentOffset, 因為移動過程中會動到ViewController view的Size
    [self updateContentOffsetWithOffset:offset];
    // 更新NavigationBar的位置
    [self updateNavigationBarWithPercentage:percentage];
    // 如果navigationBar isTranslucent為flase, 更新ViewController View的Size
    [self updateViewControllerViewWithPercentage:percentage];
    // 更新NavigationBar的Alpha
    [self updateNavigationBarAlphaWithPercentage:percentage];
    // 更新TabBar的位置
    [self updateTabBarWithPercentage:percentage];
    
    if ([self.viewController respondsToSelector:@selector(barHeightAnimator:barHeightDidChangedWithVisiableHeight:)]) {
        [self.viewController barHeightAnimator:self barHeightDidChangedWithVisiableHeight:percentage * self.navigationBarHeight];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VCBarHeightAnimatorNavigationBarHeightChanged object:@(percentage * self.navigationBarHeight)];
}

- (void)updateContentOffsetWithOffset:(CGFloat)offset {
    if (self.navigationBar.isTranslucent) {
        return;
    }
    
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y + offset) animated:NO];
}

- (void)updateNavigationBarWithPercentage:(CGFloat)percentage {
    
    // navigationBar可見的長度
    CGFloat navigationBarVisiableHeight = percentage * self.navigationBarHeight;
    // navigationBar可見度為0時PositionY的位置
    CGFloat navigationBarHidePositionY = -self.navigationBarHeight + self.statusBarHeight;
    // navigationBar調整後的位置
    CGFloat positionY = navigationBarHidePositionY + navigationBarVisiableHeight;
    CGRect frame = self.navigationBar.frame;
    frame.origin = CGPointMake(frame.origin.x, positionY);
    frame.size = CGSizeMake(frame.size.width, frame.size.height);
    self.navigationBar.frame = frame;
}

- (void)updateTabBarWithPercentage:(CGFloat)percentage {
    
    if (!self.tabBar.isTranslucent) {
        return;
    }
    
    // tabBar可見的長度
    CGFloat tabBarVisiableHeight = percentage * self.tabBarHeight;
    // tabBar調整後的位置
    CGFloat positionY = self.tabBarOriginalBottomY - tabBarVisiableHeight;
    CGRect frame = self.tabBar.frame;
    frame.origin = CGPointMake(frame.origin.x, positionY);
    frame.size = CGSizeMake(frame.size.width, frame.size.height);
    self.tabBar.frame = frame;
}

- (void)updateViewControllerViewWithPercentage:(CGFloat)percentage {
    if (!self.navigationBar.isTranslucent) {
        
        CGFloat originalPercentage = (CGRectGetMinY(self.topViewController.view.frame) - self.statusBarHeight) / self.navigationBarHeight;
        CGFloat originalOffsetY = (1 - originalPercentage) * self.navigationBarHeight;
        
        CGFloat height = (1 - originalPercentage) * self.tabBarHeight;
        CGFloat tabBarOffset = percentage * self.tabBarHeight;
        
        CGRect frame = self.topViewController.view.frame;
        CGFloat offsetY = percentage * self.navigationBarHeight;
        frame.origin = CGPointMake(frame.origin.x, offsetY+self.statusBarHeight);
        //frame.size.height減掉上次移動距離再加上這次移動的距離
        frame.size = CGSizeMake(frame.size.width, frame.size.height - height - originalOffsetY + (self.navigationBarHeight - offsetY) + (self.tabBarHeight - tabBarOffset));
        self.topViewController.view.frame = frame;
        [self.topViewController.view layoutIfNeeded];
    }
}

- (void)updateNavigationBarAlphaWithPercentage:(CGFloat)percentage {    
    UINavigationItem *navigationItem = self.topViewController.navigationItem;
    if (!navigationItem) {
        return;
    }
    
    NSDictionary<NSAttributedStringKey, id> *atts = self.navigationController.navigationBar.titleTextAttributes;
    UIColor *navigationBarTitleColor = [atts objectForKey:NSForegroundColorAttributeName];
    
    // Hide all the possible titles
    navigationItem.titleView.alpha = percentage;
    
    if (navigationBarTitleColor) {
        self.navigationBar.titleTextAttributes =
        @{NSForegroundColorAttributeName : [navigationBarTitleColor colorWithAlphaComponent:percentage]};
    }
    
    self.navigationBar.barTintColor = [self.navigationBar.barTintColor colorWithAlphaComponent:percentage];
    self.navigationBar.tintColor = [self.navigationBar.tintColor colorWithAlphaComponent:percentage];
    navigationItem.leftBarButtonItem.tintColor = [navigationItem.leftBarButtonItem.tintColor colorWithAlphaComponent:percentage];
    navigationItem.rightBarButtonItem.tintColor = [navigationItem.rightBarButtonItem.tintColor colorWithAlphaComponent:percentage];
}

- (void)scrollViewEndPanning:(UIPanGestureRecognizer *)gr {
    self.didEndGesture = NO;
    
    if (gr.state == UIGestureRecognizerStateEnded) {
        self.didEndGesture = YES;
    }
    
    if (gr.state != UIGestureRecognizerStateEnded && gr.state != UIGestureRecognizerStateCancelled && gr.state != UIGestureRecognizerStateFailed) {
        return;
    }
    
    //處理當滑到最上方時NavigationBar有可能會消失, 造成空白問題
    if (self.scrollView.contentOffset.y + self.scrollView.adjustedContentInset.top < self.scrollView.adjustedContentInset.top) {
        [self adjustBarHeightWithPercentage:1 animated:YES];
        return;
    }

    CGFloat percentage = fabs(CGRectGetMaxY(self.navigationBar.frame) - self.statusBarHeight) / self.navigationBarHeight;

    if (percentage > 0.5) {
        [self adjustBarHeightWithPercentage:1 animated:YES];

    } else {
        [self adjustBarHeightWithPercentage:0 animated:YES];
    }
}

- (void)adjustBarHeightWithPercentage:(CGFloat)percentage animated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:kCollapseAnimationDuration animations:^{
            // 更新NavigationBar的位置
            [self updateNavigationBarWithPercentage:percentage];
            // 如果navigationBar isTranslucent為flase, 更新ViewController View的Size
            [self updateViewControllerViewWithPercentage:percentage];
            // 更新NavigationBar的Alpha
            [self updateNavigationBarAlphaWithPercentage:percentage];
            // 更新TabBar的位置
            [self updateTabBarWithPercentage:percentage];

            [[NSNotificationCenter defaultCenter] postNotificationName:VCBarHeightAnimatorNavigationBarHeightAnimatedChanged object:@(percentage * self.navigationBarHeight)];
        }];
    } else {
        [self updateViewControllerViewWithPercentage:percentage];
        [self updateNavigationBarWithPercentage:percentage];
        [self updateNavigationBarAlphaWithPercentage:percentage];
        [self updateTabBarWithPercentage:percentage];
    }
}

#pragma mark - accessor

- (UIViewController *)topViewController {
    return self.navigationController.topViewController;
}

- (CGRect)statusBarFrame {
    return [UIApplication sharedApplication].statusBarFrame;
}

- (CGFloat)statusBarHeight {
    return CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
}

- (UINavigationController *)navigationController {
    return self.viewController.navigationController;
}

- (UINavigationBar *)navigationBar {
    return self.navigationController.navigationBar;
}

- (BOOL)isNavigationBarShowComplete {
    return CGRectGetMaxY(self.navigationBar.frame) == CGRectGetMaxY(self.statusBarFrame) + self.navigationBarHeight;
}

- (BOOL)isNavigationBarHideComplete {
    return CGRectGetMaxY(self.navigationBar.frame) == CGRectGetMaxY(self.statusBarFrame);
}

- (CGFloat)navigationBarHeight {
    return CGRectGetHeight(self.navigationController.navigationBar.frame);
}

- (UITabBarController *)tabBarController {
    return self.viewController.tabBarController;
}

- (UITabBar *)tabBar {
    return self.tabBarController.tabBar;
}

- (CGFloat)tabBarHeight {
    return CGRectGetHeight(self.tabBar.frame);
}

- (CGFloat)tabBarOriginalBottomY {
    return CGRectGetHeight(self.topViewController.view.frame);
}

#pragma mark - Notification

- (void)statusBarDidChangeFrame:(NSNotification *)notification {
    [self adjustBarHeightWithPercentage:1 animated:YES];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self adjustBarHeightWithPercentage:1 animated:NO];
}

@end
