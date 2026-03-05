//
//  SongListFooterView.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, LoadMoreState) {
    LoadMoreStateIdle,        // 空闲
    LoadMoreStateLoading,     // 正在加载
    LoadMoreStateNoMoreData   // 没有更多
};
@interface SongListFooterView : UIView
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UILabel *label;
- (void)setState:(LoadMoreState)state;
@end

NS_ASSUME_NONNULL_END
