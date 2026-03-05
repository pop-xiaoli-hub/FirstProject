//
//  CommentHeaderView.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/24.
//

#import "CommentHeaderView.h"
#import <Masonry.h>
#import "SongModel.h"
#import "AlbumModel.h"
#import "ArtistModel.h"
#import <SDWebImage/SDWebImage.h>
@interface CommentHeaderView()
@property (nonatomic, strong)UIVisualEffectView* blurView;
@property (nonatomic, strong)UIView* shadowView;
@end
@implementation CommentHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor clearColor];
    [self createBackView];
    [self setUpUI];
  }
  return self;
}

- (void)createBackView {
  // 阴影容器
  self.shadowView = [[UIView alloc] init];
  self.shadowView.layer.shadowColor = UIColor.blackColor.CGColor;
  self.shadowView.layer.shadowOpacity = 0.25;
  self.shadowView.layer.shadowRadius = 10;
  self.shadowView.layer.shadowOffset = CGSizeMake(0, 6);
  [self addSubview:self.shadowView];

  [self.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self).offset(20);
    make.right.equalTo(self).offset(-20);
    make.top.equalTo(self.mas_top);
    make.height.mas_equalTo(60);
  }];

  // 玻璃模糊层
  self.blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialLight]];
  self.blurView.layer.cornerRadius = 20;
  self.blurView.clipsToBounds = YES;
  [self.shadowView addSubview:self.blurView];

  [self.blurView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.shadowView);
  }];

  // 高光线（玻璃质感）
  UIView *highlight = [[UIView alloc] init];
  highlight.backgroundColor =
  [[UIColor whiteColor] colorWithAlphaComponent:0.25];
  [self.blurView.contentView addSubview:highlight];

  [highlight mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.left.right.equalTo(self.blurView);
    make.height.mas_equalTo(1);
  }];
}

- (void)setUpUI {
  self.imageView = [[UIImageView alloc] init];
  self.imageView.layer.cornerRadius = 10;
  self.imageView.clipsToBounds = YES;
  [self.blurView.contentView addSubview:self.imageView];
  [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.blurView.contentView.mas_left).offset(20);
      make.top.equalTo(self.blurView.contentView.mas_top).offset(5);
      make.height.width.mas_equalTo(50);
  }];
  self.imageView.layer.masksToBounds = YES;
  self.imageView.layer.cornerRadius = 25;
  self.imageView.layer.borderWidth = 5;
  self.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;

  self.label = [[UILabel alloc] init];
  self.label.font = [UIFont boldSystemFontOfSize:18];
  self.label.textColor = UIColor.whiteColor;
  self.label.textAlignment = NSTextAlignmentLeft;
  self.label.numberOfLines = 1;
  [self.blurView.contentView addSubview:self.label];
  [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.imageView.mas_right).offset(20);
      make.centerY.equalTo(self.imageView.mas_centerY);
      make.right.equalTo(self.blurView.contentView.mas_right).offset(-20);
      make.height.mas_equalTo(20);
  }];
}

- (void)configureWithModel:(SongModel* )songModel {
  AlbumModel * albumModel = songModel.album;
  ArtistModel* aristModel = [songModel.artists objectAtIndex:0];
  SDImageResizingTransformer *transformer =
  [SDImageResizingTransformer transformerWithSize:CGSizeMake(200, 200)  scaleMode:SDImageScaleModeAspectFill];
  [self.imageView sd_setImageWithURL:[NSURL URLWithString:albumModel.picUrl] placeholderImage:nil options:SDWebImageScaleDownLargeImages context:@{
    SDWebImageContextImageTransformer: transformer
  }];
  self.label.text = [NSString stringWithFormat:@"%@-%@",songModel.name, aristModel.name];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
