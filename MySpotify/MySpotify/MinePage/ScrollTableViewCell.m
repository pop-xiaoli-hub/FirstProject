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

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.contentView.backgroundColor = [UIColor clearColor];
    [self setBaseUI];
  }
  return self;
}


- (void)configWithSong:(SongDBModel*)model {
  self.songNameLabel.text = [model.songName copy];
  self.artistNameLabel.text = [model.artistName copy];
}

static UIColor *spotifyGreen(void) {
  return [UIColor colorWithRed:29/255.0 green:185/255.0 blue:84/255.0 alpha:1];
}

- (void)setBaseUI {
  self.indexLabel = [[UILabel alloc] init];
  self.indexLabel.textColor = [UIColor colorWithWhite:0.55 alpha:1];
  self.indexLabel.font = [UIFont systemFontOfSize:14];
  self.indexLabel.textAlignment = NSTextAlignmentRight;
  [self.contentView addSubview:self.indexLabel];

  self.songImageView = [[UIImageView alloc] init];
  self.songImageView.layer.masksToBounds = YES;
  self.songImageView.contentMode = UIViewContentModeScaleAspectFill;
  [self.contentView addSubview:self.songImageView];

  self.songNameLabel = [[UILabel alloc] init];
  self.songNameLabel.textColor = [UIColor whiteColor];
  self.songNameLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
  self.songNameLabel.backgroundColor = [UIColor clearColor];
  [self.contentView addSubview:self.songNameLabel];

  self.artistNameLabel = [[UILabel alloc] init];
  self.artistNameLabel.textColor = [UIColor colorWithWhite:0.55 alpha:1];
  self.artistNameLabel.font = [UIFont systemFontOfSize:13];
  self.artistNameLabel.backgroundColor = [UIColor clearColor];
  [self.contentView addSubview:self.artistNameLabel];

  self.trailingIconView = [[UIImageView alloc] init];
  self.trailingIconView.contentMode = UIViewContentModeScaleAspectFit;
  self.trailingIconView.tintColor = [UIColor colorWithWhite:0.55 alpha:1];
  [self.contentView addSubview:self.trailingIconView];

  self.yearLabel = [[UILabel alloc] init];
  self.yearLabel.textColor = [UIColor colorWithWhite:0.55 alpha:1];
  self.yearLabel.font = [UIFont systemFontOfSize:13];
  self.yearLabel.text = @"'20";
  [self.contentView addSubview:self.yearLabel];

  if (@available(iOS 13.0, *)) {
    UIImage *folder = [UIImage systemImageNamed:@"folder"];
    if (folder) self.trailingIconView.image = [folder imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  }

  UIView *selBg = [[UIView alloc] init];
  selBg.backgroundColor = [spotifyGreen() colorWithAlphaComponent:0.25];
  self.selectedBackgroundView = selBg;
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
  self.indexLabel.hidden = NO;
  self.songImageView.hidden = NO;
  self.songNameLabel.hidden = NO;
  self.artistNameLabel.hidden = NO;
  self.trailingIconView.hidden = NO;
  self.yearLabel.hidden = NO;
  self.songImageView.layer.cornerRadius = 6;
  [self.indexLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.contentView).offset(16);
    make.centerY.equalTo(self.contentView);
    make.width.mas_equalTo(20);
  }];
  [self.songImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.indexLabel.mas_right).offset(12);
    make.top.equalTo(self.contentView).offset(10);
    make.bottom.equalTo(self.contentView).offset(-10);
    make.width.equalTo(self.songImageView.mas_height);
  }];
  [self.songNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.songImageView.mas_right).offset(14);
    make.right.lessThanOrEqualTo(self.trailingIconView.mas_left).offset(-8);
    make.top.equalTo(self.contentView).offset(14);
    make.height.mas_equalTo(20);
  }];
  [self.artistNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.songNameLabel);
    make.right.lessThanOrEqualTo(self.trailingIconView.mas_left).offset(-8);
    make.top.equalTo(self.songNameLabel.mas_bottom).offset(2);
    make.height.mas_equalTo(16);
  }];
  [self.yearLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.right.equalTo(self.contentView).offset(-16);
    make.centerY.equalTo(self.contentView);
  }];
  [self.trailingIconView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.right.equalTo(self.yearLabel.mas_left).offset(-10);
    make.centerY.equalTo(self.contentView);
    make.width.height.mas_equalTo(22);
  }];
}
- (void)setUpPodcastingUI {
  self.indexLabel.hidden = YES;
  self.songImageView.hidden = YES;
  self.songNameLabel.hidden = YES;
  self.artistNameLabel.hidden = YES;
  self.trailingIconView.hidden = YES;
  self.yearLabel.hidden = YES;
  [self.songImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.left.top.equalTo(self.contentView);
    make.size.mas_equalTo(CGSizeZero);
  }];
}

- (void)setUpNoteUI {
  self.indexLabel.hidden = YES;
  self.songImageView.hidden = YES;
  self.songNameLabel.hidden = YES;
  self.artistNameLabel.hidden = YES;
  self.trailingIconView.hidden = YES;
  self.yearLabel.hidden = YES;
  [self.songImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.left.top.equalTo(self.contentView);
    make.size.mas_equalTo(CGSizeZero);
  }];
}

- (void)resetUI {
  self.songImageView.hidden = NO;
  self.indexLabel.hidden = NO;
  self.trailingIconView.hidden = NO;
  self.yearLabel.hidden = NO;
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
