//
//  MyCollectionViewCell.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/19.
//

#import <UIKit/UIKit.h>
#import <Masonry.h>
NS_ASSUME_NONNULL_BEGIN
@class CommentModel;
@interface MyCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong)UIImageView* coverImageView;
@property (nonatomic, strong)UIView* backView;
@property (nonatomic, strong)UILabel* userNameLabel;
@property (nonatomic, strong)UILabel* textLabel;
@property (nonatomic, strong)UIImageView* headerView;
@property (nonatomic, strong)UIButton* buttonOfLiked;
@property (nonatomic, strong)UILabel* labelOfLiked;
- (void)configureWithCommentModel:(CommentModel* )model;
- (void)createButtton;
@end

NS_ASSUME_NONNULL_END
