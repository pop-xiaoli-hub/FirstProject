//
//  SongListHeaderView.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/20.
//

#import <UIKit/UIKit.h>
#import "PlaylistModel.h"
NS_ASSUME_NONNULL_BEGIN
@class SongListHeaderView;
@protocol SongListHeaderViewDelegate <NSObject>
- (void)headerViewDidTapPlayAll:(SongListHeaderView *)headerView;
- (void)headerViewDidTapDownload:(SongListHeaderView *)headerView;
- (void)headerViewDidTapSort:(SongListHeaderView *)headerView;
- (void)headerView:(SongListHeaderView *)headerView didTapTopAction:(NSString *)type;
@end

@interface SongListHeaderView : UIView
@property (nonatomic, weak)id<SongListHeaderViewDelegate> delegate;
//@property (nonatomic, strong, readonly)UIImageView* artistImageView;
- (void)configWithPlayList:(PlaylistModel *)playlist;
@end

NS_ASSUME_NONNULL_END
