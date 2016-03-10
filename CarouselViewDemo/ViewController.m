// The MIT License (MIT)
//
// Copyright (c) 2016 zh (https://github.com/zh-XN)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "ViewController.h"
#import "CarouselView.h"

@interface ViewController ()<CarouselViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CarouselView *cv = [[CarouselView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
    cv.delegate = self;
    [self.view addSubview:cv];
}

- (NSInteger)numberOfCarouselColumns {
    return 3;
}

- (void)carousel:(CarouselView *)carousel didTapAtIndex:(NSInteger)index {
    NSLog(@"tap on view at index: %ld", (long)index);
}

- (void)carousel:(CarouselView *)carousel columnView:(UIView *)view forIndex:(NSInteger)index {
    UIImageView *imgView = [view viewWithTag:100];
    if (!imgView) {
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
        imgView.tag = 100;
        [view addSubview:imgView];
    }
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpg", (long)index]];
    imgView.image = img;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
