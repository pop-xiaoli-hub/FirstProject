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
@end

@implementation CountHeaderCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    self.backgroundColor = UIColor.clearColor;

    _avatarView = [[UIImageView alloc] init];
    _avatarView.layer.cornerRadius = 50;
    _avatarView.clipsToBounds = YES;
    _avatarView.userInteractionEnabled = YES;
    _avatarView.layer.masksToBounds = YES;
    _avatarView.layer.borderWidth = 5;
    _avatarView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [self.contentView addSubview:_avatarView];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTap)];
    [_avatarView addGestureRecognizer:tap];

    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont boldSystemFontOfSize:20];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:_nameLabel];

    [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.centerX.equalTo(self.contentView);
      make.top.equalTo(self.contentView).offset(20);
      make.width.height.mas_equalTo(100);
    }];

    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(_avatarView.mas_bottom).offset(10);
      make.centerX.equalTo(self.contentView);
    }];
  }
  return self;
}

- (void)configWithUser:(UserModel *)user {
  self.avatarView.image = user.avatar;
  self.nameLabel.text = user.name;
}

- (void)avatarTap {
  if (self.tapAvatarBlock) {
    self.tapAvatarBlock();
  }
}

- (void)awakeFromNib {
  [super awakeFromNib];
  // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

@end

