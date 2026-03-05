//
//  ArtistDetailResponseModel.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/23.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>
@class SongModel, ArtistModel;

NS_ASSUME_NONNULL_BEGIN

@interface ArtistDetailResponseModel : NSObject<YYModel>
@property (nonatomic, strong) ArtistModel *artist;
@property (nonatomic, strong) NSArray<SongModel *> *hotSongs;
@end

NS_ASSUME_NONNULL_END
