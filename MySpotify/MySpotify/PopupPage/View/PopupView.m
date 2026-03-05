//
//  PopupView.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/23.
//

#import "PopupView.h"
#import <Masonry.h>
#import "ArtistModel.h"

@interface PopupView ()
@property (nonatomic, strong) UIView *closeShadowView;
@property (nonatomic, strong) UIVisualEffectView *closeBlurView;
@end

@implementation PopupView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {

    self.backView = [[UIImageView alloc] init];
    self.backView.contentMode = UIViewContentModeScaleAspectFill;
    self.backView.clipsToBounds = YES;
    [self addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(self);
    }];

    self.blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    [self addSubview:self.blurView];
    [self.blurView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(self);
    }];

    self.darkMaskView = [[UIView alloc] init];
    self.darkMaskView.backgroundColor =
    [[UIColor darkGrayColor] colorWithAlphaComponent:0.1];
    [self addSubview:self.darkMaskView];
    [self.darkMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(self);
    }];

    self.backView.hidden = YES;
    self.backgroundColor = UIColor.darkGrayColor;
    self.layer.cornerRadius = 16;
    self.layer.masksToBounds = YES;

    self.title = [[UILabel alloc] init];
    self.title.font = [UIFont boldSystemFontOfSize:18];
    self.title.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.title];

    self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.closeButton setTitle:@"关闭" forState:UIControlStateNormal];

    [self createJumpToWeb];
    [self createScrollView];
    [self createCloseButtonStyle];

    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.mas_top).offset(15);
      make.left.equalTo(self.mas_left).offset(20);
      make.right.equalTo(self.mas_right).offset(-20);
      make.height.mas_equalTo(30);
    }];
  }
  return self;
}


- (void)createCloseButtonStyle {

  // 阴影容器
  self.closeShadowView = [[UIView alloc] init];
  self.closeShadowView.layer.shadowColor = UIColor.blackColor.CGColor;
  self.closeShadowView.layer.shadowOpacity = 0.25;
  self.closeShadowView.layer.shadowRadius = 10;
  self.closeShadowView.layer.shadowOffset = CGSizeMake(0, 6);
  [self addSubview:self.closeShadowView];

  [self.closeShadowView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self).offset(40);
    make.right.equalTo(self).offset(-40);
    make.bottom.equalTo(self).offset(-12);
    make.height.mas_equalTo(40);
  }];

  // 玻璃模糊层
  self.closeBlurView =
  [[UIVisualEffectView alloc]
   initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialLight]];
  self.closeBlurView.layer.cornerRadius = 20;
  self.closeBlurView.clipsToBounds = YES;
  [self.closeShadowView addSubview:self.closeBlurView];

  [self.closeBlurView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.closeShadowView);
  }];

  // 高光线（玻璃质感）
  UIView *highlight = [[UIView alloc] init];
  highlight.backgroundColor =
  [[UIColor whiteColor] colorWithAlphaComponent:0.25];
  [self.closeBlurView.contentView addSubview:highlight];

  [highlight mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.left.right.equalTo(self.closeBlurView);
    make.height.mas_equalTo(1);
  }];

  // 按钮
  [self.closeBlurView.contentView addSubview:self.closeButton];
  [self.closeButton setTitleColor:UIColor.whiteColor
                         forState:UIControlStateNormal];
  self.closeButton.titleLabel.font =
  [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];

  [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.closeBlurView);
  }];
}


- (void)createScrollView {
  self.scrollView = [[UIScrollView alloc] init];
  self.scrollView.showsVerticalScrollIndicator = YES;
  self.scrollView.alwaysBounceVertical = YES;
  [self addSubview:self.scrollView];

  [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self).offset(20);
    make.right.equalTo(self).offset(-20);
    make.top.equalTo(self.linkButton.mas_bottom).offset(5);
    make.bottom.equalTo(self).offset(-60);
  }];

  self.label = [[UILabel alloc] init];
  self.label.numberOfLines = 0;
  self.label.font = [UIFont systemFontOfSize:16];
  [self.scrollView addSubview:self.label];

  [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.left.right.equalTo(self.scrollView);
    make.width.equalTo(self.scrollView);
  }];
}


- (void)createJumpToWeb {
  self.linkButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [self.linkButton setTitle:@"查看歌手网页" forState:UIControlStateNormal];
  self.linkButton.titleLabel.font = [UIFont systemFontOfSize:14];
  [self.linkButton setTitleColor:UIColor.systemBlueColor
                        forState:UIControlStateNormal];
  [self addSubview:self.linkButton];

  [self.linkButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self).offset(50);
    make.right.equalTo(self).offset(-50);
    make.top.equalTo(self.title.mas_bottom);
    make.height.mas_equalTo(20);
  }];
}

- (void)configureWithDetailData:(ArtistModel *)artistModel {
  self.label.text = [artistModel.briefDesc copy];
  [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
    make.bottom.equalTo(self.scrollView);
  }];
}

@end
