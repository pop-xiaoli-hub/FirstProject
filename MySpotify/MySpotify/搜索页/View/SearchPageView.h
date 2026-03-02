//
//  SearchPageView.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/18.
//


#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface SearchPageView : UIView

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong)UITableView* resultTableview;
@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UIView *darkMaskView;
- (void)showResultTable;
- (void)hideResultTable;
@end
NS_ASSUME_NONNULL_END
