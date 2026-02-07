//
//  RecommendedSongsItemModel.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/8.
//

#import "RecommendedSongsItemModel.h"
#import "SongModel.h"
@implementation RecommendedSongsItemModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
  return @{
    @"song" : [SongModel class]
  };
}
@end
