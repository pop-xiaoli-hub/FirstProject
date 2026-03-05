//
//  WebCacheManager.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/24.
//

#import <Foundation/Foundation.h>
#import "SpotifyService.h"
NS_ASSUME_NONNULL_BEGIN
typedef void(^WebCacheCompletion)(NSData* _Nullable data, BOOL fromCache,NSError* _Nullable error);
@interface LZWebCacheManager : NSObject
@property (nonatomic, strong)NSCache* memoryCache;
@property (nonatomic, copy)NSString* diskCachePath;
@property (nonatomic, strong)SpotifyService* service;
+ (instancetype)sharedCache;
//一级缓存
- (NSData* )dataFromMemoryCacheForKey:(NSString* )key;
- (void)storeDataToMemoryCache:(NSData* )data forKey:(NSString* )key;
- (void)clearMemoryCache;
//二级缓存
- (NSData* )dataFromDiskCacheForKey:(NSString *)key;
- (void)storeDataToDiskCache:(NSData* )data forKey:(NSString* )key;
- (BOOL)diskCacheExistsForKey:(NSString* )key;
- (void)clearDiskCache;
//三级缓存
- (void)dataForKey:(NSString* )key remoteURL:(NSURL* )url completion:(WebCacheCompletion)completion;
//通用工具
- (void)storeData:(NSData* )data forKey:(NSString* )key;
- (NSString* )cachePathForKey:(NSString* )key;
- (NSString* )filePathForKey:(NSString* )key;
//- (NSString* )md5String:(NSString* )string;
- (void)clearAllCache;
- (NSString *)sha256String:(NSString *)string;
@end
NS_ASSUME_NONNULL_END
