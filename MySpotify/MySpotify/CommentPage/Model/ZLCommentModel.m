//
//  ZLCommentModel.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/28.
//

#import "ZLCommentModel.h"
#import "ZLUserModel.h"
#import "ZLRepliedModel.h"
@implementation ZLCommentModel
+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
  return @{
    @"user" : [ZLUserModel class],
    @"beReplied" : [ZLRepliedModel class]
  };
}

- (instancetype)init {
    if (self = [super init]) {
      _showReplies = NO;
    }
    return self;
}


@end
