//
//  LZCachePathHelper.m
//  MySpotify
//
//  缓存路径工具：根目录每次从系统 API 获取，避免持久化绝对路径。
//

#import "LZCachePathHelper.h"

@implementation LZCachePathHelper

+ (NSString *)cacheRootDirectory {
  NSString *root = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
  return root ?: @"";
}

+ (NSString *)streamCacheDirectory {
  NSString *dir = [[self cacheRootDirectory] stringByAppendingPathComponent:@"StreamCache"];
  if (dir.length > 0 && ![[NSFileManager defaultManager] fileExistsAtPath:dir]) {
    [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
  }
  return dir;
}

+ (NSString *)audioCacheDirectory {
  NSString *dir = [[self cacheRootDirectory] stringByAppendingPathComponent:@"AudioCache"];
  if (dir.length > 0 && ![[NSFileManager defaultManager] fileExistsAtPath:dir]) {
    [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
  }
  return dir;
}

+ (NSString *)pathInStreamCacheForFileName:(NSString *)fileName {
  if (!fileName.length) return [self streamCacheDirectory];
  return [[self streamCacheDirectory] stringByAppendingPathComponent:fileName];
}

+ (NSString *)pathInAudioCacheForFileName:(NSString *)fileName {
  if (!fileName.length) return [self audioCacheDirectory];
  return [[self audioCacheDirectory] stringByAppendingPathComponent:fileName];
}

@end
