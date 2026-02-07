//
//  MyCollectionViewLayout.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/18.
//
#import "MyCollectionViewLayout.h"
@interface MyCollectionViewLayout ()
@property (nonatomic, strong) NSMutableArray<NSNumber *> *columnHeights;
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *attributesArray;
@property (nonatomic, assign) CGFloat contentHeight;
@end

@implementation MyCollectionViewLayout

- (instancetype)init {
  if (self = [super init]) {
    self.columnCount = 2;
    self.columnMargin = 10;
    self.rowMargin = 10;
    self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.attributesArray = [NSMutableArray array];
  }
  return self;
}

- (void)prepareLayout {
  [super prepareLayout];

  [self.attributesArray removeAllObjects];
  self.contentHeight = 0;

  self.columnHeights = [NSMutableArray array];
  for (NSInteger i = 0; i < self.columnCount; i++) {
    [self.columnHeights addObject:@(self.sectionInset.top)];
  }

  NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];

  CGFloat collectionWidth = self.collectionView.bounds.size.width;
  CGFloat itemWidth = (collectionWidth - self.sectionInset.left - self.sectionInset.right - (self.columnCount - 1) * self.columnMargin) / self.columnCount;

  for (NSInteger i = 0; i < itemCount; i++) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];

    NSInteger destColumn = 0;
    CGFloat minHeight = [self.columnHeights[0] floatValue];

    for (NSInteger col = 1; col < self.columnCount; col++) {
      CGFloat height = [self.columnHeights[col] floatValue];
      if (height < minHeight) {
        minHeight = height;
        destColumn = col;
      }
    }

    CGFloat itemHeight = 100;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:heightForItemAtIndexPath:itemWidth:)]) {
      itemHeight = [self.delegate collectionView:self.collectionView layout:self heightForItemAtIndexPath:indexPath itemWidth:itemWidth];
    }

    CGFloat x = self.sectionInset.left + destColumn * (itemWidth + self.columnMargin);
    CGFloat y = minHeight;
    if (y != self.sectionInset.top) {
      y += self.rowMargin;
    }

    CGRect frame = CGRectMake(x, y, itemWidth, itemHeight);

    UICollectionViewLayoutAttributes *attrs =
    [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attrs.frame = frame;
    [self.attributesArray addObject:attrs];

    // 更新列高度
    self.columnHeights[destColumn] = @(CGRectGetMaxY(frame));

    // 更新内容高度
    CGFloat columnHeight = [self.columnHeights[destColumn] floatValue];
    if (columnHeight > self.contentHeight) {
      self.contentHeight = columnHeight;
    }
  }

  self.contentHeight += self.sectionInset.bottom;
}

//必须重写的方法

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
  return self.attributesArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
  return self.attributesArray[indexPath.item];
}

- (CGSize)collectionViewContentSize {
  return CGSizeMake(0, self.contentHeight);
}

@end
