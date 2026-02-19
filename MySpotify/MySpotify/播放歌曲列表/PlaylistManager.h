//
//  PlaylistManager.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/9.
//

#import <Foundation/Foundation.h>
@class SongPlayingModel;
typedef NS_ENUM(NSInteger, PlayMode) {
PlayModeOrder, // 顺序播放
PlayModeSingleLoop, // 单曲循环
PlayModeShuffle // 随机播放
};
NS_ASSUME_NONNULL_BEGIN

@interface PlaylistManager : NSObject
@property (nonatomic, strong)NSMutableArray<SongPlayingModel* >* playlist;
@property (nonatomic, assign)NSInteger currentIndex;
@property (nonatomic, assign)PlayMode playMode;

+ (instancetype)shared;
- (void)setPlaylist:(NSArray<SongPlayingModel *> *)list startIndex:(NSInteger)index;
- (void)addSong:(SongPlayingModel *)song;

- (SongPlayingModel *)currentSong;
- (SongPlayingModel *)nextSong;
- (SongPlayingModel *)previousSong;

@end

NS_ASSUME_NONNULL_END
