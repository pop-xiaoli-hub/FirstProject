//
//  ScrollTableViewCell.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/20.
//

#import <UIKit/UIKit.h>
@class SongDBModel;
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, CustomCollectionViewCellType) {
  CustomCollectionViewCellTypeSong,
  CustomCollectionViewCellTypePodcasting,
  CustomCollectionViewCellTypeNote
};
@interface ScrollTableViewCell : UITableViewCell
@property (nonatomic, strong) UILabel *indexLabel;
@property (nonatomic, strong) UIImageView *songImageView;
@property (nonatomic, strong) UILabel *songNameLabel;
@property (nonatomic, strong) UILabel *artistNameLabel;
@property (nonatomic, strong) UIImageView *trailingIconView;
@property (nonatomic, strong) UILabel *yearLabel;
@property (nonatomic, assign) CustomCollectionViewCellType cellType;
- (void)configWithSong:(SongDBModel*)model;
@end

NS_ASSUME_NONNULL_END
