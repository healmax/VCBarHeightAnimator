//
//  DemoPresentScrollViewController.h
//  VCBarHeightAnimatorDemo
//
//  Created by healmax healmax on 2019/2/3.
//  Copyright © 2019 com.healmax. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ViewControllerProrocol <NSObject>

- (void)fullScreen:(BOOL)fullScreen animated:(BOOL)animated;

@end

@interface DemoPresentScrollViewController : UIViewController<ViewControllerProrocol>

@end

NS_ASSUME_NONNULL_END
