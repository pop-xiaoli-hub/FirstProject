//
//  MyCollectionViewCell.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/19.
//

#import "MyCollectionViewCell.h"
#import "CommentModel.h"
#import "CommentUserModel.h"
@implementation MyCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor =  [UIColor colorWithRed:138/225.0f green:138/225.0f blue:138/225.0f alpha:0.2];
    [self setUpUI];
  }
  return self;
}

- (void)configureWithCommentModel:(CommentModel *)model {
  self.textLabel.text = [model.content copy];
  CommentUserModel* user = model.user;
  self.userNameLabel.text = [user.nickname copy];
  self.labelOfLiked.text = [[NSString stringWithFormat:@"%ld", model.likedCount] copy];
}

- (void)setUpUI {
  [self setUpImageView];
  [self setUpBackView];
  [self createTextLabel];
  [self setUpUserHeaderView];
  [self setUpUserNameLabel];
  [self createButtton];
  [self createLikedLabel];
}

- (void)createLikedLabel {
  self.labelOfLiked = [[UILabel alloc] init];
  self.labelOfLiked.textAlignment = NSTextAlignmentLeft;
  self.labelOfLiked.backgroundColor = [UIColor clearColor];
  self.labelOfLiked.textColor = [UIColor whiteColor];
  self.labelOfLiked.font = [UIFont systemFontOfSize:16];
  [self.backView addSubview:self.labelOfLiked];
 // self.labelOfLiked.textAlignment = NSTextAlignmentLeft;
  [self.labelOfLiked mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.buttonOfLiked.mas_right).offset(4);
      make.centerY.equalTo(self.buttonOfLiked.mas_centerY);
      make.height.equalTo(self.buttonOfLiked.mas_height);
      make.right.equalTo(self.backView.mas_right);
  }];
}


- (void)createButtton {
  self.buttonOfLiked = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.buttonOfLiked setImage:[[UIImage imageNamed:@"heart.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
  [self.buttonOfLiked setImage:[[UIImage imageNamed:@"selectedHeart.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
  [self.backView addSubview:self.buttonOfLiked];
  [self.buttonOfLiked mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.userNameLabel.mas_right).offset(5);
      make.right.equalTo(self.backView.mas_right).offset(-40);
      make.centerY.equalTo(self.userNameLabel.mas_centerY);
      make.height.mas_equalTo(20);
  }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.headerView.layer.cornerRadius = self.headerView.frame.size.width / 2.0;
}


- (void)setUpBackView {
  self.backView = [[UIView alloc] init];
  [self.contentView addSubview:self.backView];
  self.backView.backgroundColor = [UIColor clearColor];
  [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.contentView.mas_left);
    make.right.equalTo(self.contentView.mas_right);
    make.top.equalTo(self.coverImageView.mas_bottom);
    make.bottom.equalTo(self.contentView.mas_bottom);
  }];
}

- (void)createTextLabel {
  self.textLabel = [[UILabel alloc] init];
  self.textLabel.backgroundColor = [UIColor clearColor];
  self.textLabel.textColor = [UIColor whiteColor];
  [self.backView addSubview:self.textLabel];
  self.textLabel.textAlignment = NSTextAlignmentLeft;
  self.textLabel.layer.masksToBounds = YES;
  self.textLabel.layer.cornerRadius = 5;
  self.textLabel.font = [UIFont systemFontOfSize:16];
  [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.backView.mas_left).offset(5);
    make.right.equalTo(self.backView.mas_right).offset(-5);
    make.top.equalTo(self.backView.mas_top);
    make.height.equalTo(self.backView).multipliedBy(0.65);
  }];
  self.textLabel.numberOfLines = 0;
  self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
}

- (void)setUpUserNameLabel {
  self.userNameLabel = [[UILabel alloc] init];
//  self.textLabel.text = @"data";
  self.userNameLabel.textAlignment = NSTextAlignmentLeft;
  self.userNameLabel.backgroundColor = [UIColor clearColor];
  self.userNameLabel.textColor = [UIColor whiteColor];
  self.userNameLabel.font = [UIFont systemFontOfSize:13];
  [self.backView addSubview:self.userNameLabel];
  self.userNameLabel.layer.masksToBounds = YES;
  self.userNameLabel.layer.cornerRadius = 5;
  [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.headerView.mas_right).offset(5);
      make.right.equalTo(self.backView.mas_right).offset(-80);
      make.top.equalTo(self.textLabel.mas_bottom).offset(5);
      make.height.equalTo(self.backView).multipliedBy(0.2);
  }];
}

- (void)setUpUserHeaderView {
  self.headerView = [[UIImageView alloc] init];
  [self.backView addSubview:self.headerView];
  self.headerView.layer.masksToBounds = YES;
  self.headerView.contentMode = UIViewContentModeScaleAspectFill;
  [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.backView.mas_left).offset(5);
      make.top.equalTo(self.textLabel.mas_bottom).offset(5);
    make.height.width.equalTo(self.backView.mas_height).multipliedBy(0.2);
  }];
}

- (void)setUpImageView {
  self.coverImageView = [[UIImageView alloc] init];
  [self.contentView addSubview:self.coverImageView];
  self.coverImageView.layer.masksToBounds = YES;
  self.coverImageView.layer.cornerRadius = 10;
  CGFloat randomValue1 = 240 +arc4random_uniform(30);
 // self.coverImageView.clipsToBounds = YES;
  self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
  [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.contentView.mas_left);
    make.right.equalTo(self.contentView.mas_right);
    make.width.equalTo(self.contentView.mas_width);
    make.top.equalTo(self.contentView.mas_top);
  //  make.height.equalTo(self.contentView.mas_width).offset(randomValue1);
    make.height.mas_offset(randomValue1);
  }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.coverImageView.image = nil;
    self.userNameLabel.text = nil;
  self.textLabel.text = nil;
  [self.buttonOfLiked removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
}

// 李国飞是个大傻蛋，李国飞是一个大傻蛋

@end
