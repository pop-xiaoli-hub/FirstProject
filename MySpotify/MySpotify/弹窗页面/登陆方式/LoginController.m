//
//  LoginController.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/11/8.
//

#import "LoginController.h"
#import "LoginView.h"
#import "LoginModel.h"

@interface LoginController ()<UIScrollViewDelegate>
@property (nonatomic, assign)BOOL IsEmail;
@property (nonatomic, strong)LoginView* myView;
@property (nonatomic, strong)LoginModel* myModel;
@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
  self.IsEmail = YES;
  _myView = [[LoginView alloc] initWithFrame:[UIScreen mainScreen].bounds];
  _myView.scrollView.delegate = self;
  [self.view addSubview:self.myView];
  [self.myView.cancleButton addTarget:self action:@selector(cancleUpdateView) forControlEvents:UIControlEventTouchUpInside];
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
     tap.cancelsTouchesInView = NO;
  [self.myView.scrollView addGestureRecognizer:tap];
  [self.myView.changeButton addTarget:self action:@selector(changeToDecryptOrEncrypt:) forControlEvents:UIControlEventTouchUpInside];
  [self.myView.changeToUsePhoneNumber addTarget:self action:@selector(changeToUseOtherWays:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)changeToUseOtherWays:(UIButton* )button {
  if (self.IsEmail) {
    self.myView.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"+86 XXXXXXXXXXX" attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    self.myView.labelOfRemindUsingEmailOrPhoneNumber.text = @"通讯电话地址";
    self.myView.passwordTextField.keyboardType = UIKeyboardTypeNumberPad;
  } else {
    self.myView.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"name@domain.com" attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    self.myView.labelOfRemindUsingEmailOrPhoneNumber.text = @"电子邮箱地址";
    self.myView.passwordTextField.keyboardType = UIKeyboardTypeDefault;
  }
  self.IsEmail = !self.IsEmail;
}

- (void)changeToDecryptOrEncrypt:(UIButton* )button {
  button.selected = !button.selected;
  if (button.selected) {
    self.myView.passwordTextField.secureTextEntry = NO;
  } else {
    self.myView.passwordTextField.secureTextEntry = YES;
  }
}

- (void)dismissKeyboard {
  [self.myView endEditing:YES];
}

- (void)cancleUpdateView {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [self.myView endEditing:YES];
}

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
//  CGFloat width = scrollView.frame.size.width;
//  CGFloat offsetX = scrollView.contentOffset.x;
//  if (offsetX >= 0 && offsetX < width) {
//    self.myView.progressView.progress = 0.3;
//  } else if (offsetX >= width && offsetX < 2 * width) {
//    self.myView.progressView.progress = 0.6;
//  } else {
//    self.myView.progressView.progress = 1;
//  }
//}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  CGFloat width = scrollView.frame.size.width;
  CGFloat offsetX = scrollView.contentOffset.x;
  if (offsetX >= 0 && offsetX < width) {
    self.myView.progressView.progress = 0.333;
  } else if (offsetX >= width && offsetX < 2 * width) {
    self.myView.progressView.progress = 0.666;
  } else {
    self.myView.progressView.progress = 1;
  }
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
