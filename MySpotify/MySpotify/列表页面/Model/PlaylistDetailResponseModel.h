//
//  PlaylistDetailResponseModel.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/21.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>
@class PlaylistModel;
NS_ASSUME_NONNULL_BEGIN

@interface PlaylistDetailResponseModel : NSObject<YYModel>
@property (nonatomic, strong)PlaylistModel* playlist;
@end

NS_ASSUME_NONNULL_END
