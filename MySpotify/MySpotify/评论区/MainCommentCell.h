//
//  MainCommentCell.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/28.
//

#import <UIKit/UIKit.h>
@class ZLCommentModel;
NS_ASSUME_NONNULL_BEGIN

@interface MainCommentCell : UITableViewCell
@property (nonatomic, strong) UIImageView *headerView;
@property (nonatomic, strong) UILabel *userNameLabel;
//@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UITextView* contentTextView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *buttonOfLiked;
@property (nonatomic, strong) UIButton *buttonOfExpand;
//@property (nonatomic, strong) UIButton* buttonOfReply;
@property (nonatomic, strong) UIView* replyBgView;
@property (nonatomic, strong) UIButton* foldButton;
@property (nonatomic, strong) UIStackView* replyStackView;
- (void)configWithModel:(ZLCommentModel *)model indexPath:(NSIndexPath *)indexPath target:(id)target action:(SEL)action;
@end

NS_ASSUME_NONNULL_END
