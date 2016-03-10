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


#import "CarouselView.h"

@implementation NSObject (CarouselView)

- (void)carousel:(CarouselView *)carousel columnView:(UIView *)view forIndex:(NSInteger)index{}

- (void)carousel:(CarouselView *)carousel didTapAtIndex:(NSInteger)index{}

- (NSInteger)numberOfCarouselColumns{ return 0; }

@end

@interface CarouselView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIView *leftView;

@property (nonatomic, strong) UIView *centerView;

@property (nonatomic, strong) UIView *rightView;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation CarouselView{
    NSInteger _numberOfColumns;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _scrollInterval = kCarouselDefaultScrollInterval;
        _currentIndex = 0;
        _showsPageControl = YES;
        
        _leftView = [[UIView alloc] init];
        _leftView.backgroundColor = [UIColor whiteColor];
        _centerView = [[UIView alloc] init];
        _centerView.backgroundColor = [UIColor whiteColor];
        _rightView = [[UIView alloc] init];
        _rightView.backgroundColor = [UIColor whiteColor];
        
        [_centerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)]];
        
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        [_scrollView addSubview:_leftView];
        [_scrollView addSubview:_centerView];
        [_scrollView addSubview:_rightView];
        [self addSubview:_scrollView];
        
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.hidesForSinglePage = YES;
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
        _pageControl.currentPage = 0;
        [self addSubview:_pageControl];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (void)removeFromSuperview {
    [self stopAutoScroll];
    [super removeFromSuperview];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    // 列数最少为0
    _numberOfColumns = MAX([_delegate numberOfCarouselColumns], 0);
    if (_numberOfColumns == 1) {
        [self.delegate carousel:self columnView:_centerView forIndex:0];
        self.scrollView.scrollEnabled = NO;
    }
    else if (_numberOfColumns > 1) {
        [self.delegate carousel:self columnView:_centerView forIndex:0];
        [self.delegate carousel:self columnView:_leftView forIndex:_numberOfColumns-1];
        [self.delegate carousel:self columnView:_rightView forIndex:1];
        self.scrollView.scrollEnabled = YES;
        [self addTimerIntoRunloop];
    }
    self.pageControl.numberOfPages = _numberOfColumns;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
    self.scrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, 0);
    self.leftView.frame = self.bounds;
    self.centerView.frame = CGRectMake(self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height);
    self.rightView.frame = CGRectMake(self.bounds.size.width * 2, 0, self.bounds.size.width, self.bounds.size.height);
    self.pageControl.frame = CGRectMake(0, self.bounds.size.height - 12, self.bounds.size.width, 7);
    [self resetScrollViewOffset];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_numberOfColumns > 0) {
        [self changeViewsForOffset:scrollView.contentOffset.x];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopAutoScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self addTimerIntoRunloop];
}

#pragma mark - Actions
- (void)onTap:(UITapGestureRecognizer *)tap {
    [self.delegate carousel:self didTapAtIndex:self.currentIndex];
}

- (void)onTimerFire:(NSTimer *)timer {
    [self scrollNext];
}

#pragma mark - Methods
- (void)resetScrollViewOffset {
    [self.scrollView setContentOffset:CGPointMake(self.bounds.size.width, 0)];
}

- (void)startAutoScroll {
    [self stopAutoScroll];
    [self addTimerIntoRunloop];
}

- (void)stopAutoScroll {
    [self.timer invalidate];
    _timer = nil;
}

- (void)addTimerIntoRunloop {
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)scrollNext {
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x + self.bounds.size.width, 0)
                             animated:YES];
}

- (void)changeViewsForOffset:(CGFloat)offset {
    if (offset >= CGRectGetWidth(self.bounds) * 2) {
        self.currentIndex++;
        
        if (self.currentIndex == _numberOfColumns-1) {
            [self setLeftViewIndex:self.currentIndex-1 centerViewIndex:self.currentIndex rightViewIndex:0];
        }
        else if (self.currentIndex == _numberOfColumns) {
            self.currentIndex = 0;
            [self setLeftViewIndex:_numberOfColumns-1 centerViewIndex:0 rightViewIndex:1];
        }
        else {
            [self setLeftViewIndex:self.currentIndex-1 centerViewIndex:self.currentIndex rightViewIndex:self.currentIndex+1];
        }
    }
    else if (offset <= 0) {
        self.currentIndex--;
        if (self.currentIndex == 0) {
            [self setLeftViewIndex:_numberOfColumns-1 centerViewIndex:0 rightViewIndex:1];
        }
        else if (self.currentIndex < 0) {
            self.currentIndex = _numberOfColumns-1;
            [self setLeftViewIndex:self.currentIndex-1 centerViewIndex:self.currentIndex rightViewIndex:0];
        }
        else {
            [self setLeftViewIndex:self.currentIndex-1 centerViewIndex:self.currentIndex rightViewIndex:self.currentIndex+1];
        }
    }
    else {
        ;
    }
    
}

- (void)setLeftViewIndex:(NSUInteger)leftViewIndex
         centerViewIndex:(NSUInteger)centerViewIndex
          rightViewIndex:(NSUInteger)rightViewIndex {
    [self.delegate carousel:self columnView:self.centerView forIndex:centerViewIndex];
    [self.delegate carousel:self columnView:self.leftView forIndex:leftViewIndex];
    [self.delegate carousel:self columnView:self.rightView forIndex:rightViewIndex];
    
    [self resetScrollViewOffset];
    self.pageControl.currentPage = self.currentIndex;
}

#pragma mark - Getters
- (NSTimer *)timer {
    if (!_timer) {
        self.scrollInterval = MAX(self.scrollInterval, 1);
        _timer = [NSTimer timerWithTimeInterval:self.scrollInterval
                                         target:self
                                       selector:@selector(onTimerFire:)
                                       userInfo:nil
                                        repeats:YES];
    }
    return _timer;
}

#pragma mark - Setters
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    _scrollView.backgroundColor = backgroundColor;
    _leftView.backgroundColor = backgroundColor;
    _centerView.backgroundColor = backgroundColor;
    _rightView.backgroundColor = backgroundColor;
}

- (void)setShowsPageControl:(BOOL)showsPageControl {
    _showsPageControl = showsPageControl;
    [self.pageControl setHidden:showsPageControl];
}

@end
