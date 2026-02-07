//
//  HomePageViewModel.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/11/17.
//

#import "HomePageViewModel.h"
#import "SpotifyService.h"

@interface HomePageViewModel()
@property (nonatomic, strong) SpotifyService *service;
@end

@implementation HomePageViewModel

- (void)fetchSongData:(SongModel* )model{
  [self.service fetchSongResources:model completion:^(BOOL temp) {
    if (temp) {
      if (self.researchSong) {
        self.researchSong();
      }
    }
  }];
}

- (instancetype)init {
  if (self = [super init]) {
    _service = [SpotifyService sharedInstance];
  }
  return self;
}

- (void)loadHomePageData {
  [self fetchHomeDataWithShouldRefresh:NO];
}

- (void)refreshData {
  [self fetchHomeDataWithShouldRefresh:YES];
}

- (void)fetchHomeDataWithShouldRefresh:(BOOL)isRefreshing {
  dispatch_group_t group2 = dispatch_group_create();
  dispatch_group_enter(group2);
  [self.service fetchRecommendedSongs:^(NSArray * _Nonnull arrayOfSongs, NSError * _Nonnull error) {
    self.arrayOfSomeRecommendedSongs = [NSMutableArray arrayWithArray:arrayOfSongs];
    dispatch_group_leave(group2);
  }];
  dispatch_group_enter(group2);
  [self.service fetchRecommendedArtists:^(NSArray * _Nonnull arrayOfArtists, NSError * _Nonnull error) {
      NSLog(@"!!!");
    self.arrayOfSomeRecommendedArtists = [NSMutableArray arrayWithArray:arrayOfArtists];
    dispatch_group_leave(group2);
  }];
  dispatch_group_enter(group2);
  [self.service fetchRecommendedAlbums:^(NSArray * _Nonnull arrayOfAlbums, NSError * _Nonnull error) {
    self.arrayOfSomeRecommededAlbums = [NSMutableArray arrayWithArray:arrayOfAlbums];
    dispatch_group_leave(group2);
  }];
  dispatch_group_enter(group2);
  [self.service fetchRandomRecommendedPlaylists:^(NSArray * _Nonnull playlists, NSError * _Nonnull error) {
    self.arrayOfSomeRecommendedCategories = [NSMutableArray arrayWithArray:playlists];
    dispatch_group_leave(group2);
  }];
  dispatch_group_notify(group2, dispatch_get_main_queue(), ^{
    if (self.updateUI) {
      self.updateUI();
    }
    if (isRefreshing && self.endRefreshing) {
      self.endRefreshing();
    }
  });
}




//- (void)fetchHomeDataWithShouldRefsh:(BOOL)isRefreshing {
//    dispatch_group_t group = dispatch_group_create();
//    __block NSString *accessToken = nil;
//
//    dispatch_group_enter(group);
//    [self.service fetchAccessToken:^(NSString *token, NSError *error) {
//        accessToken = token;
//        dispatch_group_leave(group);
//    }];
//
//    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        if (!accessToken) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//              if (self.endRefreshing) {
//                self.endRefreshing();
//              }
//            });
//            return;
//        }
//        dispatch_group_t group2 = dispatch_group_create();
//        dispatch_group_enter(group2);
//        [self.service fetchRandomAlbum:accessToken completion:^(NSString *albumID, NSError *error) {
//            if (albumID) {
//                dispatch_group_enter(group2);
//                [self.service fetchTracksOfAlbum:albumID token:accessToken completion:^(PagingObjectModel *pageModel, NSError *error) {
//                    self.arrayOfSomeCommendTracks = pageModel.items;
//                    dispatch_group_t group3 = dispatch_group_create();
//                    for (TrackModel *track in pageModel.items) {
//                        dispatch_group_enter(group3);
//                        [self.service fetchTrackDetail:track.href token:accessToken completion:^(TrackModel *detail, NSError *error) {
//                            track.imageUrl = detail.imageUrl;
//                            track.image = detail.image;
//                            NSLog(@"问题：%@", track.href);
//                            dispatch_group_leave(group3);
//                        }];
//                    }
//                    dispatch_group_notify(group3, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                        dispatch_group_leave(group2);
//                    });
//                }];
//                dispatch_group_leave(group2);
//            } else {
//                dispatch_group_leave(group2);
//            }
//        }];
//
//        dispatch_group_enter(group2);
//        [self.service fetchRandomArtists:accessToken completion:^(SearchArtistList *artistList, NSError *error) {
//          if (!error) {
//            self.arrayOfArtists = artistList.items;
//          }
//            dispatch_group_leave(group2);
//        }];
//
//        NSArray *randomCategoryArray = [[self getRandomCategoryName] subarrayWithRange:NSMakeRange(0, 4)];
//        NSMutableArray *result = [NSMutableArray array];
//        self.recommendCategoryArray = [NSMutableArray array];
//
//        for (NSString *str in randomCategoryArray) {
//            dispatch_group_enter(group2);
//            [self.service fetchRecommendedAlbum:accessToken andCategory:str completion:^(CategoryModel *categoryModel, NSError *error) {
//              if (categoryModel) {
//                [result addObject:categoryModel];
//                NSLog(@"9090:%@", categoryModel.iconImage);
//              }
//                dispatch_group_leave(group2);
//            }];
//        }
//
//        dispatch_group_notify(group2, dispatch_get_main_queue(), ^{
//            self.recommendCategoryArray = result;
//          if (self.updateUI) {
//            self.updateUI();
//          }
//          if (isRefreshing && self.endRefreshing) {
//            self.endRefreshing();
//          }
//        });
//    });
//}
//
//- (NSMutableArray<NSString *> *)getRandomCategoryName {
//    NSArray<NSString *> *spotifyCategoryNames = @[
//        @"dinner", @"workout", @"sleep", @"chill", @"pop", @"rock", @"hiphop",
//        @"edm_dance", @"jazz", @"country", @"latin", @"focus", @"party",
//        @"gaming", @"wellness", @"kidsmusic"
//    ];
//    NSMutableArray *shuffled = [spotifyCategoryNames mutableCopy];
//
//    for (NSUInteger i = shuffled.count - 1; i > 0; i--) {
//        [shuffled exchangeObjectAtIndex:i
//                      withObjectAtIndex:arc4random_uniform((uint32_t)(i + 1))];
//    }
//    return [NSMutableArray arrayWithArray:[shuffled subarrayWithRange:NSMakeRange(0, 4)]];
//}


@end



/*
 - (void)fetchHomeDataWithShouldRefsh:(BOOL)isRefreshing {
     dispatch_group_t group = dispatch_group_create();
     __block NSString *accessToken = nil;
     __block NSError *internalError = nil;
     dispatch_group_enter(group);
     [self.service fetchAccessToken:^(NSString * _Nullable token, NSError * _Nullable error) {
         if (!token) {
             internalError = error;
         }
         accessToken = token;
         dispatch_group_leave(group);
     }];
     dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         if (!accessToken) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (self.endRefreshing) self.endRefreshing();
             });
             return;
         }

         dispatch_group_t group2 = dispatch_group_create();

         dispatch_group_enter(group2);
         [self.service fetchRandomAlbum:accessToken completion:^(NSString * _Nullable albumID, NSError * _Nullable error) {
             if (error || !albumID) {
                 internalError = error;
                 dispatch_group_leave(group2);
                 return;
             }
             dispatch_group_enter(group2);
             [self.service fetchTracksOfAlbum:albumID token:accessToken completion:^(PagingObjectModel * _Nullable pageModel, NSError * _Nullable error) {
                 if (!error) {
                     self.arrayOfSomeCommendTracks = pageModel.items;
                     dispatch_group_t group3 = dispatch_group_create();
                     for (TrackModel *track in pageModel.items) {
                         dispatch_group_enter(group3);
                         [self.service fetchTrackDetail:track.href token:accessToken completion:^(TrackModel * _Nonnull detail, NSError * _Nonnull error) {
                           if (!error) {
                             track.imageUrl = detail.imageUrl;
                             track.image = detail.image;
                           }
                             dispatch_group_leave(group3);
                         }];
                     }
                     dispatch_group_notify(group3, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                         dispatch_group_leave(group2);
                     });
                 } else {
                     internalError = error;
                     dispatch_group_leave(group2);
                 }
             }];
             dispatch_group_leave(group2);
         }];
         dispatch_group_enter(group2);
         [self.service fetchRandomArtists:accessToken completion:^(SearchArtistList * _Nullable artistList, NSError * _Nullable error) {
             if (!error) {
                 self.arrayOfArtists = artistList.items;
             }
             dispatch_group_leave(group2);
         }];
       NSMutableArray* randomCategoryArray = [self getRandomCategoryName];
       if (!self.recommendCategoryArray) {
         self.recommendCategoryArray = [NSMutableArray array];
       }
       if (self.recommendCategoryArray.count) {
         [self.recommendCategoryArray removeAllObjects];
       }
       self.recommendCategoryArray = [NSMutableArray array];
       __block NSMutableArray* array = [NSMutableArray array];
       for (NSString* str in randomCategoryArray) {
         dispatch_group_enter(group2);
         [self.service fetchRecommendedAlbum:accessToken andCategory:str completion:^(CategoryModel * _Nonnull categoryModel, NSError * _Nonnull error) {
           if (!error) {
             [array addObject:categoryModel];
             if (array.count == 4) {
               self.recommendCategoryArray = [array mutableCopy];
             }
           }
           dispatch_group_leave(group2);
         }];
       }

         dispatch_group_notify(group2, dispatch_get_main_queue(), ^{
             if (self.updateUI) self.updateUI();
             if (isRefreshing && self.endRefreshing) self.endRefreshing();
         });
     });
 }
 */


//- (instancetype)init {
//  if (self = [super init]) {
//    _service = [SpotifyServiceClass sharedService];
//  }
//  return self;
//}
//
//
//- (void)loadHomeDataWithCompletion:(void(^)(NSError* _Nullable))completion {
//  __block NSError* internalError = nil;
//  dispatch_group_t group = dispatch_group_create();
//}
//
//- (void)loadDataOftracks {
//  SongModel* model = [SongModel new];
//  [model applyForDataOfMusic:^(PagingObjectModel * _Nonnull pageModel, NSError * _Nonnull error) {
//      if (!error) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//          self.arrayOfSomeCommendTracks = pageModel.items;
//          if (self.updateUI) {
//            self.updateUI();
//          }
//        });
//      }
//    } and:^(SearchArtistList * _Nonnull searchArtistListModel, NSError * _Nonnull error) {
//
//    }];
//}
//
//
//- (void)loadVideoDataOfSelectedtrack:(NSInteger)index {
//  
//}
//
//- (void)refreshData {
//  [self loadDataOfTracksForRefresh];
//}
//
//- (void)loadDataOfTracksForRefresh {
//  SongModel* model = [SongModel new];
//  [model applyForDataOfMusic:^(PagingObjectModel * _Nonnull pageModel, NSError * _Nonnull error) {
//      if (!error) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//          self.arrayOfSomeCommendTracks = pageModel.items;
//          if (self.updateUI) {
//            self.updateUI();
//          }
//          if (self.endRefreshing) {
//            self.endRefreshing();
//          }
//        });
//      } else {
//        if (self.endRefreshing) {
//          self.endRefreshing();
//        }
//      }
//    } and:^(SearchArtistList * _Nonnull searchArtistListModel, NSError * _Nonnull error) {
//
//    }];
//}


