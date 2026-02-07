//
//  SongDBModel.mm
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/12.
//

#import "SongDBModel+WCTTableCoding.h"
#import "SongDBModel.h"
#import <WCDB/WCDBObjc.h>

@implementation SongDBModel
WCDB_IMPLEMENTATION(SongDBModel)
WCDB_SYNTHESIZE(songId)
//WCDB_SYNTHESIZE(url)
WCDB_SYNTHESIZE(picUrl)
WCDB_SYNTHESIZE(songName)
WCDB_SYNTHESIZE(artistName)
WCDB_SYNTHESIZE(totalSize)
WCDB_SYNTHESIZE(cacheSize)
WCDB_SYNTHESIZE(isCompleted)
WCDB_SYNTHESIZE(filePath)
WCDB_PRIMARY(songId)

+ (nonnull NSString *)tableName {
  return @"cacheSongs";
}


- (nonnull NSString *)primaryKey { 
  return @"songId";
}

- (long)primaryKeyValue {
  return self.songId;
}

- (nonnull NSString *)tableName { 
  return @"cacheSongs";
}

@end
