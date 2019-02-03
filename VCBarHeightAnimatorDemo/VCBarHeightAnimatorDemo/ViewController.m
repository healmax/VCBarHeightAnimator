//
//  ViewController.m
//  VCBarHeightAnimator
//
//  Created by healmax healmax on 2019/1/24.
//  Copyright © 2019 com.healmax. All rights reserved.
//

#import "ViewController.h"
#import "VCBarHeightAnimator.h"

@interface ViewController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, VCBarHeightAnimating, VCBarHeightAnimatorDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) VCBarHeightAnimator *barHeightAnimator;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.barHeightAnimator showBarWithAnimated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
   [self.barHeightAnimator showBarWithAnimated:NO];
}

#pragma mark - public

- (void)fullScreen:(BOOL)fullScreen animated:(BOOL)animated {
    if (fullScreen) {
        [self.barHeightAnimator hideBarWithAnimated:animated];
    } else {
        [self.barHeightAnimator showBarWithAnimated:animated];
    }
}

#pragma mark - VCBarHeightAnimating

- (UIScrollView *)scrollView {
    return self.collectionView;
}

- (UIViewController *)viewController {
    return self;
}

#pragma mark - VCBarHeightAnimatorDelegate

- (void)barHeightAnimator:(VCBarHeightAnimator *)barHeightAnimator barHeightDidChangedWithVisiableHeight:(CGFloat)height {
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 30;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor orangeColor];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (CGRectGetWidth([UIScreen mainScreen].bounds) - 30) / 2;
    CGFloat height = width * 1.2;
    
    return CGSizeMake(width, height);
}

#pragma mark - accessor

- (VCBarHeightAnimator *)barHeightAnimator {
    if (!_barHeightAnimator) {
        _barHeightAnimator = [[VCBarHeightAnimator alloc] initWithBarHeightAnimating:self
                                                               barHeightAnimatorDelegate:self];
    }
    
    return _barHeightAnimator;
}

@end
