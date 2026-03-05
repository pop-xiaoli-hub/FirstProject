//
//  CountHeaderCell.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/15.
//

#import "CountHeaderCell.h"
#import "UserModel.h"
#import <Masonry/Masonry.h>

@interface CountHeaderCell ()
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *editProfileButton;
@property (nonatomic, strong) UIVisualEffectView *editButtonGlassView;
@end

@implementation CountHeaderCell

static UIColor *spotifyGreen(void) {
  return [UIColor colorWithRed:29/255.0 green:185/255.0 blue:84/255.0 alpha:1];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];

    _avatarView = [[UIImageView alloc] init];
    _avatarView.layer.cornerRadius = 40;
    _avatarView.clipsToBounds = YES;
    _avatarView.layer.borderWidth = 4;
    _avatarView.layer.borderColor = spotifyGreen().CGColor;
    _avatarView.userInteractionEnabled = YES;
    _avatarView.contentMode = UIViewContentModeScaleAspectFill;
    _avatarView.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1];
    [self.contentView addSubview:_avatarView];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTap)];
    [_avatarView addGestureRecognizer:tap];

    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
    _nameLabel.textAlignment = NSTextAlignmentLeft;
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_nameLabel];

    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    _editButtonGlassView = [[UIVisualEffectView alloc] initWithEffect:effect];
    _editButtonGlassView.layer.cornerRadius = 10;
    _editButtonGlassView.layer.masksToBounds = YES;
    _editButtonGlassView.alpha = 0.7;
    [self.contentView addSubview:_editButtonGlassView];

    _editProfileButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_editProfileButton setTitle:@"已关注120人, 粉丝342人" forState:UIControlStateNormal];
    _editProfileButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_editProfileButton setTitleColor:[UIColor colorWithWhite:0.9 alpha:1] forState:UIControlStateNormal];
    _editProfileButton.backgroundColor = [UIColor clearColor];
    [_editProfileButton addTarget:self action:@selector(avatarTap) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_editProfileButton];

    [_editButtonGlassView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(_nameLabel);
      make.top.equalTo(self.contentView.mas_centerY).offset(2);
      make.height.mas_equalTo(36);
      make.width.mas_equalTo(200);
    }];
    [_editProfileButton mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(_editButtonGlassView);
    }];

    [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.contentView).offset(20);
      make.centerY.equalTo(self.contentView);
      make.width.height.mas_equalTo(80);
    }];

    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(_avatarView.mas_right).offset(20);
      make.right.equalTo(self.contentView).offset(-20);
      make.bottom.equalTo(self.contentView.mas_centerY).offset(-4);
    }];

  }
  return self;
}

- (void)configWithUser:(UserModel *)user {
  self.avatarView.image = user.avatar;
  self.nameLabel.text = user.name ?: @"";
}

- (void)avatarTap {
  if (self.tapAvatarBlock) {
    self.tapAvatarBlock();
  }
}

- (void)awakeFromNib {
  [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
}

@end
