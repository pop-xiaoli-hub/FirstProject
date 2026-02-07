//
//  SongListTableViewCell.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/20.
//

#import <UIKit/UIKit.h>
@class SongModel;
NS_ASSUME_NONNULL_BEGIN

@interface SongListTableViewCell : UITableViewCell
- (void)configWithSong:(SongModel *)song;
@end

NS_ASSUME_NONNULL_END
