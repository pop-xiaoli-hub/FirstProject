//
//  MinePlaylistCollectionCell.m
//  MySpotify
//

#import "MinePlaylistCollectionCell.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>

static UIColor *spotifyGreen(void) {
  return [UIColor colorWithRed:29/255.0 green:185/255.0 blue:84/255.0 alpha:1];
}

@interface MinePlaylistCollectionCell ()
@property (nonatomic, strong) UIVisualEffectView *glassView;
@property (nonatomic, strong) UIView *highlightOverlay;
@end

@implementation MinePlaylistCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.contentView.backgroundColor = [UIColor clearColor];
    [self setupGlassBackground];
    [self setupSubviews];
  }
  return self;
}

- (void)setupGlassBackground {
  UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
  _glassView = [[UIVisualEffectView alloc] initWithEffect:effect];
  _glassView.layer.cornerRadius = 12;
  _glassView.layer.masksToBounds = YES;
  _glassView.alpha = 0.6;
  [self.contentView insertSubview:_glassView atIndex:0];
  [_glassView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.contentView);
  }];
}

- (void)setupSubviews {
  _coverImageView = [[UIImageView alloc] init];
  _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
  _coverImageView.layer.cornerRadius = 8;
  _coverImageView.clipsToBounds = YES;
  _coverImageView.backgroundColor = [UIColor colorWithWhite:0.25 alpha:1];
  [self.contentView addSubview:_coverImageView];

  _titleLabel = [[UILabel alloc] init];
  _titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
  _titleLabel.textColor = [UIColor whiteColor];
  _titleLabel.numberOfLines = 1;
  [self.contentView addSubview:_titleLabel];

  _subtitleLabel = [[UILabel alloc] init];
  _subtitleLabel.font = [UIFont systemFontOfSize:12];
  _subtitleLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1];
  _subtitleLabel.numberOfLines = 1;
  [self.contentView addSubview:_subtitleLabel];

  [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.top.equalTo(self.contentView);
    make.height.equalTo(_coverImageView.mas_width);
  }];
  [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.equalTo(self.contentView);
    make.top.equalTo(_coverImageView.mas_bottom).offset(8);
  }];
  [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.equalTo(self.contentView);
    make.top.equalTo(_titleLabel.mas_bottom).offset(2);
  }];

  _highlightOverlay = [[UIView alloc] init];
  _highlightOverlay.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15];
  _highlightOverlay.layer.cornerRadius = 12;
  _highlightOverlay.userInteractionEnabled = NO;
  _highlightOverlay.alpha = 0;
  [self.contentView addSubview:_highlightOverlay];
  [_highlightOverlay mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.contentView);
  }];
}

- (void)configWithTitle:(NSString *)title subtitle:(NSString *)subtitle imageURL:(NSString *)url selected:(BOOL)selected {
  _titleLabel.text = title ?: @"";
  _subtitleLabel.text = subtitle ?: @"";
  _coverImageView.layer.borderWidth = selected ? 2.5 : 0;
  _coverImageView.layer.borderColor = selected ? spotifyGreen().CGColor : [UIColor clearColor].CGColor;
  if (url.length) {
    SDImageResizingTransformer *t = [SDImageResizingTransformer transformerWithSize:CGSizeMake(220, 220) scaleMode:SDImageScaleModeAspectFill];
    [_coverImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil options:SDWebImageScaleDownLargeImages context:@{ SDWebImageContextImageTransformer: t }];
  } else {
    _coverImageView.image = nil;
    _coverImageView.backgroundColor = [UIColor colorWithWhite:0.25 alpha:1];
  }
}

- (void)setHighlighted:(BOOL)highlighted {
  [super setHighlighted:highlighted];
  [UIView animateWithDuration:0.15 animations:^{
    self.highlightOverlay.alpha = highlighted ? 1 : 0;
  }];
}

- (void)playSelectAnimation {
  [UIView animateWithDuration:0.15 animations:^{
    self.transform = CGAffineTransformMakeScale(0.94, 0.94);
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.5 options:0 animations:^{
      self.transform = CGAffineTransformIdentity;
    } completion:nil];
  }];
}

@end
