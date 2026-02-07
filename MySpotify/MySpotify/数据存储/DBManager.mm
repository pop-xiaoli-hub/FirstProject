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



@end
