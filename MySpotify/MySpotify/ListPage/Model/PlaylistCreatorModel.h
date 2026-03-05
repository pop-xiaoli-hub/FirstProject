//
//  PlaylistCreatorModel.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/22.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>
NS_ASSUME_NONNULL_BEGIN

@interface PlaylistCreatorModel : NSObject<YYModel>
@property (nonatomic, assign) long long userId;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *avatarUrl;
//@property (nonatomic, assign) NSInteger gender;
//@property (nonatomic, copy) NSString *signature;
//@property (nonatomic, assign) NSInteger vipType;
//@property (nonatomic, assign) BOOL anchor;

@end

NS_ASSUME_NONNULL_END
