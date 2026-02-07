//
//  ScrollTableViewCell.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/20.
//


#import "ScrollTableViewCell.h"
#import <Masonry.h>
#import "SongDBModel.h"
@implementation ScrollTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {

  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.contentView.backgroundColor = [UIColor colorWithRed:138/225.0f green:138/225.0f blue:138/225.0f alpha:0.2];
    [self setBaseUI];
  }
  return self;
}


- (void)configWithSong:(SongDBModel*)model {
  self.songNameLabel.text = [model.songName copy];
  self.artistNameLabel.text = [model.artistName copy];
}

- (void)setBaseUI {
  self.songImageView = [[UIImageView alloc] init];
  self.songImageView.layer.masksToBounds = YES;
  self.songImageView.contentMode = UIViewContentModeScaleAspectFill;
  [self.contentView addSubview:self.songImageView];

  self.songNameLabel = [[UILabel alloc] init];
  self.songNameLabel.textColor = [UIColor whiteColor];
  self.songNameLabel.font = [UIFont systemFontOfSize:16];
  self.songNameLabel.backgroundColor = [UIColor clearColor];
  [self.contentView addSubview:self.songNameLabel];

  self.artistNameLabel = [[UILabel alloc] init];
  self.artistNameLabel.textColor = [UIColor lightGrayColor];
  self.artistNameLabel.font = [UIFont systemFontOfSize:14];
  self.artistNameLabel.backgroundColor = [UIColor clearColor];
  [self.contentView addSubview:self.artistNameLabel];
}

- (void)setCellType:(CustomCollectionViewCellType)cellType {
  _cellType = cellType;
  [self resetUI];
  if (cellType == CustomCollectionViewCellTypeSong) {
    [self setUpSongUI];
  } else if (cellType == CustomCollectionViewCellTypePodcasting) {
    [self setUpPodcastingUI];
  } else {
    [self setUpNoteUI];
  }
}

- (void)setUpSongUI {
  self.songNameLabel.hidden = NO;
  self.artistNameLabel.hidden = NO;
  self.songImageView.layer.cornerRadius = 8;
  [self.songImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
  //  make.left.top.equalTo(self.contentView);
    make.left.equalTo(self.contentView).offset(13);
    make.top.equalTo(self.contentView).offset(7);
    make.bottom.equalTo(self.contentView).offset(-7);
    make.width.equalTo(self.contentView.mas_height).offset(-14);
  }];

  [self.songNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.songImageView.mas_right).offset(10);
    make.top.equalTo(self.songImageView.mas_top).offset(4);
    make.right.equalTo(self.contentView).offset(-10);
    make.height.mas_equalTo(25);
  }];

  [self.artistNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.songNameLabel);
    make.top.equalTo(self.songNameLabel.mas_bottom).offset(8);
    make.right.equalTo(self.contentView).offset(-10);
    make.height.mas_equalTo(20);
  }];
}
- (void)setUpPodcastingUI {
  self.songNameLabel.hidden = YES;
  self.artistNameLabel.hidden = YES;
}

- (void)setUpNoteUI {
  self.songNameLabel.hidden = YES;
  self.artistNameLabel.hidden = YES;
}


- (void)resetUI {
  [self.songImageView mas_remakeConstraints:^(MASConstraintMaker *make) {}];
  [self.songNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {}];
  [self.artistNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {}];
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
