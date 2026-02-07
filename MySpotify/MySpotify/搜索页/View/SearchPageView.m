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


@end

@implementation SearchPageView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor blackColor];
    [self setupSearchBar];
    [self setupCollectionView];
    [self setupConstraints];
  }
  return self;
}

- (void)setupSearchBar {

    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.placeholder = @"搜索歌曲、艺人或专辑";
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.backgroundColor = [UIColor clearColor];

    UITextField *textField = self.searchBar.searchTextField;

    textField.textColor = [UIColor whiteColor];

    textField.tintColor = [UIColor whiteColor];

    textField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"搜索歌曲、艺人或专辑"
                                    attributes:@{
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
}

@end
