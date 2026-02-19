//
//  SongPlayingModel.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/3.
//

#import "SongPlayingModel.h"

@implementation SongPlayingModel
- (instancetype)initWithSongName:(NSString* )songName andArtistName:(NSString* )artistName andSongId:(long)id andPicUrl:(NSString* )picUrl andMusicSource:(NSString* )resource andIsDownloaded:(BOOL) isDownload {
  if (self = [super init]) {
    _name = [songName copy];
    _artistName = [artistName copy];
    _songId = id;
    _headerUrl = [picUrl copy];
    _audioResources = [resource copy];
    _isDownload = isDownload;
  }
  return self;
}
@end
