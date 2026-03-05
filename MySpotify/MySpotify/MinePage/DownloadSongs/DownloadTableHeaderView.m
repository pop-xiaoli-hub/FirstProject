//
//  DownloadTableHeaderView.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/2.
//

#import "DownloadTableHeaderView.h"
#import <Masonry.h>
@implementation DownloadTableHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self createUI];
  }
  return self;
}

- (void)createUI {
  self.label = [[UILabel alloc] init];
  self.label.font = [UIFont boldSystemFontOfSize:22];
  self.label.textColor = UIColor.whiteColor;
  self.label.textAlignment = NSTextAlignmentCenter;
  self.label.text = @"可用空间:";
  [self addSubview:self.label];
  [self createButtonOfOpenSettings];
  [self createButtonOfPlayAll];
  [self createButtonOfbuttonOfSelectSongs];
  [self viewAddConstraints];
}

- (void)viewAddConstraints {
  [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.mas_left).offset(20);
      make.top.equalTo(self.mas_top).offset(20);
  }];
  [self.buttonOfOpenSettings mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.label.mas_right).offset(5);
      make.centerY.equalTo(self.label.mas_centerY);
  }];
  [self.buttonOfPlayAllSongs mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.label.mas_left).offset(-5);
      make.top.equalTo(self.label.mas_bottom).offset(40);
      make.height.mas_equalTo(44);
      make.width.greaterThanOrEqualTo(@140);
  }];
  [self.buttonOfSelectSongs mas_makeConstraints:^(MASConstraintMaker *make) {
      make.centerY.equalTo(self.buttonOfPlayAllSongs.mas_centerY);
      make.right.equalTo(self.mas_right).offset(-20);
  }];
}

- (void)createButtonOfbuttonOfSelectSongs {
  self.buttonOfSelectSongs = [UIButton buttonWithType:UIButtonTypeSystem];
  UIImage* icon = [[UIImage systemImageNamed:@"line.3.horizontal.decrease"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  [self.buttonOfSelectSongs setImage:icon forState:UIControlStateNormal];
  self.buttonOfSelectSongs.tintColor = UIColor.whiteColor;
  [self addSubview:self.buttonOfSelectSongs];
}

- (void)createButtonOfOpenSettings {
  self.buttonOfOpenSettings = [UIButton buttonWithType:UIButtonTypeCustom];
  self.buttonOfOpenSettings.backgroundColor = [UIColor clearColor];
  [self.buttonOfOpenSettings setTitle:@"点击进入" forState:UIControlStateNormal];
  [self.buttonOfOpenSettings setTitleColor:UIColor.systemPinkColor forState:UIControlStateNormal];
  [self addSubview:self.buttonOfOpenSettings];
}

- (void)createButtonOfPlayAll {
  self.buttonOfPlayAllSongs = [UIButton buttonWithType:UIButtonTypeCustom];
  self.buttonOfPlayAllSongs.layer.cornerRadius = 22;
  self.buttonOfPlayAllSongs.clipsToBounds = YES;
  self.buttonOfPlayAllSongs.backgroundColor = [UIColor colorWithWhite:1 alpha:0.12];

  [self.buttonOfPlayAllSongs setTitle:@" 播放全部" forState:UIControlStateNormal];
  [self.buttonOfPlayAllSongs setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
  self.buttonOfPlayAllSongs.titleLabel.font = [UIFont boldSystemFontOfSize:15];

  UIImage *icon = [[UIImage systemImageNamed:@"play.fill"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  [self.buttonOfPlayAllSongs setImage:icon forState:UIControlStateNormal];
  self.buttonOfPlayAllSongs.tintColor = UIColor.whiteColor;
  [self addSubview:self.buttonOfPlayAllSongs];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
