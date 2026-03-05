//
//  SongListFooterView.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/22.
//

#import "SongListFooterView.h"
#import <Masonry.h>
@implementation SongListFooterView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.indicator.color = UIColor.lightGrayColor;
    [self addSubview:self.indicator];
    self.label = [[UILabel alloc] init];
    self.label.font = [UIFont systemFontOfSize:13];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.textColor = UIColor.lightGrayColor;
    [self addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
          make.center.equalTo(self);
          make.width.mas_equalTo(200);
          make.height.equalTo(self.mas_height);
    }];
    [self.indicator mas_makeConstraints:^(MASConstraintMaker *make) {
      make.right.equalTo(self.mas_right).offset(-90);
          make.centerY.equalTo(self);
    }];

//    self.indicator.center = CGPointMake(100, frame.size.height / 2);
//    self.label.frame = CGRectMake(120, 0, 200, frame.size.height);

    [self setState:LoadMoreStateIdle];
  }
  return self;
}

- (void)setState:(LoadMoreState)state {
  switch (state) {
    case LoadMoreStateIdle:
      self.hidden = YES;
      [self.indicator stopAnimating];
      break;

    case LoadMoreStateLoading:
      self.hidden = NO;
      self.label.text = @"正在加载…";
      [self.indicator startAnimating];
      break;

    case LoadMoreStateNoMoreData:
      self.hidden = NO;
      self.label.text = @"没有更多了";
      [self.indicator stopAnimating];
      break;
  }
}

@end
