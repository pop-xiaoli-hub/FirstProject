//
//  RecommendationsOfCategoryModel.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/10.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>
NS_ASSUME_NONNULL_BEGIN
@class CategoryModel;
@interface RecommendationsOfCategoryModel : NSObject<YYModel>
@property (nonatomic, strong)NSArray<CategoryModel* >* result;
@end

NS_ASSUME_NONNULL_END
