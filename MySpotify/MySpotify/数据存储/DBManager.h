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
- (BOOL)createTable:(id<DatabaseProtocol, WCTTableCoding>)object;
- (NSArray<SongDBModel *> *)queryAllSongs;
- (NSArray<LocalDownloadSongs *> *)queryOfDownloadSongs;
- (BOOL)insert:(id)object;
@end

NS_ASSUME_NONNULL_END

