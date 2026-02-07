//
//  DownloadTableViewCell.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/2.
//

#import <UIKit/UIKit.h>
@class LocalDownloadSongs;
NS_ASSUME_NONNULL_BEGIN

@interface DownloadTableViewCell : UITableViewCell
- (void)configWithSong:(LocalDownloadSongs *)song;
@end

NS_ASSUME_NONNULL_END
