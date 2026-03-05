//
//  LyricTableViewCell.m
//  MySpotify
//

#import "LyricTableViewCell.h"
#import <Masonry.h>

static NSString *const kLyricCellId = @"LyricCell";

@implementation LyricTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    _lyricLabel = [[UILabel alloc] init];
    _lyricLabel.textAlignment = NSTextAlignmentCenter;
    _lyricLabel.numberOfLines = 2;
    _lyricLabel.font = [UIFont systemFontOfSize:15];
    _lyricLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1];
    [self.contentView addSubview:_lyricLabel];
    [_lyricLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.contentView.mas_left).offset(12);
      make.right.equalTo(self.contentView.mas_right).offset(-12);
      make.centerY.equalTo(self.contentView);
    }];
  }
  return self;
}

- (void)setLyricText:(NSString *)text highlighted:(BOOL)highlighted {
  _lyricLabel.text = text ?: @"";
  if (highlighted) {
    _lyricLabel.font = [UIFont boldSystemFontOfSize:18];
    _lyricLabel.textColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor colorWithWhite:0.25 alpha:0.6];
    self.contentView.layer.cornerRadius = 8;
    self.contentView.layer.masksToBounds = YES;
  } else {
    _lyricLabel.font = [UIFont systemFontOfSize:15];
    _lyricLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1];
    self.contentView.backgroundColor = [UIColor clearColor];
  }
}

- (void)prepareForReuse {
  [super prepareForReuse];
  _lyricLabel.text = nil;
  _lyricLabel.font = [UIFont systemFontOfSize:15];
  _lyricLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1];
  self.contentView.backgroundColor = [UIColor clearColor];
}

@end
