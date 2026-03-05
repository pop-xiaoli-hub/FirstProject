//
//  HomePageView.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/11/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomePageView : UIView
@property (nonatomic, strong)UIButton* buttonOfExpand;
@property (nonatomic, strong)UIButton* buttonOfAll;
@property (nonatomic, strong)UIButton* buttonOfSongs;
@property (nonatomic, strong)UIButton* buttonOfAudioBooks;
@property (nonatomic, strong)UITableView* tableView;
@property (nonatomic, strong)UIView* playerBackgroudView;



@end

NS_ASSUME_NONNULL_END
