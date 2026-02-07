//
//  ZLCommentResponseModel.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/28.
//

#import "ZLCommentResponseModel.h"
#import "ZLCommentModel.h"
@implementation ZLCommentResponseModel
+(NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
  return @{
         @"hotComments" : [ZLCommentModel class],
         @"comments"    : [ZLCommentModel class]
     };
}
@end
