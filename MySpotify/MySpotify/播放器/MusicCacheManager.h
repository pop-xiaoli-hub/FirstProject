//
//  MusicCacheManager.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/29.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MusicCacheManager : NSObject

@property (nonatomic, strong, readonly) AVPlayer *player;

+ (instancetype)sharedManager;

/// 播放网络歌曲（边听边缓存）
- (void)playStreamWithURL:(NSURL *)url songID:(NSString *)songID;

/// 下载歌曲到缓存（离线播放）
- (void)downloadSongWithURL:(NSURL *)url songID:(NSString *)songID
                 completion:(void (^)(NSString * _Nullable filePath, NSError * _Nullable error))completion;

/// 判断本地缓存是否存在
- (BOOL)isSongCached:(NSString *)songID;

/// 获取缓存文件路径
- (NSString *)cachedFilePathForSongID:(NSString *)songID;

/// 清理所有缓存
- (void)clearAllCache;

@end

NS_ASSUME_NONNULL_END
