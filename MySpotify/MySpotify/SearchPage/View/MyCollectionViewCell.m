//
//  MyCollectionViewCell.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/19.
//

#import "MyCollectionViewCell.h"
#import "CommentModel.h"
#import "CommentUserModel.h"

static const CGFloat kAvatarSize = 18.0;
static const CGFloat kUserRowBottomInset = 5.0;
static const CGFloat kTextHorizontalInset = 10.0;
static const CGFloat kTextTopInset = 4.0;
static const CGFloat kTextToUserRowSpacing = 4.0;

@interface MyCollectionViewCell ()
@property (nonatomic, assign) BOOL compactFirstItem;
@end

@implementation MyCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor colorWithRed:32 / 255.0 green:33 / 255.0 blue:46 / 255.0 alpha:0.92];
    self.contentView.layer.cornerRadius = 12.0;
    self.contentView.layer.masksToBounds = YES;
    self.contentView.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
    self.contentView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.08].CGColor;
    [self setUpUI];
  }
  return self;
}

- (void)configureWithCommentModel:(CommentModel *)model compactFirstItem:(BOOL)compactFirstItem {
  self.compactFirstItem = compactFirstItem;
  self.textLabel.text = [model.content copy];
  CommentUserModel *user = model.user;
  self.userNameLabel.text = [user.nickname copy];
  self.labelOfLiked.text = [NSString stringWithFormat:@"%ld", (long)model.likedCount];
  self.textLabel.numberOfLines = compactFirstItem ? 1 : 2;
  self.textLabel.font = compactFirstItem
      ? [UIFont systemFontOfSize:12 weight:UIFontWeightRegular]
      : [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
}

- (void)setUpUI {
  [self setUpImageView];
  [self setUpBackView];
  [self setUpUserHeaderView];
  [self createLikedLabel];
  [self createButtton];
  [self setUpUserNameLabel];
  [self createTextLabel];
}

- (void)createLikedLabel {
  self.labelOfLiked = [[UILabel alloc] init];
  self.labelOfLiked.textAlignment = NSTextAlignmentRight;
  self.labelOfLiked.backgroundColor = [UIColor clearColor];
  self.labelOfLiked.textColor = [UIColor colorWithWhite:1 alpha:0.7];
  self.labelOfLiked.font = [UIFont monospacedDigitSystemFontOfSize:11 weight:UIFontWeightMedium];
  [self.backView addSubview:self.labelOfLiked];
  [self.labelOfLiked mas_makeConstraints:^(MASConstraintMaker *make) {
    make.right.equalTo(self.backView.mas_right).offset(-kTextHorizontalInset);
    make.centerY.equalTo(self.headerView.mas_centerY);
    make.width.mas_greaterThanOrEqualTo(14);
  }];
}

- (void)createButtton {
  self.buttonOfLiked = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.buttonOfLiked setImage:[[UIImage imageNamed:@"heart.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
  [self.buttonOfLiked setImage:[[UIImage imageNamed:@"selectedHeart.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
  [self.backView addSubview:self.buttonOfLiked];
  [self.buttonOfLiked mas_makeConstraints:^(MASConstraintMaker *make) {
    make.right.equalTo(self.labelOfLiked.mas_left).offset(-2);
    make.centerY.equalTo(self.headerView.mas_centerY);
    make.width.height.mas_equalTo(20);
  }];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  [self applyAvatarMask];
}

/// 头像尺寸由约束固定为 kAvatarSize，不可用 bounds.width/2：首帧 width 可能为 0，会得到方角。
- (void)applyAvatarMask {
  CGFloat r = kAvatarSize * 0.5;
  self.headerView.layer.cornerRadius = r;
  self.headerView.layer.masksToBounds = YES;
  self.headerView.clipsToBounds = YES;
  if (@available(iOS 13.0, *)) {
    self.headerView.layer.cornerCurve = kCACornerCurveCircular;
  }
}

- (void)setUpBackView {
  self.backView = [[UIView alloc] init];
  [self.contentView addSubview:self.backView];
  self.backView.backgroundColor = [UIColor clearColor];
  [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.bottom.equalTo(self.contentView);
    make.top.equalTo(self.coverImageView.mas_bottom);
  }];
}

- (void)createTextLabel {
  self.textLabel = [[UILabel alloc] init];
  self.textLabel.backgroundColor = [UIColor clearColor];
  self.textLabel.textColor = [UIColor colorWithWhite:1 alpha:0.95];
  [self.backView addSubview:self.textLabel];
  self.textLabel.textAlignment = NSTextAlignmentLeft;
  self.textLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
  self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.backView.mas_left).offset(kTextHorizontalInset);
    make.right.equalTo(self.backView.mas_right).offset(-kTextHorizontalInset);
    make.top.equalTo(self.backView.mas_top).offset(kTextTopInset);
    make.bottom.equalTo(self.headerView.mas_top).offset(-kTextToUserRowSpacing);
  }];
  self.textLabel.numberOfLines = 2;
}

- (void)setUpUserNameLabel {
  self.userNameLabel = [[UILabel alloc] init];
  self.userNameLabel.textAlignment = NSTextAlignmentLeft;
  self.userNameLabel.backgroundColor = [UIColor clearColor];
  self.userNameLabel.textColor = [UIColor colorWithWhite:1 alpha:0.55];
  self.userNameLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
  self.userNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  self.userNameLabel.numberOfLines = 1;
  [self.backView addSubview:self.userNameLabel];
  [self.userNameLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
  [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.headerView.mas_right).offset(5);
    make.centerY.equalTo(self.headerView.mas_centerY);
    make.right.lessThanOrEqualTo(self.buttonOfLiked.mas_left).offset(-6);
  }];
}

- (void)setUpUserHeaderView {
  self.headerView = [[UIImageView alloc] init];
  [self.backView addSubview:self.headerView];
  self.headerView.contentMode = UIViewContentModeScaleAspectFill;
  self.headerView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15];
  [self applyAvatarMask];
  [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.backView.mas_left).offset(kTextHorizontalInset);
    make.bottom.equalTo(self.backView.mas_bottom).offset(-kUserRowBottomInset);
    make.width.height.mas_equalTo(kAvatarSize);
  }];
}

- (void)setUpImageView {
  self.coverImageView = [[UIImageView alloc] init];
  [self.contentView addSubview:self.coverImageView];
  self.coverImageView.layer.masksToBounds = YES;
  self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
  [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.top.equalTo(self.contentView);
    make.height.equalTo(self.contentView.mas_width);
  }];
}

- (void)prepareForReuse {
  [super prepareForReuse];
  self.coverImageView.image = nil;
  self.headerView.image = nil;
  self.userNameLabel.text = nil;
  self.textLabel.text = nil;
  self.compactFirstItem = NO;
  self.textLabel.numberOfLines = 2;
  self.textLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
  [self.buttonOfLiked removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
}

@end
