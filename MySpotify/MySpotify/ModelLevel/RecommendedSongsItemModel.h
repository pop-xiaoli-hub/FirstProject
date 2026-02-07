//
//  RecommendedSongsItemModel.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/8.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>
NS_ASSUME_NONNULL_BEGIN
@class SongModel;
@interface RecommendedSongsItemModel : NSObject<YYModel>
@property (nonatomic, assign) long long id;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *picUrl;
@property (nonatomic, strong, nullable) SongModel *song;
@end

NS_ASSUME_NONNULL_END
