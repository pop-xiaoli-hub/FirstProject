//
//  LoginView.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/11/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoginView : UIView
@property (nonatomic, strong)UIImage* image;
@property (nonatomic, strong)UILabel* labelOfRemindUsingEmailOrPhoneNumber;
@property (nonatomic, strong)UIProgressView* progressView;
@property (nonatomic, strong)UIScrollView* scrollView;
@property (nonatomic, strong)UIButton* cancleButton;
@property (nonatomic, strong)UIButton* buttonOfNext;
@property (nonatomic, strong)UITextField* passwordTextField;
@property (nonatomic, strong)UIButton* changeButton;
@property (nonatomic, strong)UILabel* hintLabel;
@property (nonatomic, strong)UIButton* changeToUsePhoneNumber;
@property (nonatomic, strong)UIButton* dropToNextPage;
@property (nonatomic, strong)UIButton* buttonOfUseGoogleCount;
@property (nonatomic, strong)UIButton* buttonOfUseAppleCount;
@property (nonatomic, strong)UIView* contentView;
@property (nonatomic, assign)NSInteger screenWidth;
@property (nonatomic, strong)UIView* page1View;
@property (nonatomic, strong)UIButton* buttonOfLogIn;
@end

NS_ASSUME_NONNULL_END
