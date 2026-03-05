//
//  RangeDownloader.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LZRangeDownloader : NSObject
+ (instancetype)sharedLoader;
- (void)download:(NSURL *)url offset:(NSUInteger)offset length:(NSUInteger)length completion:(void(^)(NSData *data, NSError *error))completion;
//取消某个 range 任务
- (void)cancelWithKey:(NSString *)key offset:(NSUInteger)offset length:(NSUInteger)length;

// 取消某个资源所有任务
- (void)cancelAllForKey:(NSString *)key;

// 取消全部下载
- (void)cancelAll;
@end

NS_ASSUME_NONNULL_END
