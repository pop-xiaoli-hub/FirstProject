//
//  DetailMusicPlayerView.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/6.
//

#import "DetailMusicPlayerView.h"
#import <Masonry.h>
#import "SongPlayingModel.h"
#import <SDWebImage.h>
@implementation DetailMusicPlayerView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self createUI];
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
    NSLog(@"点击下载");
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

- (void)configureWithModel:(SongPlayingModel *)model{
  self.songNameLabel.text = [model.name copy];
  SDImageResizingTransformer *transformer =
  [SDImageResizingTransformer transformerWithSize:CGSizeMake(200, 200) scaleMode:SDImageScaleModeAspectFill];
  [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.headerUrl] placeholderImage:nil options:SDWebImageScaleDownLargeImages context:@{
    SDWebImageContextImageTransformer: transformer, SDWebImageContextImageThumbnailPixelSize: @(CGSizeMake(200,200)), SDWebImageContextImageForceDecodePolicy: @(SDImageForceDecodePolicyNever)
  }];
}

- (void)createSlider {
  self.slider = [[UISlider alloc] init];
  self.slider.minimumValue = 0;
  self.slider.minimumTrackTintColor = [UIColor redColor];
  self.slider.maximumTrackTintColor = [UIColor whiteColor];
  [self addSubview:self.slider];
  [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.mas_left).offset(20);
      make.right.equalTo(self.mas_right).offset(-20);
      make.top.equalTo(self.songNameLabel.mas_bottom).offset(20);
      make.height.mas_equalTo(20);
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

- (void) createImageView {
  self.imageView = [[UIImageView alloc] init];
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
//  self.imageView.layer.shadowColor = [UIColor systemBlueColor].CGColor;
//  self.imageView.layer.shadowOpacity = 0.3;
//  self.imageView.layer.shadowOffset = CGSizeMake(0, 4);
//  self.imageView.layer.shadowRadius = 6;
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
