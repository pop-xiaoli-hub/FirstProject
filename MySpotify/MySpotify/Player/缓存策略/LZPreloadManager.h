//
//  LZPreloadManager.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LZPreloadManager : NSObject
+ (instancetype)shared;
/// 预加载接口  key: 缓存key（url.lastComponent）url: 真实音频url startOffset: 从哪个字节开始预加载 length: 预加载长度
- (void)preloadWithKey:(NSString *)key url:(NSURL *)url startOffset:(NSUInteger)startOffset length:(NSUInteger)length;
/// 清空所有预加载任务
- (void)cancelAll;
@end

NS_ASSUME_NONNULL_END
