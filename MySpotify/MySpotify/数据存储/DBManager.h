//
//  DBManager.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/12.
//

#import <Foundation/Foundation.h>
#import <WCDB/WCDBObjc.h>
#import "DatabaseProtocol.h"
NS_ASSUME_NONNULL_BEGIN
@class SongDBModel, LocalDownloadSongs;
@interface DBManager : NSObject

@property (nonatomic, strong, readonly) WCTDatabase *database;

+ (instancetype)shared;

// 初始化数据库
- (void)setupDatabase;
- (void)cleanCacheWithMaxSize:(long long)maxSize;
- (BOOL)createTable:(id<DatabaseProtocol, WCTTableCoding>)object;
- (NSArray<SongDBModel *> *)queryAllSongs;
- (NSArray<LocalDownloadSongs *> *)queryOfDownloadSongs;
- (BOOL)dataBaseHasObject:(long)songId;
- (BOOL)insert:(id)object;

/// 按主键更新表内一条记录（对象需遵循 DatabaseProtocol 与 WCTTableCoding）
- (BOOL)updateObject:(id)object;

/// 按主键删除表内一条记录（对象需遵循 DatabaseProtocol 与 WCTTableCoding）
- (BOOL)deleteObject:(id)object;

/// 按 songId 删除缓存表 cacheSongs 中的一条记录
- (BOOL)deleteSongWithId:(long)songId;

/// 按 songId 删除下载表 downloadSongs 中的一条记录
- (BOOL)deleteDownloadSongWithId:(long)songId;

/// 按 songId 查询缓存表（推荐：缓存 key 已改为 songId，稳定）
- (SongDBModel * _Nullable)querySongWithSongId:(long)songId;
/// 按 url 查询（兼容旧逻辑；url 动态变化时可能查不到）
- (SongDBModel * _Nullable)querySongWithURL:(NSString *)url;

/// 仅更新某首歌的缓存信息：本地路径、已缓存大小、是否完整（用于流式缓存落盘后同步）
- (BOOL)updateSongCacheInfoWithSongId:(long)songId filePath:(NSString * _Nullable)filePath cacheSize:(long long)cacheSize isCompleted:(BOOL)isCompleted;
@end

NS_ASSUME_NONNULL_END

