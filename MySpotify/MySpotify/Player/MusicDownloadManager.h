//
//  MusicDownloadManager.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MusicDownloadManager : NSObject

+ (instancetype)sharedManager;
- (void)downloadSongWithURL:(NSURL *)url progress:(void(^)(float))progressBlock completion:(void(^)(NSURL *, NSError *))completionBlock;
- (void)cancelDownloadForURL:(NSURL *)url;
@end

NS_ASSUME_NONNULL_END
