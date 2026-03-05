//
//  LyricTableViewCell.h
//  MySpotify
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LyricTableViewCell : UITableViewCell
@property (nonatomic, strong) UILabel *lyricLabel;
- (void)setLyricText:(NSString *)text highlighted:(BOOL)highlighted;
@end

NS_ASSUME_NONNULL_END
