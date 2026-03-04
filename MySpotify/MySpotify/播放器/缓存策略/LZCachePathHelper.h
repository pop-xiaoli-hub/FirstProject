//
//  LZCachePathHelper.h
//  MySpotify
//
//  缓存路径工具：仅用「固定子目录名 + 逻辑 key」生成路径，根目录每次从系统 API 获取，
//  避免保存模拟器/沙盒的绝对路径，重装或重新编译后仍能正确找到缓存。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LZCachePathHelper : NSObject

/// 缓存根目录（NSCachesDirectory，每次调用都从系统取，不持久化）
+ (NSString *)cacheRootDirectory;

/// 流式缓存子目录（用于 LZDiskCache），路径 = cacheRoot/StreamCache
+ (NSString *)streamCacheDirectory;

/// 音频整文件缓存子目录（用于 MusicCacheManager 等），路径 = cacheRoot/AudioCache
+ (NSString *)audioCacheDirectory;

/// 根据子目录名与文件名生成完整路径（不包含动态符号，仅相对子目录 + 文件名）
+ (NSString *)pathInStreamCacheForFileName:(NSString *)fileName;
+ (NSString *)pathInAudioCacheForFileName:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
