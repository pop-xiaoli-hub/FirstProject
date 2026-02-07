//
//  SongPlayingModel.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/3.
//

#import "SongPlayingModel.h"

@implementation SongPlayingModel
- (instancetype)initWithSongName:(NSString* )songName andArtistName:(NSString* )artistName andSongId:(long)id andPicUrl:(NSString* )picUrl andMusicSource:(NSString* )resource {
  if (self = [super init]) {
    _name = [songName copy];
    _artistName = [artistName copy];
    _songId = id;
    _headerUrl = [picUrl copy];
    _audioResources = [resource copy];
  }
  return self;
}
@end
