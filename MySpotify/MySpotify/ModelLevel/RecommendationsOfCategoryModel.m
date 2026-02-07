//
//  RecommendationsOfCategoryModel.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/10.
//

#import "RecommendationsOfCategoryModel.h"
#import "CategoryModel.h"
@implementation RecommendationsOfCategoryModel
+(NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
  return @{
    @"result" : [CategoryModel class]
  };
}
@end
