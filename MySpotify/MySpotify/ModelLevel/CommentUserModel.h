//
//  CommentUserModel.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommentUserModel : NSObject
@property (nonatomic, assign) long long userId;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *avatarUrl;
@end

NS_ASSUME_NONNULL_END
