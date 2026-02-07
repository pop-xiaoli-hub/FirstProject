//
//  RecommendationsOfAlbumsModel.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/10.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>
NS_ASSUME_NONNULL_BEGIN
@class AlbumModel;
@interface RecommendationsOfAlbumsModel : NSObject<YYModel>
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSArray<AlbumModel *> *playlists;
@end

NS_ASSUME_NONNULL_END
