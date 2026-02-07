//
//  RecommendationsResponseModel.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/8.
//

#import "RecommendationsResponseModel.h"
#import "RecommendedSongsItemModel.h"
@implementation RecommendationsResponseModel
+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
  return @{
    @"result" : [RecommendedSongsItemModel class],
  };
}
@end
