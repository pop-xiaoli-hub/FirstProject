//
//  RecommendationsOfArtistsModel.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/9.
//

#import "RecommendationsOfArtistsModel.h"
#import "ArtistModel.h"
@implementation RecommendationsOfArtistsModel
+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
  return @{
    @"artists" : [ArtistModel class]
  };
}
@end
