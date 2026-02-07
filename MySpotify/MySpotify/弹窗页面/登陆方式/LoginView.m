//
//  LoginView.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/11/8.
//

#import "LoginView.h"
#import "Masonry.h"
@implementation LoginView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor blackColor];
    _image = [UIImage imageNamed:@"logoOfSpotify.png"];
    [self createLogo];
    [self createCancleButton];
    [self createProgressView];
    [self createScrollView];
    [self createThreeStepsView];
  }
  return self;
}

- (void)createCancleButton {
  _cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [_cancleButton setImage:[UIImage imageNamed:@"cancleButton.png"] forState:UIControlStateNormal];
  [self addSubview:_cancleButton];
  [_cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
      make.right.equalTo(self).offset(-20);
      make.top.equalTo(self).offset(20);
      make.width.height.mas_equalTo(25);
  }];
}

- (void)createScrollView {
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.pagingEnabled = YES;
    _scrollView.scrollEnabled = YES;
    _scrollView.userInteractionEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.bounces = NO;
    [self addSubview:_scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressView.mas_bottom).offset(10);
        make.bottom.equalTo(self);
        make.left.right.equalTo(self);
    }];
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.height.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView.mas_width).multipliedBy(3);
    }];
    UIView *page1 = [[UIView alloc] init];
    UIView *page2 = [[UIView alloc] init];
    UIView *page3 = [[UIView alloc] init];
    page1.backgroundColor = [UIColor clearColor];
    page2.backgroundColor = [UIColor clearColor];
    page3.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:page1];
    [self.contentView addSubview:page2];
    [self.contentView addSubview:page3];
    [page1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.contentView);
        make.left.equalTo(self.contentView.mas_left);
        make.width.equalTo(self.scrollView);
    }];
    [page2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.contentView);
        make.left.equalTo(page1.mas_right);
        make.width.equalTo(self.scrollView);
    }];
    [page3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.contentView);
        make.left.equalTo(page2.mas_right);
        make.width.equalTo(self.scrollView);
        make.right.equalTo(self.contentView.mas_right);
    }];
    self.page1View = page1;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  [self layoutIfNeeded];
  self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 3, self.scrollView.frame.size.height);
}

- (void)createThreeStepsView {
  [self createFirstStepViewInView:self.page1View];
}

- (void)createFirstStepViewInView:(UIView *)parentView {
  UILabel* hintLabel = [[UILabel alloc] init];
  hintLabel.text = @"第 1 步， 共 3 步";
  hintLabel.textColor = [UIColor darkGrayColor];
  hintLabel.font = [UIFont systemFontOfSize:18];
  hintLabel.backgroundColor = [UIColor clearColor];
  hintLabel.textAlignment = NSTextAlignmentLeft;
  [parentView addSubview:hintLabel];
  [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(parentView).offset(10);
    make.left.equalTo(parentView).offset(50);
    make.height.mas_equalTo(25);
    make.width.mas_equalTo(150);
  }];
  UILabel* setUpPasswordLabel = [[UILabel alloc] init];
  setUpPasswordLabel.text = @"注册方式";
  setUpPasswordLabel.textColor = [UIColor whiteColor];
  setUpPasswordLabel.font = [UIFont systemFontOfSize:20];
  setUpPasswordLabel.backgroundColor = [UIColor clearColor];
  setUpPasswordLabel.textAlignment = NSTextAlignmentLeft;
  [parentView addSubview:setUpPasswordLabel];
  [setUpPasswordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(hintLabel.mas_bottom).offset(5);
    make.left.equalTo(hintLabel);
    make.height.mas_equalTo(25);
    make.width.mas_equalTo(150);
  }];
  self.buttonOfNext = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.buttonOfNext setImage:[UIImage imageNamed:@"again.png"] forState:UIControlStateNormal];
  [parentView addSubview:self.buttonOfNext];
  [self.buttonOfNext mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(parentView).offset(15);
      make.top.equalTo(parentView).offset(25);
      make.width.height.mas_offset(30);
  }];
  [self createPasswordFieldInView:parentView];
  [self createHintLabelInView:parentView];
  [self createButtonOfChangeToUsePhoneNumberInView:parentView];
  [self createDropToNextPageButtonInView:parentView];
  [self createButtonOfUseGoogleCountInView:parentView];
  [self createButtonOfUseAppleCountInView:parentView];
  [self createButtonOfLogIn:parentView];
}

- (void)createButtonOfLogIn:(UIView* )parentView {
  self.buttonOfLogIn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [self.buttonOfLogIn setTitle:@"登陆" forState:UIControlStateNormal];
  [self.buttonOfLogIn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  self.buttonOfLogIn.titleLabel.font = [UIFont systemFontOfSize:20];
  self.buttonOfLogIn.backgroundColor = [UIColor clearColor];
  [parentView addSubview:self.buttonOfLogIn];
  [self.buttonOfLogIn mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.buttonOfUseAppleCount.mas_bottom).offset(60);
      make.centerX.equalTo(self.page1View);
      make.height.mas_equalTo(30);
      make.width.mas_equalTo(60);
  }];
}


-(void)createButtonOfUseAppleCountInView:(UIView *)parentView {
  self.buttonOfUseAppleCount = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [self.buttonOfUseAppleCount setTitle:@"使用Apple账号注册" forState:UIControlStateNormal];
  self.buttonOfUseAppleCount.backgroundColor = [UIColor orangeColor];
  [self.buttonOfUseAppleCount setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [self.buttonOfUseAppleCount setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
  self.buttonOfUseAppleCount.layer.masksToBounds = YES;
  self.buttonOfUseAppleCount.layer.cornerRadius = 25;
  self.buttonOfUseAppleCount.titleLabel.font = [UIFont boldSystemFontOfSize:19];
  [parentView addSubview:self.buttonOfUseAppleCount];
  [self.buttonOfUseAppleCount mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.buttonOfUseGoogleCount.mas_bottom).offset(20);
      make.left.equalTo(self.dropToNextPage);
      make.height.mas_equalTo(50);
      make.width.equalTo(parentView).offset(-50);
  }];
  UILabel* label = [[UILabel alloc] init];
  label.text = @"已拥有账号?";
  label.textColor = [UIColor lightGrayColor];
  label.font = [UIFont systemFontOfSize:18];
  label.backgroundColor = [UIColor clearColor];
  [parentView addSubview:label];
  [label mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.buttonOfUseAppleCount.mas_bottom).offset(25);
      make.centerX.equalTo(self.dropToNextPage);
      make.height.mas_equalTo(30);
      make.width.mas_equalTo(120);
  }];
  label.textAlignment = NSTextAlignmentCenter;
}

- (void)createButtonOfUseGoogleCountInView:(UIView *)parentView {
  self.buttonOfUseGoogleCount = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [self.buttonOfUseGoogleCount setTitle:@"使用Google账号注册" forState:UIControlStateNormal];
  self.buttonOfUseGoogleCount.backgroundColor = [UIColor orangeColor];
  [self.buttonOfUseGoogleCount setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [self.buttonOfUseGoogleCount setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
  self.buttonOfUseGoogleCount.layer.masksToBounds = YES;
  self.buttonOfUseGoogleCount.layer.cornerRadius = 25;
  self.buttonOfUseGoogleCount.titleLabel.font = [UIFont boldSystemFontOfSize:19];
  [parentView addSubview:self.buttonOfUseGoogleCount];
  [self.buttonOfUseGoogleCount mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.dropToNextPage.mas_bottom).offset(70);
      make.left.equalTo(self.dropToNextPage);
      make.height.mas_equalTo(50);
      make.width.equalTo(parentView).offset(-50);
  }];
}

- (void)createDropToNextPageButtonInView:(UIView *)parentView {
  self.dropToNextPage = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [self.dropToNextPage setTitle:@"下一步" forState:UIControlStateNormal];
  self.dropToNextPage.backgroundColor = [UIColor orangeColor];
  [self.dropToNextPage setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  [self.dropToNextPage setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
  self.dropToNextPage.layer.masksToBounds = YES;
  self.dropToNextPage.layer.cornerRadius = 25;
  self.dropToNextPage.titleLabel.font = [UIFont boldSystemFontOfSize:19];
  [parentView addSubview:self.dropToNextPage];
  [self.dropToNextPage mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.changeToUsePhoneNumber.mas_bottom).offset(20);
      make.left.equalTo(self.changeToUsePhoneNumber);
      make.height.mas_equalTo(50);
      make.width.equalTo(parentView).offset(-50);
  }];
  UILabel* label = [[UILabel alloc] init];
  label.text = @"或者";
  label.textColor = [UIColor whiteColor];
  label.font = [UIFont systemFontOfSize:20];
  label.backgroundColor = [UIColor clearColor];
  [parentView addSubview:label];
  [label mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.dropToNextPage.mas_bottom).offset(20);
      make.centerX.equalTo(self.dropToNextPage);
      make.height.mas_equalTo(30);
      make.width.mas_equalTo(60);
  }];
  label.textAlignment = NSTextAlignmentCenter;
}

- (void)createButtonOfChangeToUsePhoneNumberInView:(UIView *)parentView {
  self.changeToUsePhoneNumber = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [self.changeToUsePhoneNumber setTitle:@"改用电话号码。" forState:UIControlStateNormal];
  [self.changeToUsePhoneNumber setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
  self.changeToUsePhoneNumber.titleLabel.font = [UIFont systemFontOfSize:18];
  [self.changeToUsePhoneNumber setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
  [parentView addSubview:self.changeToUsePhoneNumber];
  [self.changeToUsePhoneNumber mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.hintLabel.mas_bottom).mas_equalTo(40);
      make.left.equalTo(self.hintLabel);
      make.height.mas_equalTo(20);
      make.width.mas_equalTo(120);
  }];
}

- (void)createHintLabelInView:(UIView *)parentView {
  self.hintLabel = [[UILabel alloc] init];
  self.hintLabel.text = @"⚠️ 此电子邮件地址无效。请务必确认其格式为：";
  self.hintLabel.font = [UIFont systemFontOfSize:15];
  self.hintLabel.textColor = [UIColor darkGrayColor];
  [parentView addSubview:self.hintLabel];
  [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.passwordTextField.mas_bottom).offset(8);
      make.left.equalTo(self.passwordTextField);
      make.width.equalTo(self.passwordTextField);
      make.height.mas_equalTo(20);
  }];
  UILabel* label = [[UILabel alloc] init];
  label.text = @"example@email.com";
  label.font = [UIFont systemFontOfSize:14];
  label.textColor = [UIColor darkGrayColor];
  [parentView addSubview:label];;
  [label mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.hintLabel.mas_bottom).offset(4);
      make.left.equalTo(self.hintLabel);
      make.height.mas_equalTo(14);
      make.width.equalTo(self.hintLabel);
  }];
}

- (void)createPasswordFieldInView:(UIView *)parentView {
  self.labelOfRemindUsingEmailOrPhoneNumber = [[UILabel alloc] init];
  self.labelOfRemindUsingEmailOrPhoneNumber.text = @"电子邮箱地址";
  self.labelOfRemindUsingEmailOrPhoneNumber.textColor = [UIColor whiteColor];
  self.labelOfRemindUsingEmailOrPhoneNumber.backgroundColor = [UIColor clearColor];
  [parentView addSubview:self.labelOfRemindUsingEmailOrPhoneNumber];
  self.labelOfRemindUsingEmailOrPhoneNumber.font = [UIFont systemFontOfSize:18];
  [self.labelOfRemindUsingEmailOrPhoneNumber mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(parentView).offset(100);
      make.left.equalTo(parentView).offset(30);
      make.height.mas_equalTo(20);
      make.width.mas_equalTo(110);
  }];
  self.passwordTextField = [[UITextField alloc] init];
  self.passwordTextField.placeholder = @"name@domain.com" ;
  self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"name@domain.com" attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
  self.passwordTextField.textColor = [UIColor whiteColor];
  self.passwordTextField.secureTextEntry = YES;
  self.passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
  self.passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
  self.passwordTextField.backgroundColor = [UIColor clearColor];
  self.passwordTextField.layer.masksToBounds = YES;
  self.passwordTextField.layer.borderWidth = 2;
  self.passwordTextField.layer.borderColor = [UIColor redColor].CGColor;
  [parentView addSubview:self.passwordTextField];
  [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.labelOfRemindUsingEmailOrPhoneNumber.mas_bottom).offset(10);
      make.left.equalTo(self.labelOfRemindUsingEmailOrPhoneNumber);
      make.height.mas_equalTo(60);
      make.width.equalTo(parentView).offset(-60);
  }];
  self.changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.changeButton setImage:[UIImage imageNamed:@"encrypt.png"] forState:UIControlStateNormal];
  [self.changeButton setImage:[UIImage imageNamed:@"decrypt.png"] forState:UIControlStateSelected];
  [self.passwordTextField addSubview:self.changeButton];
  self.passwordTextField.rightView = self.changeButton;
  self.passwordTextField.rightViewMode = UITextFieldViewModeAlways;
}

- (void)createProgressView {
  _progressView = [[UIProgressView alloc] init];
  _progressView.progressTintColor = [UIColor redColor];
  _progressView.trackTintColor = [UIColor whiteColor];
  _progressView.progressViewStyle = UIProgressViewStyleDefault;
  _progressView.progress = 0.333;
  [self addSubview:_progressView];
  [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self).offset(120);
      make.centerX.equalTo(self);
      make.width.equalTo(self).offset(-50);
      make.height.mas_equalTo(3);
  }];
}

- (void)createLogo {
  UIImageView* logoView = [[UIImageView alloc] initWithImage:_image];
  logoView.clipsToBounds = YES;
  logoView.contentMode = UIViewContentModeScaleAspectFill;
  [self addSubview:logoView];
  [logoView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self).offset(40);
      make.centerX.equalTo(self);
      make.height.width.mas_equalTo(40);
  }];
}

@end
