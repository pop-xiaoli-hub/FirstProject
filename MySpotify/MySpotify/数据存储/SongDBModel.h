//
//  SongDBModel.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/12.
//

#import <Foundation/Foundation.h>
#import "DatabaseProtocol.h"
@interface SongDBModel : NSObject<DatabaseProtocol>

@property(nonatomic, assign) long songId;      // 主键：歌曲ID
@property(nonatomic, copy) NSString *url;         // 曲资源
@property(nonatomic, copy) NSString *picUrl;      //封面图
@property(nonatomic, copy) NSString *songName;    //歌曲名
@property(nonatomic, copy) NSString *artistName;  //作曲家
@property(nonatomic, assign) long long totalSize; // 文件总大小
@property(nonatomic, assign) long long cacheSize; // 已缓存大小
@property(nonatomic, assign) BOOL isCompleted;    // 是否缓存完成
@property(nonatomic, copy) NSString *filePath;    // 本地缓存路径
+ (nonnull NSString *)tableName;
@end
