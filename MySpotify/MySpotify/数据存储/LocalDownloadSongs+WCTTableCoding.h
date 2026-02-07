//
//  LocalDownloadSongs+WCTTableCoding.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/2.
//

#import "LocalDownloadSongs.h"
#import <WCDB/WCDBObjc.h>

@interface LocalDownloadSongs (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(songId)
WCDB_PROPERTY(localPath)
WCDB_PROPERTY(picUrl)
WCDB_PROPERTY(songName)
WCDB_PROPERTY(artistName)

@end
