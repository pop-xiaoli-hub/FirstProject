//
//  LoginPageView.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/11/6.
//

#import "LoginPageView.h"
#import "Masonry.h"
@implementation LoginPageView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor blackColor];
    UIImage* image = [UIImage imageNamed:@"backgroundPhoto.jpg"];
    self.layer.contents = (__bridge id)image.CGImage;
    self.layer.contentsGravity = kCAGravityResizeAspectFill;
    self.layer.contentsScale = [UIScreen mainScreen].scale;
    self.layer.masksToBounds = YES;
    CALayer* darkOverLayer = [CALayer layer];
    darkOverLayer.frame = self.frame;
    darkOverLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4].CGColor;
    [self.layer addSublayer:darkOverLayer];
    [self createLogo];
    [self createWordsLabel];
    [self createButton];
  }
  return self;
}

- (void)createButton {
  _buttonOfSignUpFree = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [_buttonOfSignUpFree setTitle:@"SIGN  UP  FREE" forState:UIControlStateNormal];
  [_buttonOfSignUpFree setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [_buttonOfSignUpFree setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
  _buttonOfSignUpFree.titleLabel.font = [UIFont systemFontOfSize:18];
  _buttonOfSignUpFree.backgroundColor = [UIColor orangeColor];
  _buttonOfSignUpFree.layer.masksToBounds = YES;
  _buttonOfSignUpFree.layer.cornerRadius = 25;
  [self addSubview:_buttonOfSignUpFree];
  [_buttonOfSignUpFree mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.bottomWordsLabel.mas_bottom).offset(140);
      make.left.equalTo(self).offset(30);
      make.height.mas_equalTo(50);
      make.right.equalTo(self).offset(-30);
  }];

  _buttonOfContinueWithFaceBook = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  NSString* part1 = @"f ";
  NSString* part2 = @"CONTINUE WITH FACEBOOK";
  NSMutableAttributedString* attributesTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", part1, part2]];
  UIFont* font1 = [UIFont fontWithName:@"RacketyDEMO" size:35];
  [attributesTitle addAttribute:NSFontAttributeName value:font1 range:NSMakeRange(0, part1.length)];
  UIFont* font2 = [UIFont systemFontOfSize:18];
  [attributesTitle addAttribute:NSFontAttributeName value:font2 range:NSMakeRange(part1.length, part2.length + 1)];
  [attributesTitle addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, part1.length + part2.length + 1)];
  [_buttonOfContinueWithFaceBook setAttributedTitle:attributesTitle forState:UIControlStateNormal];
  [_buttonOfContinueWithFaceBook setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
  [self addSubview:_buttonOfContinueWithFaceBook];
  [_buttonOfContinueWithFaceBook mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.buttonOfSignUpFree.mas_bottom).offset(20);
      make.height.mas_equalTo(50);
      make.left.equalTo(self.buttonOfSignUpFree);
      make.width.equalTo(self.buttonOfSignUpFree);
  }];
  _buttonOfContinueWithFaceBook.titleLabel.textAlignment = NSTextAlignmentCenter;
  _buttonOfContinueWithFaceBook.backgroundColor = [UIColor orangeColor];
  _buttonOfContinueWithFaceBook.layer.masksToBounds = YES;
  _buttonOfContinueWithFaceBook.layer.cornerRadius = 25;

  _buttonOfLogin = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [_buttonOfLogin setTitle:@"LOG IN" forState:UIControlStateNormal];
  [_buttonOfLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [_buttonOfLogin setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
  _buttonOfLogin.titleLabel.font = [UIFont systemFontOfSize:16];
  _buttonOfLogin.backgroundColor = [UIColor clearColor];
  [self addSubview:_buttonOfLogin];
  [_buttonOfLogin mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.buttonOfContinueWithFaceBook.mas_bottom).offset(30);
      make.centerX.equalTo(self.buttonOfContinueWithFaceBook);
      make.height.mas_equalTo(50);
      make.width.mas_equalTo(120);
  }];
}

- (void)createWordsLabel {
  _wordsLabel = [[UILabel alloc] init];
  [self addSubview:_wordsLabel];
  _wordsLabel.backgroundColor = [UIColor clearColor];
  _wordsLabel.textColor = [UIColor whiteColor];
  _wordsLabel.font = [UIFont fontWithName:@"RacketyDEMO" size:40];
  _wordsLabel.text = @"Millions of songs.";
  [_wordsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self).offset(30);
      make.top.equalTo(self.logoView).offset(280);
      make.height.mas_equalTo(40);
    make.width.equalTo(self).offset(-30);
  }];

  _bottomWordsLabel = [[UILabel alloc] init];
  [self addSubview:_bottomWordsLabel];
  _bottomWordsLabel.backgroundColor = [UIColor clearColor];
  _bottomWordsLabel.textColor = [UIColor whiteColor];
  _bottomWordsLabel.font = [UIFont fontWithName:@"RacketyDEMO" size:40];
  _bottomWordsLabel.text = @"     Free on Spotify.";
  [_bottomWordsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self).offset(30);
    make.top.equalTo(self.wordsLabel.mas_bottom).offset(5);
      make.height.mas_equalTo(40);
      make.width.equalTo(self).offset(-30);
  }];
}


- (void)createLogo {
  UIImage* image = [UIImage imageNamed:@"spotify-full-logo.png"];
  _logoView = [[UIImageView alloc] initWithImage:image];
  [self addSubview:_logoView];
  [_logoView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self).offset(30);
      make.top.equalTo(self).offset(90);
      make.height.mas_equalTo(45);
      make.width.mas_equalTo(150);
  }];
  _logoView.clipsToBounds = YES;
  _logoView.contentMode = UIViewContentModeScaleAspectFill;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
