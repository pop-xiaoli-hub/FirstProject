//
//  StreamingURLBuilder.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LZStreamingURLBuilder : NSObject
/// 旧：用完整 URL 换 scheme，仅兼容；动态 URL 会变，缓存 key 不稳定
+ (NSURL *)buildStreamingURL:(NSURL *)url;
+ (NSURL *)realURL:(NSURL *)url;

/// 推荐：用 songId 生成稳定 scheme，realURL 存内部映射，请求时用 songId 作缓存 key（不随 URL 变化）
+ (NSURL *)buildStreamingURLWithSongId:(long)songId realURL:(NSURL *)url;
/// 从 streaming URL（streaming://{songId}）解析出当时注册的 realURL
+ (NSURL *)realURLForStreamingURL:(NSURL *)streamingURL;
@end

NS_ASSUME_NONNULL_END
