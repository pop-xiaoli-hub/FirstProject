//
//  DownloadTableViewCell.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/2.
//

#import "DownloadTableViewCell.h"
#import <Masonry.h>
#import "LocalDownloadSongs.h"
@interface DownloadTableViewCell()
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *artistLabel;
@property (nonatomic, strong) UIImageView* songImageView;
@end

@implementation DownloadTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

    self.backgroundColor = UIColor.clearColor;

    _songImageView = [[UIImageView alloc] init];
    _songImageView.layer.masksToBounds = YES;
    _songImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_songImageView];

    _nameLabel = [[UILabel alloc] init];
    _nameLabel.textColor = UIColor.whiteColor;
    _nameLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:_nameLabel];

    _artistLabel = [[UILabel alloc] init];
    _artistLabel.textColor = [UIColor colorWithWhite:1 alpha:0.6];
    _artistLabel.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:_artistLabel];

    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.contentView).offset(10);
      make.left.right.equalTo(self.contentView).inset(16);
    }];

    [_artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(_nameLabel.mas_bottom).offset(4);
      make.left.right.equalTo(_nameLabel);
      make.bottom.equalTo(self.contentView).offset(-10);
    }];
  }
  return self;
}

- (void)configWithSong:(LocalDownloadSongs *)song {
  self.nameLabel.text = song.songName;
  self.artistLabel.text = [song.artistName copy];
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
