//
//  CategoryModel.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CategoryModel : NSObject
@property (nonatomic, copy)NSString* name;
@property (nonatomic, copy)NSString* picUrl;
@property (nonatomic, assign)long long id;
@property (nonatomic, assign)long trackCount;
@property (nonatomic, assign)long long playCount;
@end

NS_ASSUME_NONNULL_END
