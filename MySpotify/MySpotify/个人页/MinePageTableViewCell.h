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
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray<SongModel *> *songs;
@property (nonatomic, strong) UISegmentedControl* segmentControl;
@property (nonatomic, strong) UITableView* tableViewOfSongs;
@property (nonatomic, strong) UITableView* tableViewOfPodcasting;
@property (nonatomic, strong) UITableView* tableViewOfNotes;
@property (nonatomic, strong) NSMutableArray* localSongArray;
@property (nonatomic, copy) void (^buttonClickBlock)(UIButton*);
- (void)configWithSongs:(NSArray<SongModel *> *)songs;
@end

NS_ASSUME_NONNULL_END

