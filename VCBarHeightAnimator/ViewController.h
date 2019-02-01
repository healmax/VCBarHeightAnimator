//
//  ViewController.h
//  VCBarHeightAnimator
//
//  Created by healmax healmax on 2019/1/24.
//  Copyright © 2019 com.healmax. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ViewControllerProrocol <NSObject>

- (void)fullScreen:(BOOL)fullScreen animated:(BOOL)animated;

@end

@interface ViewController : UIViewController<ViewControllerProrocol>


@end

