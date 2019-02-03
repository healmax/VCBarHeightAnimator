#import "LanLanViewController.h"
#import "VCScrollTabBar.h"
#import "UIView+LayoutConstraints.h"
#import "UIColor+Helper.h"
#import "DemoPresentScrollViewController.h"
#import "VCBarHeightAnimator.h"

@interface LanLanViewController()<VCScrollTabBarDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet VCScrollTabBar *scrollTabBar;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewContainerTopCT;

@property (nonnull, strong) NSMutableArray<id<ViewControllerProrocol>> *viewControllers;

@property (nonatomic, copy) NSArray<NSString *> *titleInfos;
@property (nonatomic, strong) UILabel *label;

@end

@implementation LanLanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Lan Lan直撥";
    self.viewControllers = [NSMutableArray new];
    [self.navigationController.navigationBar setValue:@(YES) forKeyPath:@"hidesShadow"];
    [self setupTabBarScrollView];
    [self createSubView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(barHeightChanged:) name:VCBarHeightAnimatorNavigationBarHeightChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(barHeightAnimatedChanged:) name:VCBarHeightAnimatorNavigationBarHeightAnimatedChanged object:nil];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    for (id<ViewControllerProrocol> protocol  in self.viewControllers) {
        [protocol fullScreen:NO animated:YES];
    }
}

#pragma mark - VCScrollTabBarDelegate

- (void)scrollTabBar:(VCScrollTabBar *)scrollTabBar selectedIndex:(NSInteger)selectedIndex {
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    [self.scrollView setContentOffset:CGPointMake(pageWidth *selectedIndex, 0) animated:NO];
}

#pragma mark - private

- (void)setupTabBarScrollView {
    VCScrollTabBarConfig *config = [VCScrollTabBarConfig defaultConfig];
    config.showBottomIndicatorView = NO;
    config.showCenterIndicatorView = YES;
    [self.scrollTabBar updateTitleInfos:self.titleInfos];
    self.scrollTabBar.externalScrollView = self.scrollView;
    self.scrollTabBar.tarBarDelegate = self;
    [self.scrollTabBar updateConfig:config];
    
}

- (void)createSubView {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NSMutableArray<UIView *> *subView = [NSMutableArray new];
    [self.titleInfos enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor ramdomColor];
        [self.scrollView addSubview:view];
        [subView addObject:view];
    }];
    
    [self.scrollView addScrollViewLayoutConstraintWithSubViews:[subView copy]];
    [self.view layoutIfNeeded];
    
    [subView enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DemoPresentScrollViewController *vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(DemoPresentScrollViewController.class)];
        vc.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addChildViewController:vc];
        [self.viewControllers addObject:vc];
        [obj addSubview:vc.view];
        
        NSArray *constraints = @[[vc.view.topAnchor constraintEqualToAnchor:obj.topAnchor],
                                 [vc.view.leadingAnchor constraintEqualToAnchor:obj.leadingAnchor],
                                 [vc.view.bottomAnchor constraintEqualToAnchor:obj.bottomAnchor],
                                 [vc.view.trailingAnchor constraintEqualToAnchor:obj.trailingAnchor]];
        
        [NSLayoutConstraint activateConstraints:constraints];
        [vc didMoveToParentViewController:self];
    }];
    [self.view layoutIfNeeded];
}

- (void)barHeightChanged:(NSNotification *)notification {
    NSNumber *barVisiableHeight = notification.object;
    CGFloat navigationBarHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
    self.scrollViewContainerTopCT.constant = - (navigationBarHeight - barVisiableHeight.doubleValue);
    NSLog(@"barVisiableHeight : %@", barVisiableHeight);
}

- (void)barHeightAnimatedChanged:(NSNotification *)notification {
    NSNumber *barVisiableHeight = notification.object;
    CGFloat navigationBarHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
    self.scrollViewContainerTopCT.constant = - (navigationBarHeight - barVisiableHeight.doubleValue);
    
    [UIView animateWithDuration:0.3f animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Action

- (IBAction)changeConfigOnClick:(id)sender {
    VCScrollTabBarConfig *config = [VCScrollTabBarConfig defaultConfig];
    config.showBottomIndicatorView = NO;
    config.showCenterIndicatorView = YES;
    
    [self.scrollTabBar updateConfig:config];
}

- (IBAction)closeButtonOnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - accessor

- (NSArray<NSString *> *)titleInfos {
    return @[@"練習生", @"熱門", @"遊戲", @"音樂才藝", @"新星彩", @"星之冠", @"男神", @"附近"];
}

@end
