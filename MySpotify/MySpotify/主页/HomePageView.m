//
//  HomePageView.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/11/11.
//红绿蓝138

#import "HomePageView.h"
#import "Masonry.h"
#import "CustomHomePageCell.h"
@implementation HomePageView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor blackColor];
    [self createButtonOfDiffirentClasses];
    [self createTableView];
  }
  return self;
}



- (void)createTableView {
  self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
  self.tableView.backgroundColor = [UIColor clearColor];
  [self addSubview:self.tableView];
  [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.buttonOfExpand.mas_bottom).offset(10);
      make.left.right.equalTo(self);
      make.bottom.equalTo(self.mas_bottom).offset(-90);
  }];
}

- (void)createButtonOfDiffirentClasses {
  _buttonOfExpand = [UIButton buttonWithType:UIButtonTypeCustom];
  [_buttonOfExpand setImage:[UIImage imageNamed:@"expand.png"] forState:UIControlStateNormal];
  [self addSubview:_buttonOfExpand];
  [_buttonOfExpand mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.mas_top).offset(60);
      make.left.equalTo(self.mas_left).offset(20);
      make.height.width.mas_equalTo(30);
  }];

  _buttonOfAll = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [_buttonOfAll setTitle:@"全部" forState:UIControlStateNormal];
  [_buttonOfAll setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  _buttonOfAll.backgroundColor = [UIColor colorWithRed:138/225.0f green:138/225.0f blue:138/225.0f alpha:0.8];
  [self addSubview:_buttonOfAll];
  [_buttonOfAll mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(_buttonOfExpand);
      make.left.equalTo(self.buttonOfExpand);
      make.width.mas_equalTo(60);
      make.height.mas_equalTo(30);
  }];
  _buttonOfAll.alpha = 0;
  _buttonOfAll.layer.masksToBounds = YES;
  _buttonOfAll.layer.cornerRadius = 15;

  _buttonOfSongs = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [_buttonOfSongs setTitle:@"歌曲" forState:UIControlStateNormal];
  [_buttonOfSongs setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  _buttonOfSongs.backgroundColor = [UIColor colorWithRed:138/225.0f green:138/225.0f blue:138/225.0f alpha:0.8];
  [self addSubview:_buttonOfSongs];
  [_buttonOfSongs mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(_buttonOfExpand);
      make.left.equalTo(self.buttonOfExpand);
      make.width.mas_equalTo(60);
      make.height.mas_equalTo(30);
  }];
  _buttonOfSongs.alpha = 0;
  _buttonOfSongs.layer.masksToBounds = YES;
  _buttonOfSongs.layer.cornerRadius = 15;


  _buttonOfAudioBooks = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [_buttonOfAudioBooks setTitle:@"播客" forState:UIControlStateNormal];
  [_buttonOfAudioBooks setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  _buttonOfAudioBooks.backgroundColor = [UIColor colorWithRed:138/225.0f green:138/225.0f blue:138/225.0f alpha:0.8];
  [self addSubview:_buttonOfAudioBooks];
  [_buttonOfAudioBooks mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(_buttonOfExpand);
      make.left.equalTo(self.buttonOfExpand);
      make.width.mas_equalTo(60);
      make.height.mas_equalTo(30);
  }];
  _buttonOfAudioBooks.alpha = 0;
  _buttonOfAudioBooks.layer.masksToBounds = YES;
  _buttonOfAudioBooks.layer.cornerRadius = 15;

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
