//
//  PlaylistModel.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/21.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>
@class SongModel, PlaylistCreatorModel, TracksIDModel;
NS_ASSUME_NONNULL_BEGIN

@interface PlaylistModel : NSObject<YYModel>
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *coverImgUrl;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, assign) NSInteger playCount;
@property (nonatomic, strong) NSArray<TracksIDModel *> *trackIds;
@property (nonatomic, strong)PlaylistCreatorModel* creator;

@property (nonatomic, strong) NSArray<SongModel *> *tracks;
@end

NS_ASSUME_NONNULL_END
