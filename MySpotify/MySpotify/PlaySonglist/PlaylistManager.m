//
//  PlaylistManager.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/9.
//

#import "PlaylistManager.h"
#import "SongPlayingModel.h"
@implementation PlaylistManager

+ (instancetype)shared {
  static PlaylistManager *m;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    m = [[PlaylistManager alloc] init];
    m.playlist = [NSMutableArray array];
    m.currentIndex = 0;
    m.playMode = PlayModeOrder;
  });
  return m;
}

//- (void)setPlaylist:(NSArray<SongPlayingModel *> *)list startIndex:(NSInteger)index {
//  [self.playlist removeAllObjects];
//  [self.playlist addObjectsFromArray:list];
//  self.currentIndex = (index >= 0 && index < self.playlist.count) ? index : 0;
//}

- (void)addSong:(SongPlayingModel *)song {
  if (song) {
    [self.playlist insertObject:song atIndex:0];
  }
}

- (SongPlayingModel *)currentSong {
  if (self.currentIndex < 0 || self.currentIndex >= self.playlist.count) {
    return nil;
  }
  return self.playlist[self.currentIndex];
}

- (SongPlayingModel *)nextSong {
  if (_playlist.count == 0) {
    return nil;
  }

  if (self.playMode == PlayModeShuffle) {
    _currentIndex = arc4random_uniform((uint32_t)_playlist.count);
  } else {
    _currentIndex = (_currentIndex + 1) % self.playlist.count;
  }
  return _playlist[_currentIndex];
}

- (SongPlayingModel *)previousSong {
  if (_playlist.count == 0) {
    return nil;
  }
  _currentIndex = (_currentIndex - 1 + _playlist.count) % _playlist.count;
  return _playlist[_currentIndex];
}

@end
