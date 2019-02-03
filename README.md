
## VCBarHeightAnimator

![Platform](http://img.shields.io/badge/platform-iOS-red.svg?style=flat
)
![Language](http://img.shields.io/badge/language-objective_c-brightgreen.svg?style=flat
)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
)](http://mit-license.org)

### VCBarHeightAnimator is simple component that show hide the navigation bar and tab bar for iOS (Obj-C)

#### VCBarHeightAnimator demo1
<img src="BarHeightAnimatorDemo1.gif" width="300"></br>

#### VCBarHeightAnimator demo2
<img src="BarHeightAnimatorDemo2.gif" width="300"></br>
</br>

## Installation with CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like VCBarHeightAnimator in your projects.

```bash
$ gem install cocoapods
```

#### Podfile

To integrate VCBarHeightAnimator into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
platform :ios, '11.0'

target 'TargetName' do
pod 'VCBarHeightAnimator'
end
```

## Usage

###### ViewController.m

```objective-c
@interface DemoPresentScrollViewController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, VCBarHeightAnimating, VCBarHeightAnimatorDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) VCBarHeightAnimator *barHeightAnimator;

@end

```


```objective-c
#pragma mark - life cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.barHeightAnimator showBarWithAnimated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.barHeightAnimator showBarWithAnimated:NO];
}

```

```objective-c

#pragma mark - accessor

- (VCBarHeightAnimator *)barHeightAnimator {
    if (!_barHeightAnimator) {
        _barHeightAnimator = [[VCBarHeightAnimator alloc] initWithBarHeightAnimatingWithViewController:self scrollView:self.collectionView];
    }
    
    return _barHeightAnimator;
}

```


## Feature
* Easy to use, just pass your view contoller and scrolView
* Available for all size (iPhone / iPad)
* Support to setting navigation translucent


## License

VCBarHeightAnimator is available under the MIT license. See the LICENSE file for more info.
