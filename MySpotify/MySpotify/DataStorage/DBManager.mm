//
//  DBManager.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/12.
//

#import "DBManager.h"
#import "SongDBModel.h"
#import "SongDBModel+WCTTableCoding.h"
#import "LocalDownloadSongs.h"
#import "LocalDownloadSongs+WCTTableCoding.h"
#import "LZDiskCache.h"
#import "LZMemoryCache.h"
@interface DBManager ()
@property (nonatomic, strong) WCTDatabase *database;
@property (nonatomic, strong) dispatch_queue_t cleanQueue;
@end

@implementation DBManager

+ (instancetype)shared {
  static DBManager *manager;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    manager = [[DBManager alloc] init];
    manager.cleanQueue = dispatch_queue_create("com.myspotify.disk.clean", DISPATCH_QUEUE_SERIAL);
    [manager setupDatabase];
  });
  return manager;
}

- (void)setupDatabase {
  NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"myspotify.db"];
  self.database = [[WCTDatabase alloc] initWithPath:path];
  if ([self.database canOpen]) {
    NSLog(@"数据库打开成功：%@", path);
  } else {
    NSLog(@"数据库打开失败");
  }
}

- (BOOL)insert:(id)object {
  NSString* string = [object tableName];//这个方法返回任何一个类的一个对应的表名
  BOOL ret = [self.database insertObject:object intoTable:string];
  if (ret) {
    NSLog(@"插入成功");
  } else {
    NSLog(@"插入失败");
  }
  return ret;
}


- (BOOL)createTable:(id<DatabaseProtocol, WCTTableCoding>)object {
  NSString* tableName = [object tableName];
  if (![self.database tableExists:tableName]) {
    BOOL flag = [self.database createTable:tableName withClass:object.class];
    if (flag) {
      NSLog(@"表%@创建成功", tableName);
    } else {
      NSLog(@"表%@创建失败", tableName);
    }
    return flag;
  }
  return YES;
}

- (BOOL)dataBaseHasObject:(long)songId {
  NSArray* songs = [self queryAllSongs];
  for (SongDBModel* model in songs) {
    if (model.songId == songId) {
      return YES;
    }
  }
  return NO;
}

- (NSArray<SongDBModel *> *)queryAllSongs {
  NSString *tableName = [SongDBModel tableName];
  NSArray<SongDBModel *> *result = [self.database getObjectsOfClass:SongDBModel.class fromTable:tableName];
  NSLog(@"查询到 %lu 条歌曲", (unsigned long)result.count);
  return result;
}

- (NSArray<LocalDownloadSongs *> *)queryOfDownloadSongs {
  NSString *tableName = [LocalDownloadSongs tableName];
  NSArray<LocalDownloadSongs *> *result = [self.database getObjectsOfClass:LocalDownloadSongs.class fromTable:tableName];
  NSLog(@"查询到 %lu 条歌曲", (unsigned long)result.count);
  return result;
}

- (BOOL)updateObject:(id)object {
  NSString *tableName = [object tableName];
  BOOL ret = NO;
  if ([object isKindOfClass:[SongDBModel class]]) {
    SongDBModel *model = (SongDBModel *)object;
    ret = [self.database updateTable:tableName setProperties:SongDBModel.allProperties toObject:object where:SongDBModel.songId == model.songId];
    NSLog(@"更新歌曲最后播放时间成功");
  } else if ([object isKindOfClass:[LocalDownloadSongs class]]) {
    LocalDownloadSongs *model = (LocalDownloadSongs *)object;
    ret = [self.database updateTable:tableName setProperties:LocalDownloadSongs.allProperties toObject:object where:LocalDownloadSongs.songId == model.songId];
  } else {
    NSLog(@"updateObject: 不支持的模型类型 %@", [object class]);
    return NO;
  }
  if (ret) {
    NSLog(@"更新成功");
  } else {
    NSLog(@"更新失败");
  }
  return ret;
}

- (BOOL)deleteObject:(id)object {
  NSString *tableName = [object tableName];
  long pkValue = [object primaryKeyValue];
  BOOL ret = NO;
  if ([object isKindOfClass:[SongDBModel class]]) {
    ret = [self.database deleteFromTable:tableName where:SongDBModel.songId == pkValue];
  } else if ([object isKindOfClass:[LocalDownloadSongs class]]) {
    ret = [self.database deleteFromTable:tableName where:LocalDownloadSongs.songId == pkValue];
  } else {
    NSLog(@"deleteObject: 不支持的模型类型 %@", [object class]);
    return NO;
  }
  if (ret) {
    NSLog(@"删除成功");
  } else {
    NSLog(@"删除失败");
  }
  return ret;
}

- (BOOL)deleteSongWithId:(long)songId {
  NSString *tableName = [SongDBModel tableName];
  BOOL ret = [self.database deleteFromTable:tableName where:SongDBModel.songId == songId];
  if (ret) {
    NSLog(@"缓存歌曲删除成功 songId=%ld", songId);
  } else {
    NSLog(@"缓存歌曲删除失败 songId=%ld", songId);
  }
  return ret;
}

- (BOOL)deleteDownloadSongWithId:(long)songId {
  NSString *tableName = [LocalDownloadSongs tableName];
  BOOL ret = [self.database deleteFromTable:tableName where:LocalDownloadSongs.songId == songId];
  if (ret) {
    NSLog(@"下载歌曲删除成功 songId=%ld", songId);
  } else {
    NSLog(@"下载歌曲删除失败 songId=%ld", songId);
  }
  return ret;
}

- (SongDBModel *)querySongWithSongId:(long)songId {
  NSString *tableName = [SongDBModel tableName];
  NSArray<SongDBModel *> *result = [self.database getObjectsOfClass:SongDBModel.class fromTable:tableName where:SongDBModel.songId == songId];
  return result.firstObject;
}

- (SongDBModel *)querySongWithURL:(NSString *)url {
  if (!url || url.length == 0) return nil;
  NSString *tableName = [SongDBModel tableName];
  NSArray<SongDBModel *> *result = [self.database getObjectsOfClass:SongDBModel.class fromTable:tableName where:SongDBModel.url == url];
  return result.firstObject;
}

- (BOOL)updateSongCacheInfoWithSongId:(long)songId filePath:(NSString *)filePath cacheSize:(long long)cacheSize isCompleted:(BOOL)isCompleted {
  NSString *tableName = [SongDBModel tableName];
  NSArray<SongDBModel *> *rows = [self.database getObjectsOfClass:SongDBModel.class fromTable:tableName where:SongDBModel.songId == songId];
  SongDBModel *obj = rows.firstObject;
  if (!obj) {
    return NO;
  }
  obj.filePath = filePath ?: @"";
  obj.cacheSize = cacheSize;
  obj.isCompleted = isCompleted;
  return [self.database updateTable:tableName setProperties:SongDBModel.allProperties toObject:obj where:SongDBModel.songId == songId];
}

- (void)cleanCacheWithMaxSize:(long long)maxSize {
  NSLog(@"diskClean:磁盘缓存开始清理");
  dispatch_async(self.cleanQueue, ^{
    LZDiskCache* disk = [LZDiskCache sharedInstance];
    NSArray* cacheSongs = [self queryAllSongs];
    long long currentSize = 0;
    for (SongDBModel* dbModel in cacheSongs) {
      currentSize += dbModel.cacheSize;
    }
    NSLog(@"当前磁盘缓存占用大小：%lld MB", currentSize / 1024 / 1024);
    if (currentSize <= maxSize) {
      return;
    }
    NSLog(@"开始清理缓存");
    NSArray *sorted = [cacheSongs sortedArrayUsingComparator:^NSComparisonResult(SongDBModel *obj1, SongDBModel *obj2) {
      if (obj1.lastPlayTimestamp > obj2.lastPlayTimestamp) {
        return NSOrderedDescending;
      } else if (obj1.lastPlayTimestamp < obj2.lastPlayTimestamp) {
        return NSOrderedAscending;
      } else {
        return NSOrderedSame;
      }
    }];
    for (SongDBModel* model in sorted) {
      if (currentSize <= maxSize) {
        break;
      }
      long long songID = model.songId;
      NSString* key = [NSString stringWithFormat:@"%lld", songID];
      NSString* diskPath = [disk filePath:key];
      BOOL deleted = NO;
      NSError* error = nil;
      if ([[NSFileManager defaultManager] fileExistsAtPath:diskPath]) {
        deleted = [[NSFileManager defaultManager] removeItemAtPath:diskPath error:&error];
      } else {
        deleted = YES;
      }
      if (deleted) {
        [self deleteSongWithId:songID];
        currentSize -= model.cacheSize;
        NSLog(@"已删除 songID=%lld，剩余大小=%lld MB", songID, currentSize / 1024 / 1024);
      } else {
        NSLog(@"删除失败");
      }
    }
  });
}



@end

/*
 - (void)cleanCacheWithMaxSize:(long long)maxSize {
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
 WCTDatabase *db = [[NLDataBaseManager sharedManager] database];
 // 把账本全拿出来
 NSArray<NLAudioCacheInfo *> *allInfos = [db getObjectsOfClass:NLAudioCacheInfo.class fromTable:kAudioCacheTableName];
 long long currentSize = 0;
 for (NLAudioCacheInfo *info in allInfos) {
 currentSize += info.totalLength;
 }
 if (currentSize <= maxSize) {
 return;
 }
 NSLog(@"[缓存清理] 账本总计 %lld MB, 超出限制 %lld MB，触发 LRU 清理缓存机制", currentSize / 1024 / 1024, maxSize / 1024 / 1024);

 // 按最后访问时间排序，最老的在前面
 NSArray<NLAudioCacheInfo *> *sortedInfos = [allInfos sortedArrayUsingComparator:^NSComparisonResult(NLAudioCacheInfo *obj1, NLAudioCacheInfo *obj2) {
 if (obj1.lastAccessTime < obj2.lastAccessTime) return NSOrderedAscending;
 if (obj1.lastAccessTime > obj2.lastAccessTime) return NSOrderedDescending;
 return NSOrderedSame;
 }];
 // 开始清理老旧文件
 for (NLAudioCacheInfo *info in sortedInfos) {
 NSString *md5 = info.urlMD5;
 // 依然在它的专属队列里杀，防止错杀
 dispatch_sync([self queueForMD5:md5], ^{
 NSString *tmpPath = [self.cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.tmp", md5]];
 NSString *mp3Path = [self.cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", md5]];

 BOOL deleted = NO;
 if ([[NSFileManager defaultManager] fileExistsAtPath:mp3Path]) {
 [[NSFileManager defaultManager] removeItemAtPath:mp3Path error:nil];
 deleted = YES;
 } else if ([[NSFileManager defaultManager] fileExistsAtPath:tmpPath]) {
 [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
 deleted = YES;
 }
 if (deleted) {
 // 文件删了，账本也撕掉
 [db deleteFromTable:kAudioCacheTableName where:NLAudioCacheInfo.urlMD5 == md5];
 NSLog(@"[缓存清理] 剔除了老旧文件 %@，释放了 %lld 空间", md5, info.totalLength);
 }
 });
 // 直接减去账本里记录的大小
 currentSize -= info.totalLength;
 if (currentSize <= maxSize) break; // 达标了，停止杀戮
 }
 });
 }

 - (void)clearAllCache {
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
 NSFileManager *fm = [NSFileManager defaultManager];
 NSError *err = nil;
 NSArray<NSString *> *contents = [fm contentsOfDirectoryAtPath:self.cacheDirectory error:&err];
 if (err) {
 NSLog(@"[缓存] clearAllCache 列举目录失败: %@", err.localizedDescription);
 return;
 }
 for (NSString *name in contents) {
 NSString *path = [self.cacheDirectory stringByAppendingPathComponent:name];
 [fm removeItemAtPath:path error:nil];
 }
 WCTDatabase *db = [[NLDataBaseManager sharedManager] database];
 [db deleteFromTable:kAudioCacheTableName];
 dispatch_async(dispatch_get_main_queue(), ^{
 [[NSNotificationCenter defaultCenter] postNotificationName:NLCacheManagerDidFinishCachingNotification object:self];
 });
 NSLog(@"[缓存] 已清空所有缓存");
 });
 }
 */
