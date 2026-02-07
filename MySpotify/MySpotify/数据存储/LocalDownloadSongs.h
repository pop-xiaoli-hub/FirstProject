//
//  LocalDownloadSongs.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/2.
//

#import <Foundation/Foundation.h>
#import "DatabaseProtocol.h"
@interface LocalDownloadSongs : NSObject<DatabaseProtocol>
@property(nonatomic, assign) long songId;      // 主键：歌曲ID
@property(nonatomic, copy) NSString *localPath;         // 本地路径
@property(nonatomic, copy) NSString *picUrl;      //封面图
@property(nonatomic, copy) NSString *songName;    //歌曲名
@property(nonatomic, copy) NSString *artistName;  //作曲家
+ (nonnull NSString *)tableName;

@end
