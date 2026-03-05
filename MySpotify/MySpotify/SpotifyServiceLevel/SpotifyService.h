//
//  SpotifyService.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class RecommendedSongsItemModel, SongModel, SongPlayingModel;
@interface SpotifyService : NSObject
@property (nonatomic, copy)NSString* baseUrl;
+ (instancetype)sharedInstance;
- (void)fetchRecommendedSongs:(void(^)(NSArray* arrayOfSongs, NSError* error))completion;
- (void)fetchRecommendedArtists:(void(^)(NSArray* arrayOfArtists, NSError* error))completion;
- (void)fetchRecommendedAlbums:(void(^)(NSArray* arrayOfAlbums, NSError* error))completion;
- (void)fetchCommentsOfSongs:(SongModel* )songModel withCompletion:(void(^)(NSError* error))completion;
- (void)fetchSomeSongsWithIndex:(NSInteger)number withCompletion:(void(^)(NSMutableArray* arrayOfSongs, NSError* error))completion;
- (void)fetchRandomRecommendedPlaylists:(void(^)(NSArray *playlists, NSError *error))completion;
- (void)fetchPlaylistDetailWithId:(NSString *)playlistId completion:(void(^)(id responseObject, NSError *error))completion;
- (void)fetchSongsWithIds:(NSString *)ids completion:(void(^)(NSArray<SongModel *> *songs, NSError *error))completion;
- (void)fetchArtistDetailWithId:(long long)artistId ompletion:(void (^)(id responseObject, NSError *error))completion;
- (void)fetchAllCommentsOfSongs:(SongModel *)songModel offset:(NSInteger)offset limit:(NSInteger)limit withCompletion:(void(^)(id responseObject, NSError *error))completion;
- (void)fetchSongResources:(SongPlayingModel* )model completion:(void(^)( BOOL temp))completion;
- (void)searchSongs:(NSString *)keywords withCompletion:(void(^)(NSArray *songs, NSError *error))completion;
- (void)fetchSongLyrics:(NSString* )songId withCompletion:(void(^)(id responseObject, NSError* error))completion;
@end

NS_ASSUME_NONNULL_END
