//
//  DetailMusicPlayerView.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class SongPlayingModel;
@class LyricLine;
@class MusicSlider;

@interface DetailMusicPlayerView : UIView

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign)BOOL isLoading;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *songNameLabel;
@property (nonatomic, strong) UIButton *previousButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIButton *switchButton;
@property (nonatomic, strong) MusicSlider *slider;
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) UIButton *downloadButton;
@property (nonatomic, strong) UIView *lyricContainerView;
@property (nonatomic, strong) UITableView *lyricTableView;
@property (nonatomic, copy) NSArray<LyricLine *> *lyricLines;
@property (nonatomic, assign) NSInteger currentLineIndex;
@property (nonatomic, assign, readwrite) BOOL showingLyrics;
@property (nonatomic, copy) void (^buttonClickBlock)(UIButton *);
@property (nonatomic, copy) void (^showSongLyrics)(void);

/// 歌词容器（与封面同区域，点击封面后显示）
//@property (nonatomic, strong, readonly) UIView *lyricContainerView;
/// 是否正在显示歌词（否则显示封面）
//@property (nonatomic, assign, readonly) BOOL showingLyrics;

- (void)configureWithModel:(SongPlayingModel *)model;
- (void)resetControlsWithDownloaded:(BOOL)isDownloaded;

/// 设置歌词行，传 nil 或空数组表示无歌词
- (void)setLyricLines:(NSArray<LyricLine *> * _Nullable)lines;
/// 根据播放时间更新当前行高亮并滚动居中
- (void)updateCurrentTime:(NSTimeInterval)currentTime;
/// 切回封面（切歌时调用）
- (void)resetToCover;
@end

NS_ASSUME_NONNULL_END
