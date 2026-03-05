//
//  LocalDownloadSongs.mm
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/2.
//

#import "LocalDownloadSongs+WCTTableCoding.h"
#import "LocalDownloadSongs.h"
#import <WCDB/WCDBObjc.h>

@implementation LocalDownloadSongs


WCDB_IMPLEMENTATION(LocalDownloadSongs)
WCDB_SYNTHESIZE(songId)
WCDB_SYNTHESIZE(localPath)
WCDB_SYNTHESIZE(artistName)
WCDB_SYNTHESIZE(songName)
WCDB_SYNTHESIZE(picUrl)
WCDB_PRIMARY(songId)
+ (nonnull NSString *)tableName {
  return @"downloadSongs";
}


- (nonnull NSString *)primaryKey {
  return @"songId";
}

- (long)primaryKeyValue {
  return self.songId;
}

- (nonnull NSString *)tableName {
  return @"downloadSongs";
}

@end
