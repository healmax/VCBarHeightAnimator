//
//  VCScrollViewContentOffsetObserver.m
//  VCBarHeightAnimator
//
//  Created by healmax healmax on 2019/1/26.
//  Copyright © 2019 com.healmax. All rights reserved.
//

#import "VCScrollViewContentOffsetObserver.h"

static NSString *kContentOffsetKeyPath = @"contentOffset";

@implementation VCScrollViewContentOffsetObserver

- (instancetype)initWithScrollView:(UIScrollView *)scrollView {
    self = [super init];
    if (self) {
        NSAssert(scrollView, @"Scroll view is required");
        _scrollView = scrollView;
        [self addKeyPathObserver];
    }
    return self;
}

- (void)addKeyPathObserver {
    [_scrollView addObserver:self forKeyPath:kContentOffsetKeyPath options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)dealloc {
    [_scrollView removeObserver:self forKeyPath:kContentOffsetKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if (self.didChangeContentOffset) {
        self.didChangeContentOffset();
    }
}

@end
