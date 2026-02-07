//
//  RecommendationsOfArtistsModel.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/9.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>
NS_ASSUME_NONNULL_BEGIN
@class ArtistModel;
@interface RecommendationsOfArtistsModel : NSObject<YYModel>
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSArray<ArtistModel* >* artists;
@end

NS_ASSUME_NONNULL_END
