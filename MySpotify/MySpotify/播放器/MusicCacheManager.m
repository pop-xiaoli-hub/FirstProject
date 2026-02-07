//
//  MusicCacheManager.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/29.
//
#import "MusicCacheManager.h"

@interface MusicCacheManager () <NSURLSessionDataDelegate>

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) NSMutableData *audioData;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSString *tempFilePath;
@property (nonatomic, strong) NSString *currentSongID;

@end

@implementation MusicCacheManager

+ (instancetype)sharedManager {
    static MusicCacheManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MusicCacheManager alloc] init];
    });
    return manager;
}

#pragma mark - 播放网络歌曲（边听边缓存）
- (void)playStreamWithURL:(NSURL *)url songID:(NSString *)songID {

    self.currentSongID = songID;

    NSString *cachePath = [self cachedFilePathForSongID:songID];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
        // 已缓存，直接播放
        self.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:cachePath]];
        [self.player play];
        return;
    }

    // 未缓存，边听边缓存
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *tempPath = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.temp", songID]];
    self.tempFilePath = tempPath;

    self.audioData = [NSMutableData data];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    self.dataTask = [session dataTaskWithURL:url];
    [self.dataTask resume];
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.audioData appendData:data];

    // 写入临时文件
    [self.audioData writeToFile:self.tempFilePath atomically:YES];

    if (!self.player) {
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:self.tempFilePath]];
        self.player = [AVPlayer playerWithPlayerItem:item];
        [self.player play];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (!error) {
        // 下载完成，将临时文件重命名为正式缓存文件
        NSString *finalPath = [self cachedFilePathForSongID:self.currentSongID];
        [[NSFileManager defaultManager] moveItemAtPath:self.tempFilePath toPath:finalPath error:nil];
    } else {
        NSLog(@"边听边缓存失败: %@", error.localizedDescription);
    }
}

#pragma mark - 下载歌曲到缓存
- (void)downloadSongWithURL:(NSURL *)url songID:(NSString *)songID
                 completion:(void (^)(NSString * _Nullable filePath, NSError * _Nullable error))completion {

    if ([self isSongCached:songID]) {
        if (completion) completion([self cachedFilePathForSongID:songID], nil);
        return;
    }

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url
                                                completionHandler:^(NSURL * _Nonnull location, NSURLResponse * _Nonnull response, NSError * _Nullable error) {
        if (!error) {
            NSString *cachePath = [self cachedFilePathForSongID:songID];
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:cachePath] error:nil];
            if (completion) completion(cachePath, nil);
        } else {
            if (completion) completion(nil, error);
        }
    }];
    [task resume];
}

#pragma mark - 缓存管理
- (BOOL)isSongCached:(NSString *)songID {
    NSString *path = [self cachedFilePathForSongID:songID];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (NSString *)cachedFilePathForSongID:(NSString *)songID {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    return [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", songID]];
}

- (void)clearAllCache {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *files = [manager contentsOfDirectoryAtPath:cacheDir error:nil];
    for (NSString *file in files) {
        if ([file hasSuffix:@".mp3"] || [file hasSuffix:@".temp"]) {
            [manager removeItemAtPath:[cacheDir stringByAppendingPathComponent:file] error:nil];
        }
    }
}

@end
