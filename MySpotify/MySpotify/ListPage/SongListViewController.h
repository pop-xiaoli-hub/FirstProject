//
//  SongListViewController.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/20.
//

#import <UIKit/UIKit.h>
@class SongListHeaderView;
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, SongListType) {
  SongListTypeCategory,
  SongListTypeAlbum
};
@interface SongListViewController : UIViewController
@property (nonatomic, strong)SongListHeaderView* headerView;
@property (nonatomic, strong)UITableView* tableView;
- (instancetype)initWithId:(NSInteger)id type:(SongListType)type name:(NSString* )name;
@end

NS_ASSUME_NONNULL_END
