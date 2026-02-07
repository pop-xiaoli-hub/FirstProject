//
//  CommentModel.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/21.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>
NS_ASSUME_NONNULL_BEGIN
@class CommentUserModel;
@interface CommentModel : NSObject<YYModel>
@property (nonatomic, assign) long long commentId;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) NSInteger likedCount;
@property (nonatomic, assign) NSInteger replyCount;
@property (nonatomic, assign) long long time;
@property (nonatomic, copy) NSString *timeStr;
@property (nonatomic, strong) CommentUserModel *user;
@end


NS_ASSUME_NONNULL_END
