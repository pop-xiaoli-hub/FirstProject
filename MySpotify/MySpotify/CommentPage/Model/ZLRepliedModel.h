//
//  ZLRepliedModel.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/28.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>
@class ZLUserModel;
NS_ASSUME_NONNULL_BEGIN

@interface ZLRepliedModel : NSObject<YYModel>
@property (nonatomic, assign) long long beRepliedCommentId;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString* timeStr;
@property (nonatomic, strong) ZLUserModel *user;
@end

NS_ASSUME_NONNULL_END
