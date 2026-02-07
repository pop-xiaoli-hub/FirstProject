//
//  CommentModel.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/21.
//

#import "CommentModel.h"
#import "CommentUserModel.h"
@implementation CommentModel
+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
  return @{
    @"CommentUserModel" : [CommentUserModel class]
  };
}
@end
