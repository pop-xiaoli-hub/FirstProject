//
//  CommentListResponseModel.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/21.
//

#import "CommentListResponseModel.h"
#import "CommentModel.h"
@implementation CommentListResponseModel
+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
  return @{
    @"comments" : [CommentModel class]
  };
}
@end
