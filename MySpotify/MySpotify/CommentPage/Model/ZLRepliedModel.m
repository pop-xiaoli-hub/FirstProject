//
//  ZLRepliedModel.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/28.
//

#import "ZLRepliedModel.h"
#import "ZLUserModel.h"
@implementation ZLRepliedModel
+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
  return @{
    @"user" : [ZLUserModel class]
  };
}
@end
