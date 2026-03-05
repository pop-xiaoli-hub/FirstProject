//
//  CommentPager.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommentPager : NSObject
@property (nonatomic, assign) NSInteger offset;     // 当前偏移量
@property (nonatomic, assign) NSInteger limit;      // 每页条数
@property (nonatomic, assign) BOOL hasMore;          // 接口返回 more
@property (nonatomic, assign) BOOL isLoading;        // 防并发请求
@end

NS_ASSUME_NONNULL_END
