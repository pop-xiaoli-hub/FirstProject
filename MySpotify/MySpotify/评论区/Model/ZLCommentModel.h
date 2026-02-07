//
//  ZLCommentModel.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/28.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>
@class ZLUserModel,ZLRepliedModel;
NS_ASSUME_NONNULL_BEGIN

@interface ZLCommentModel : NSObject<YYModel>
@property (nonatomic, assign) long long commentId;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *timeStr;

@property (nonatomic, assign) NSInteger likedCount;
@property (nonatomic, assign) BOOL liked;

@property (nonatomic, strong) ZLUserModel *user;
@property (nonatomic, strong) NSArray<ZLRepliedModel *> *beReplied;
@property (nonatomic, assign) BOOL showReplies;//楼中评论是否被展开

@property (nonatomic, assign) BOOL expandedContent; // 是否展开全文
@property (nonatomic, assign) BOOL needFold;

//@property (nonatomic, strong) NSInvocation *ipLocation;
@end

NS_ASSUME_NONNULL_END
