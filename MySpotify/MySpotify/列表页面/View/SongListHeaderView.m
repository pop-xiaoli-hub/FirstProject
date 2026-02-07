//
//  SongListHeaderView.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/20.
//

#import "SongListHeaderView.h"
#import <Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import "PlaylistModel.h"
#import "PlaylistCreatorModel.h"
@interface SongListHeaderView()
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIImageView *artistImageView;
@property (nonatomic, strong) UILabel *artistNameLabel;

// 顶部按钮
@property (nonatomic, strong) UIStackView *topStack;

// 底部按钮
@property (nonatomic, strong) UIButton *playAllButton;
@property (nonatomic, strong) UIButton *downloadButton;
@property (nonatomic, strong) UIButton *sortButton;
@end

@implementation SongListHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor clearColor];

    // 封面
    _coverImageView = [[UIImageView alloc] init];
    _coverImageView.layer.cornerRadius = 10;
    _coverImageView.clipsToBounds = YES;
    [self addSubview:_coverImageView];

    // 标题
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont boldSystemFontOfSize:22];
    _titleLabel.textColor = UIColor.whiteColor;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.numberOfLines = 2;
    [self addSubview:_titleLabel];

    // 描述
    _descLabel = [[UILabel alloc] init];
    _descLabel.font = [UIFont systemFontOfSize:13];
    _descLabel.textColor = [UIColor colorWithWhite:1 alpha:0.6];
    _descLabel.textAlignment = NSTextAlignmentCenter;
    _descLabel.numberOfLines = 2;
    [self addSubview:_descLabel];

    // 作者头像
    _artistImageView = [[UIImageView alloc] init];
    _artistImageView.layer.cornerRadius = 16;
    _artistImageView.clipsToBounds = YES;
    [self addSubview:_artistImageView];

    // 作者名
    _artistNameLabel = [[UILabel alloc] init];
    _artistNameLabel.font = [UIFont systemFontOfSize:15];
    _artistNameLabel.textColor = [UIColor colorWithWhite:1 alpha:0.85];
    [self addSubview:_artistNameLabel];

    [self setUpViews];
  }
  return self;
}

- (void)setUpViews {

    // 封面
    [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(80);
        make.centerX.equalTo(self);
        make.width.height.mas_equalTo(160);
    }];

    // 标题
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_coverImageView.mas_bottom).offset(16);
        make.left.right.equalTo(self).inset(20);
    }];

    // 描述
    [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel.mas_bottom).offset(8);
        make.left.right.equalTo(self).inset(20);
    }];

    // 作者头像
    [_artistImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_descLabel.mas_bottom).offset(14);
        make.left.equalTo(self).offset(20);
        make.width.height.mas_equalTo(32);
    }];

    // 作者名
    [_artistNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_artistImageView);
        make.left.equalTo(_artistImageView.mas_right).offset(10);
    }];

    [self setupActionViews];
}

- (void)setupActionViews {

    // ===== 顶部按钮（转发 / 评论 / 喜欢）=====
    _topStack = [[UIStackView alloc] init];
    _topStack.axis = UILayoutConstraintAxisHorizontal;
    _topStack.spacing = 24;
    _topStack.alignment = UIStackViewAlignmentCenter;
    [self addSubview:_topStack];

    [_topStack addArrangedSubview:[self createTopItem:@"square.and.arrow.up" type:@"share"]];
    [_topStack addArrangedSubview:[self createTopItem:@"text.bubble" type:@"comment"]];
    [_topStack addArrangedSubview:[self createTopItem:@"heart" type:@"like"]];

    [_topStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.artistImageView);
        make.right.equalTo(self).offset(-20);
    }];

    // ===== 底部按钮（播放全部 / 下载 / 排序）=====
    _playAllButton = [self createPlayAllButton];
    _downloadButton = [self createIconButton:@"arrow.down.circle"];
    _sortButton = [self createIconButton:@"line.3.horizontal.decrease"];

    [self addSubview:_playAllButton];
    [self addSubview:_downloadButton];
    [self addSubview:_sortButton];

    // Masonry 约束
    [_playAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(16);
        make.top.equalTo(self.artistImageView.mas_bottom).offset(24);
        make.height.mas_equalTo(44);
        make.width.greaterThanOrEqualTo(@140);
    }];

    [_downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-16);
        make.centerY.equalTo(_playAllButton);
        make.width.height.mas_equalTo(44);
    }];

    [_sortButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_downloadButton.mas_left).offset(-12);
        make.centerY.equalTo(_playAllButton);
        make.width.height.mas_equalTo(44);
    }];
}

- (UIView *)createTopItem:(NSString *)icon type:(NSString *)type {
    UIStackView *container = [[UIStackView alloc] init];
    container.axis = UILayoutConstraintAxisVertical;
    container.alignment = UIStackViewAlignmentCenter;
    container.spacing = 4;
    container.accessibilityIdentifier = type;

    UIImageView *iconView = [[UIImageView alloc] initWithImage:
        [[UIImage systemImageNamed:icon] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    iconView.tintColor = UIColor.whiteColor;

    UILabel *label = [[UILabel alloc] init];
    label.text = @"--";
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor colorWithWhite:1 alpha:0.7];

    [container addArrangedSubview:iconView];
    [container addArrangedSubview:label];

    UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topItemTapped:)];
    [container addGestureRecognizer:tap];

    return container;
}

- (void)topItemTapped:(UITapGestureRecognizer* )tap {

}


- (UIButton *)createPlayAllButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.layer.cornerRadius = 22;
    btn.clipsToBounds = YES;
    btn.backgroundColor = [UIColor colorWithWhite:1 alpha:0.12];

    [btn setTitle:@" 播放全部" forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];

    UIImage *icon = [[UIImage systemImageNamed:@"play.fill"]
        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [btn setImage:icon forState:UIControlStateNormal];
    btn.tintColor = UIColor.whiteColor;

    [btn addTarget:self
            action:@selector(playAllTapped)
  forControlEvents:UIControlEventTouchUpInside];

    return btn;
}

- (void)playAllTapped {

}

- (UIButton *)createIconButton:(NSString *)iconName {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *icon = [[UIImage systemImageNamed:iconName]
        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [btn setImage:icon forState:UIControlStateNormal];
    btn.tintColor = UIColor.whiteColor;
    return btn;
}

- (void)configWithPlayList:(PlaylistModel *)playlist {
  SDImageResizingTransformer *transformer =
  [SDImageResizingTransformer transformerWithSize:CGSizeMake(200, 200) scaleMode:SDImageScaleModeAspectFill];
  [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:playlist.coverImgUrl] placeholderImage:nil options:SDWebImageScaleDownLargeImages context:@{
    SDWebImageContextImageTransformer: transformer, SDWebImageContextImageThumbnailPixelSize: @(CGSizeMake(200, 200)), SDWebImageContextImageForceDecodePolicy: @(SDImageForceDecodePolicyNever)
  }];
  self.titleLabel.text = [playlist.name copy];
  self.descLabel.text = playlist.desc.length ? [playlist.desc copy]: @"网易云音乐歌单";
  PlaylistCreatorModel* creator = playlist.creator;
  self.artistNameLabel.text = [creator.nickname copy];
  [self.artistImageView sd_setImageWithURL:[NSURL URLWithString:creator.avatarUrl] placeholderImage:nil options:SDWebImageScaleDownLargeImages context:@{
    SDWebImageContextImageTransformer: transformer, SDWebImageContextImageThumbnailPixelSize: @(CGSizeMake(200, 200)), SDWebImageContextImageForceDecodePolicy: @(SDImageForceDecodePolicyNever)
  }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
