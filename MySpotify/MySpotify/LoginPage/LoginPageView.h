//
//  LoginPageView.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/11/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoginPageView : UIView
@property (nonatomic, strong)UIImageView* logoView;
@property (nonatomic, strong)UILabel* wordsLabel;
@property (nonatomic, strong)UILabel* bottomWordsLabel;
@property (nonatomic, strong)UIButton* buttonOfSignUpFree;
@property (nonatomic, strong)UIButton* buttonOfContinueWithFaceBook;
@property (nonatomic, strong)UIButton* buttonOfLogin;
@end

NS_ASSUME_NONNULL_END
