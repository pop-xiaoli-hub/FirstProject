//
//  DetailMusicPlayerView.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/6.
//

#import "DetailMusicPlayerView.h"
#import <Masonry.h>
#import "SongPlayingModel.h"
#import "LyricLine.h"
#import "LyricTableViewCell.h"
#import <SDWebImage.h>
#import "PlaylistManager.h"
#import "MusicSlider.h"
@interface DetailMusicPlayerView () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation DetailMusicPlayerView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self createUI];
//    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCoverTap)];
//    tap.numberOfTouchesRequired = 1;
//    [self addGestureRecognizer:tap];
  }
  return self;
}

- (void)resetControlsWithDownloaded:(BOOL)isDownloaded {
  self.switchButton.selected = YES;
  UIImage *downloadImage = isDownloaded ? [UIImage imageNamed:@"dwnloaded.png"] : [UIImage imageNamed:@"m1.png"];
  UIButton *downloadButton = [self.stackView viewWithTag:101];
  [downloadButton setImage:downloadImage forState:UIControlStateNormal];
  self.slider.value = 0.0;
}

- (void)createUI {
  [self createImageView];
  [self createLyricContainerView];
  [self createSongNameLabel];
  [self createSlider];
  [self createButtonOfPrevious];
  [self createButtonOfNext];
  [self createButtonOfSwitch];
  [self createStackview];
}

- (void)createStackview {
  self.stackView = [[UIStackView alloc] init];
  self.stackView.axis = UILayoutConstraintAxisHorizontal;
  self.stackView.distribution = UIStackViewDistributionFillEqually;
  self.stackView.spacing = 20;
  for (int i = 0; i < 4; i++) {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"m%d.png",i + 1]] forState:UIControlStateNormal];
    [self.stackView addArrangedSubview:button];
    button.tag = 101 + i;
    [button addTarget:self action:@selector(pressButton:) forControlEvents:UIControlEventTouchUpInside];
  }
  [self addSubview:self.stackView];
  [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.mas_left).offset(15);
      make.right.equalTo(self.mas_right).offset(-15);
      make.top.equalTo(self.switchButton.mas_bottom).offset(40);
  }];
}

- (void)pressButton:(UIButton* )button {
  if (self.buttonClickBlock) {
    self.buttonClickBlock(button);
  }
}


//- (void)createDownloadButton {
//  self.downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
//  [self.downloadButton setImage:[[UIImage imageNamed:@"previousSong.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]forState:UIControlStateNormal];
//  [self addSubview:self.downloadButton];
//  [self.downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
//      make.left.equalTo(self.mas_left).offset(50);
//      make.top.equalTo(self.slider.mas_bottom).offset(60);
//      make.height.width.mas_equalTo(40);
//  }];
//}

- (void)configureWithModel:(SongPlayingModel *)model {
  self.songNameLabel.text = [model.name copy];
  SDImageResizingTransformer *transformer =
  [SDImageResizingTransformer transformerWithSize:CGSizeMake(200, 200) scaleMode:SDImageScaleModeAspectFill];
  [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.headerUrl] placeholderImage:nil options:SDWebImageScaleDownLargeImages context:@{
    SDWebImageContextImageTransformer: transformer, SDWebImageContextImageThumbnailPixelSize: @(CGSizeMake(200,200)), SDWebImageContextImageForceDecodePolicy: @(SDImageForceDecodePolicyNever)
  }];
}

#pragma mark - 歌词显示与滚动

// Controller 设置歌词数据（拉取完成后或切歌时传 nil）。若正在显示歌词则立即 reload 列表。
- (void)setLyricLines:(NSArray<LyricLine *> *)lines {
  _lyricLines = lines ? [lines copy] : @[];
  _currentLineIndex = -1;
  if (self.showingLyrics) {
    [self.lyricTableView reloadData];
  }
}

// 切回封面（切歌时或逻辑上需要隐藏歌词时由 Controller 调用）
- (void)resetToCover {
  _showingLyrics = NO;
  self.imageView.hidden = NO;
  self.lyricContainerView.hidden = YES;
  self.lyricContainerView.userInteractionEnabled = NO;
}

// 根据播放时间更新「当前行」并滚动居中。由 Controller 的 timeObserver 约 0.5s 调用一次。
- (void)updateCurrentTime:(NSTimeInterval)currentTime {
  if (self.lyricLines.count == 0 || !self.showingLyrics) {
    return;
  }
  NSInteger newIndex = -1;
  for (NSInteger i = self.lyricLines.count - 1; i >= 0; i--) {
    if (currentTime >= self.lyricLines[i].time) {
      newIndex = (NSInteger)i;
      break;
    }
  }
  if (newIndex == _currentLineIndex) {
    return;
  }
  _currentLineIndex = newIndex;
  [self.lyricTableView reloadData];
  if (newIndex >= 0) {
    NSIndexPath *path = [NSIndexPath indexPathForRow:newIndex inSection:0];
    [self.lyricTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
  }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.lyricLines.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  LyricTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LyricCell" forIndexPath:indexPath];
  LyricLine *line = self.lyricLines[indexPath.row];
  BOOL highlighted = (indexPath.row == self.currentLineIndex);
  [cell setLyricText:line.text highlighted:highlighted];
  return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 44;
}

- (void)createSlider {
  self.slider = [[MusicSlider alloc] init];
  self.slider.minimumValue = 0;
  self.slider.minimumTrackTintColor = [UIColor whiteColor];
  self.slider.maximumTrackTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
  [self.slider setThumbImage:[UIImage new] forState:UIControlStateNormal];
  [self.slider setThumbImage:[UIImage new] forState:UIControlStateHighlighted];
  [self.slider addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
  [self.slider addTarget:self action:@selector(sliderTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
  [self addSubview:self.slider];
  [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.mas_left).offset(20);
      make.right.equalTo(self.mas_right).offset(-20);
      make.top.equalTo(self.songNameLabel.mas_bottom).offset(20);
      make.height.mas_equalTo(30);
  }];
}

-(void)sliderTouchDown:(MusicSlider* )slider {
  [UIView animateWithDuration:0.15 animations:^{
    slider.trackHeight = 10;
    [slider setNeedsLayout];
    [slider layoutIfNeeded];
  }];
}

- (void)sliderTouchUp:(MusicSlider *)slider {
  [UIView animateWithDuration:0.15 animations:^{
    slider.trackHeight = 4;
    [slider setNeedsLayout];
    [slider layoutIfNeeded];
  }];
}

- (void)createSongNameLabel {
  self.songNameLabel = [[UILabel alloc] init];
  self.songNameLabel.layer.masksToBounds = YES;
  self.songNameLabel.backgroundColor = [UIColor clearColor];
  [self addSubview:self.songNameLabel];
  [self.songNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.imageView.mas_bottom).offset(80);
      make.left.equalTo(self.mas_left).offset(10);
      make.right.equalTo(self.mas_right).offset(-10);
      make.height.mas_equalTo(30);
  }];
  self.songNameLabel.textColor = [UIColor lightGrayColor];
  self.songNameLabel.textAlignment = NSTextAlignmentCenter;
//  self.songNameLabel.font = [UIFont systemFontOfSize:30];
  self.songNameLabel.font = [UIFont boldSystemFontOfSize:22];
}

- (void)createImageView {
  self.imageView = [[UIImageView alloc] init];
  self.imageView.userInteractionEnabled = YES;
  [self addSubview:self.imageView];
  [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.mas_left).offset(65);
    make.right.equalTo(self.mas_right).offset(-65);
    make.top.equalTo(self.mas_top).offset(100);
    make.height.mas_equalTo(self.mas_width).offset(-130);
  }];
  self.imageView.layer.masksToBounds = YES;
  self.imageView.contentMode = UIViewContentModeScaleAspectFill;
  self.imageView.layer.cornerRadius = 20;
  self.imageView.layer.borderWidth = 4;
  self.imageView.layer.borderColor = [UIColor darkGrayColor].CGColor;
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCoverTap)];
  [self.imageView addGestureRecognizer:tap];
}

- (void)createLyricContainerView {
  _lyricContainerView = [[UIView alloc] init];
  _lyricContainerView.backgroundColor = [UIColor clearColor];
  _lyricContainerView.layer.cornerRadius = 20;
  _lyricContainerView.layer.masksToBounds = YES;
  _lyricContainerView.hidden = YES;
  _lyricContainerView.userInteractionEnabled = NO;
  [self addSubview:_lyricContainerView];
  [_lyricContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.imageView.mas_left);
    make.right.equalTo(self.imageView.mas_right);
    make.top.equalTo(self.imageView.mas_top).offset(-50);
    make.bottom.equalTo(self.imageView.mas_bottom).offset(50);
  }];
  UIButton *backToCoverBtn = [UIButton buttonWithType:UIButtonTypeSystem];
  [backToCoverBtn setTitle:@"返回封面" forState:UIControlStateNormal];
  [backToCoverBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
  backToCoverBtn.titleLabel.font = [UIFont systemFontOfSize:13];
  [backToCoverBtn addTarget:self action:@selector(handleLyricAreaTap) forControlEvents:UIControlEventTouchUpInside];
  [_lyricContainerView addSubview:backToCoverBtn];
  [backToCoverBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(_lyricContainerView.mas_top).offset(8);
    make.centerX.equalTo(_lyricContainerView);
    make.height.mas_equalTo(28);
  }];

  _lyricTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
  _lyricTableView.backgroundColor = [UIColor clearColor];
  _lyricTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  _lyricTableView.dataSource = self;
  _lyricTableView.delegate = self;
  _lyricTableView.showsVerticalScrollIndicator = NO;
  [_lyricTableView registerClass:[LyricTableViewCell class] forCellReuseIdentifier:@"LyricCell"];
  [_lyricContainerView addSubview:_lyricTableView];
  [_lyricTableView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.bottom.equalTo(_lyricContainerView);
    make.top.equalTo(backToCoverBtn.mas_bottom).offset(4);
  }];
  _lyricLines = @[];
  _currentLineIndex = -1;
}

//- (void)handleCoverTap {
//  if (self.lyricLines.count == 0) {
//    return;
//  }
//  _showingLyrics = YES;
//  self.imageView.hidden = YES;
//  self.lyricContainerView.hidden = NO;
//  [self.lyricTableView reloadData];
//  [self updateCurrentTime:0];
//}

// 点击封面,先切到歌词容器并 reload，再调 showSongLyrics() 让 Controller 拉取歌词；拉取完成后 Controller 会 setLyricLines + updateCurrentTime。
- (void)handleCoverTap {
  if (!self.showSongLyrics) return;
  _showingLyrics = YES;
  self.imageView.hidden = YES;
  self.lyricContainerView.hidden = NO;
  self.lyricContainerView.userInteractionEnabled = YES;
  if (!self.isLoading) {
    self.showSongLyrics();
    [self.lyricTableView reloadData];
    self.isLoading = YES;
  }
}

// 点击「返回封面」：隐藏歌词容器，显示封面；隐藏时关闭 userInteractionEnabled 避免挡住下次点击封面。
- (void)handleLyricAreaTap {
  _showingLyrics = NO;
  self.imageView.hidden = NO;
  self.lyricContainerView.hidden = YES;
  self.lyricContainerView.userInteractionEnabled = NO;
}

- (void)createButtonOfPrevious {
  self.previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.previousButton setImage:[[UIImage imageNamed:@"previousSong.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]forState:UIControlStateNormal];
  [self addSubview:self.previousButton];
  [self.previousButton mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.mas_left).offset(50);
      make.top.equalTo(self.slider.mas_bottom).offset(60);
      make.height.width.mas_equalTo(40);
  }];
}

- (void)createButtonOfNext {
  self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.nextButton setImage:[[UIImage imageNamed:@"nextSong.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]forState:UIControlStateNormal];
  [self addSubview:self.nextButton];
  [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
      make.right.equalTo(self.mas_right).offset(-50);
      make.top.equalTo(self.slider.mas_bottom).offset(60);
      make.height.width.mas_equalTo(40);
  }];
}

- (void)createButtonOfSwitch {
  self.switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.switchButton setImage:[[UIImage imageNamed:@"st.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
  [self.switchButton setImage:[[UIImage imageNamed:@"be.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
  [self addSubview:self.switchButton];
  [self.switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
      make.centerX.equalTo(self);
    make.top.equalTo(self.previousButton).offset(-5);
      make.height.width.mas_equalTo(50);
  }];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
