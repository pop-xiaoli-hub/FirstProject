//
//  RecommendationsResponseModel.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/8.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>
NS_ASSUME_NONNULL_BEGIN
@class RecommendedSongsItemModel;
@class RecommendedArtistsItemModel;
@interface RecommendationsResponseModel : NSObject<YYModel>
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, assign) NSInteger category;
@property (nonatomic, strong) NSArray<RecommendedSongsItemModel* >* result;
@property (nonatomic, strong) NSArray<RecommendedArtistsItemModel* >* artistItemResult;
@end

NS_ASSUME_NONNULL_END
