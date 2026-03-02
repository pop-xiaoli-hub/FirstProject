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
@interface DBManager ()
@property (nonatomic, strong) WCTDatabase *database;
@end

@implementation DBManager

+ (instancetype)shared {
    static DBManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DBManager alloc] init];
        [manager setupDatabase];
    });
    return manager;
}

- (void)setupDatabase {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject
     stringByAppendingPathComponent:@"myspotify.db"];
    self.database = [[WCTDatabase alloc] initWithPath:path];
    if ([self.database canOpen]) {
        NSLog(@"数据库打开成功：%@", path);
    } else {
        NSLog(@"数据库打开失败");
    }
//  SongDBModel* songModel = [[SongDBModel alloc] init];
//  songModel.songId = 3334597712;
//  songModel.songName = @"假意 Beat";
//  songModel.artistName = @"prodjaded";
//  songModel.url = @"http://m701.music.126.net/20260120224112/c9f4ed478b5e240d36edbefdec898210/jdymusic/obj/wo3DlMOGwrbDjj7DisKw/77498532022/ee4f/a6c2/4073/83a73ed7d0f2a0011ae1c1ebb3a9f51f.mp3?vuutv=ujRMTjNOLZuScdqvA/k2UeQEqhVz9Xmc1WXopBtmw4NtxvOehTkjI/5fgNyk4lBjg9mOjEwRlNVElEA96wtP4ZCFji8KsbryiFlBcIKkb9s=";
//  songModel.picUrl = @"http://p4.music.126.net/4ThtjxQ4wmIMmkHw7flNDw==/109951172520480756.jpg";
//  songModel.cacheSize = 0;
//  songModel.isCompleted = NO;
//  [self createTable:songModel];
//  [self insert:songModel];
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

- (void)cleanCacheWithMaxSize:(long long)maxSize {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

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
