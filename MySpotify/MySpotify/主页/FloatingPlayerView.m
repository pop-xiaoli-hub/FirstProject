//
//  FloatingPlayerView.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/11.
//

#import "FloatingPlayerView.h"
#import <Masonry.h>
@implementation FloatingPlayerView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {

  }
  return self;
}

- (void)layoutNewFrame {
  [self mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.superview.mas_left).offset(20);
      make.right.equalTo(self.superview.mas_right).offset(-20);
      make.bottom.equalTo(self.superview.mas_bottom).offset(-90);
      make.height.mas_equalTo(60);
  }];
}

- (void)createPlayerView {
  UIVisualEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
  self.blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
  [self addSubview:_blurView];
  [self.blurView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self);
    make.right.equalTo(self);
    make.bottom.equalTo(self.mas_bottom);
    make.height.mas_equalTo(60);
  }];
  self.blurView.layer.masksToBounds = YES;
  self.blurView.layer.cornerRadius = 30;
  [self bringSubviewToFront:self.blurView];
  self.buttonOfPlayerSwitches = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.buttonOfPlayerSwitches setImage:[UIImage imageNamed:@"start.png"] forState:UIControlStateNormal];
  [self.buttonOfPlayerSwitches setImage:[UIImage imageNamed:@"Pause.png"] forState:UIControlStateSelected];
  [self.blurView.contentView addSubview:self.buttonOfPlayerSwitches];
  [self.buttonOfPlayerSwitches mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.blurView.mas_top).offset(10);
      make.bottom.equalTo(self.blurView.mas_bottom).offset(-10);
      make.right.equalTo(self.blurView).offset(-20);
      make.width.mas_equalTo(40);
  }];
  self.trackHeaderView = [[UIImageView alloc] init];
  self.trackHeaderView.layer.masksToBounds = YES;
  [self.blurView.contentView addSubview:self.trackHeaderView];
  [self.trackHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.blurView.mas_left).offset(20);
      make.top.equalTo(self.blurView.mas_top).offset(5);
      make.width.height.mas_equalTo(50);
  }];
  self.trackHeaderView.layer.cornerRadius = 25;
  self.trackHeaderView.layer.backgroundColor = [UIColor whiteColor].CGColor;
  self.trackNameLabel = [[UILabel alloc] init];
  self.trackNameLabel.backgroundColor = [UIColor clearColor];
  [self.blurView.contentView addSubview:self.trackNameLabel];
  [self.trackNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.trackHeaderView.mas_right).offset(10);
      make.top.equalTo(self.blurView.mas_top).offset(5);
      make.height.mas_equalTo(25);
      make.right.equalTo(self.buttonOfPlayerSwitches.mas_left).offset(-20);
  }];
  self.trackNameLabel.layer.masksToBounds = YES;
  self.trackNameLabel.layer.cornerRadius = 15;
  self.trackNameLabel.font = [UIFont systemFontOfSize:18];

  self.trackArtistNameLabel = [[UILabel alloc] init];
  self.trackArtistNameLabel.backgroundColor = [UIColor clearColor];
  [self.blurView.contentView addSubview:self.trackArtistNameLabel];
  [self.trackArtistNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.trackHeaderView.mas_right).offset(10);
      make.top.equalTo(self.trackNameLabel.mas_bottom).offset(0);
      make.height.mas_equalTo(20);
      make.right.equalTo(self.buttonOfPlayerSwitches.mas_left).offset(-50);
  }];
  self.trackArtistNameLabel.layer.masksToBounds = YES;
  self.trackArtistNameLabel.layer.cornerRadius = 10;
  self.trackArtistNameLabel.font = [UIFont systemFontOfSize:15];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
