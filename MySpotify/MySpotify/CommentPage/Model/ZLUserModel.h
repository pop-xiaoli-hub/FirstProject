//
//  ZLUserModel.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZLUserModel : NSObject
@property (nonatomic, assign) long long userId;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *avatarUrl;

@property (nonatomic, assign) NSInteger vipType;
@property (nonatomic, assign) BOOL followed;
@end

NS_ASSUME_NONNULL_END
