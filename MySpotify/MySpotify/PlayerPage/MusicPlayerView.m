//
//  MusicPlayerView.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/6.
//

#import "MusicPlayerView.h"
#import <Masonry.h>
#import "SongModel.h"

@implementation MusicPlayerView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self createGraditent];
    [self createScrollView];
  }
  return self;
}

- (void)createScrollView {
  _scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
  _scrollView.pagingEnabled = YES;
  _scrollView.showsHorizontalScrollIndicator = NO;
  _scrollView.bounces = YES;
  _scrollView.alwaysBounceVertical = NO;
  _scrollView.alwaysBounceHorizontal = YES;
  [self addSubview:_scrollView];
  [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self);
    make.right.equalTo(self);
    make.top.equalTo(self);
    make.bottom.equalTo(self);
  }];
  _scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 3, self.scrollView.frame.size.height);
  self.leftPage = [[DetailMusicPlayerView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
  [_scrollView addSubview:self.leftPage];
  self.centerPage = [[DetailMusicPlayerView alloc] initWithFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
  [_scrollView addSubview:self.centerPage];
  self.rightPage = [[DetailMusicPlayerView alloc] initWithFrame:CGRectMake(self.frame.size.width * 2, 0, self.frame.size.width, self.frame.size.height)];
  [_scrollView addSubview:self.rightPage];
  [_scrollView setContentOffset:CGPointMake(self.frame.size.width, 0)];
}


- (void)createGraditent {
  CAGradientLayer *gradient = [CAGradientLayer layer];
  gradient.frame = self.bounds;
  gradient.colors = @[
      (__bridge id)[UIColor colorWithRed:0.08 green:0.08 blue:0.10 alpha:1].CGColor,
      (__bridge id)[UIColor colorWithRed:0.35 green:0.35 blue:0.38 alpha:1].CGColor
  ];
  gradient.startPoint = CGPointMake(0, 0);
  gradient.endPoint   = CGPointMake(0, 1);
  [self.layer insertSublayer:gradient atIndex:0];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
