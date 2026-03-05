//
//  SearchPageView.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/18.
//

#import "SearchPageView.h"
#import <Masonry/Masonry.h>
#import "MyCollectionViewLayout.h"

@interface SearchPageView ()

// 玻璃效果层

@end

@implementation SearchPageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self setupSearchBar];
        [self setupCollectionView];
        [self setupTableView];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - UI Setup

- (void)setupSearchBar {

    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.placeholder = @"搜索歌曲、艺人或专辑";
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.backgroundColor = [UIColor clearColor];

    UITextField *textField = self.searchBar.searchTextField;
    textField.textColor = [UIColor whiteColor];
    textField.tintColor = [UIColor whiteColor];
    textField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"搜索歌曲、艺人或专辑" attributes:@{
        NSForegroundColorAttributeName : [UIColor colorWithWhite:1.0 alpha:0.6]
    }];

    textField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.15];
    textField.layer.cornerRadius = 10;
    textField.layer.masksToBounds = YES;

    UIImageView *iconView = (UIImageView *)textField.leftView;
    iconView.tintColor = [UIColor whiteColor];
    iconView.image = [iconView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    [self addSubview:self.searchBar];
}

- (void)setupCollectionView {
    MyCollectionViewLayout *layout = [[MyCollectionViewLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.collectionView];
}

#pragma mark - Glass Result Table

- (void)setupTableView {

    // ===== 毛玻璃模糊层 =====
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
    self.blurView.hidden = YES;
    [self addSubview:self.blurView];

    // ===== 暗色玻璃遮罩层 =====
    self.darkMaskView = [[UIView alloc] init];
    self.darkMaskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
    self.darkMaskView.hidden = YES;
    [self addSubview:self.darkMaskView];

    // ===== 搜索结果列表 =====
    self.resultTableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.resultTableview.rowHeight = 60;
    self.resultTableview.backgroundColor = [UIColor clearColor]; // 关键：透明
    self.resultTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.resultTableview.hidden = YES;
    self.resultTableview.userInteractionEnabled = YES;
    [self addSubview:self.resultTableview];

    // 层级顺序
    [self bringSubviewToFront:self.resultTableview];
}

#pragma mark - Constraints

- (void)setupConstraints {

    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(50);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(60);
    }];

    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom);
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
    }];

    // 毛玻璃层
    [self.blurView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.collectionView);
    }];

    // 暗色蒙版
    [self.darkMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.collectionView);
    }];

    // 结果表
    [self.resultTableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.collectionView);
    }];
}

#pragma mark - Public Control Methods

// 显示搜索结果（玻璃效果）
- (void)showResultTable {
    self.blurView.hidden = NO;
    self.darkMaskView.hidden = NO;
    self.resultTableview.hidden = NO;

    self.blurView.alpha = 0;
    self.darkMaskView.alpha = 0;
    self.resultTableview.alpha = 0;

    [UIView animateWithDuration:0.25 animations:^{
        self.blurView.alpha = 1;
        self.darkMaskView.alpha = 1;
        self.resultTableview.alpha = 1;
    }];
}

- (void)hideResultTable {
    [UIView animateWithDuration:0.25 animations:^{
        self.blurView.alpha = 0;
        self.darkMaskView.alpha = 0;
        self.resultTableview.alpha = 0;
    } completion:^(BOOL finished) {
        self.blurView.hidden = YES;
        self.darkMaskView.hidden = YES;
        self.resultTableview.hidden = YES;
    }];
}

@end
