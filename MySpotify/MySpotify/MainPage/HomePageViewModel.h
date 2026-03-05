//
//  HomePageViewModel.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/11/17.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@class SongModel, SongPlayingModel;
@interface HomePageViewModel : NSObject

@property (nonatomic, strong) NSMutableArray *arrayOfSomeRecommendedSongs;
@property (nonatomic, strong) NSMutableArray *arrayOfSomeRecommendedArtists;
@property (nonatomic, strong) NSMutableArray* arrayOfSomeRecommededAlbums;
@property (nonatomic, strong) NSMutableArray* arrayOfSomeRecommendedCategories;
@property (nonatomic, copy) void(^updateUI)(void);
@property (nonatomic, copy) void(^endRefreshing)(void);
@property (nonatomic, copy) void(^researchSong)(void);

- (void)loadHomePageData;
- (void)refreshData;
- (void)fetchSongData:(SongPlayingModel* )model;

@end


NS_ASSUME_NONNULL_END


