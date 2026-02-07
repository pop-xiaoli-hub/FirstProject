//
//  RecommendationsOfAlbumsModel.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/10.
//

#import "RecommendationsOfAlbumsModel.h"
#import "AlbumModel.h"
@implementation RecommendationsOfAlbumsModel
+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
  return @{
    @"playlists" : [AlbumModel class]
  };
}
@end
