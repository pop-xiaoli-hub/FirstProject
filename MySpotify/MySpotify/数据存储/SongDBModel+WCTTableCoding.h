//
//  SongDBModel+WCTTableCoding.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/12.
//

#import "SongDBModel.h"
#import <WCDB/WCDBObjc.h>

@interface SongDBModel (WCTTableCoding) <WCTTableCoding>


WCDB_PROPERTY(songId)
WCDB_PROPERTY(url)
WCDB_PROPERTY(picUrl)
WCDB_PROPERTY(songName)
WCDB_PROPERTY(artistName)
WCDB_PROPERTY(totalSize)
WCDB_PROPERTY(cacheSize)
WCDB_PROPERTY(isCompleted)
WCDB_PROPERTY(filePath)

@end
