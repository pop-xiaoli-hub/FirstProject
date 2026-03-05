//
//  MinePageTableViewCell.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class SongModel;
@interface MinePageTableViewCell : UITableViewCell
@property (nonatomic, copy) void (^likeBlock)(NSInteger index);
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UITableView *tableViewOfSongs;
@property (nonatomic, strong) NSMutableArray *localSongArray;
@property (nonatomic, copy) void (^buttonClickBlock)(UIButton *);
@property (nonatomic, copy) void (^downloadButtonBlock)(void);
@property (nonatomic, copy) void (^cacheSongButtonBlock)(void);
- (void)configWithSongs:(NSArray<SongModel *> *)songs;
@end

NS_ASSUME_NONNULL_END

