//
//  SpotifyService.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/8.
//

// NSString* url = [NSString stringWithFormat: @"http://localhost:3000/song/url/v1?id=%ld&level=standard", model.songId];

#import "SpotifyService.h"
#import "NetworkManager.h"
#import <YYModel.h>
#import "RecommendedSongsItemModel.h"
#import "RecommendationsResponseModel.h"
#import "RecommendationsOfArtistsModel.h"
#import "Songmodel.h"
#import "AlbumModel.h"
#import "SDWebImageManager.h"
#import "ArtistModel.h"
#import "RecommendationsOfCategoryModel.h"
#import "CategoryModel.h"
#import "RecommendationsOfAlbumsModel.h"
#import "CommentListResponseModel.h"
#import "CommentModel.h"
#import "CommentUserModel.h"
#import "SongDBModel.h"
#import "SongDBModel+WCTTableCoding.h"
#import "SongPlayingModel.h"
@implementation SpotifyService

+(instancetype)sharedInstance {
  static SpotifyService* service;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    service = [[self alloc] init];
    service.baseUrl = @"https://1390963969-2g6ivueiij.ap-guangzhou.tencentscf.com";
    //service.baseUrl = @"http://localhost:3000";
  });
  return service;
}

- (void)fetchImageWithURL:(NSString* )urlString completion:(void(^)(UIImage* image))completion {
  if (!urlString) {
    if (completion) {
      completion(nil);
    }
    return;
  }
  NSURL* url = [NSURL URLWithString:urlString];
  SDWebImageManager* manager = [SDWebImageManager sharedManager];
  [manager loadImageWithURL:url options:SDWebImageHighPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
    if (completion) {
      completion(image);
    }
  }];
}

- (void)fetchSongResources:(SongPlayingModel* )model completion:(void(^)( BOOL temp))completion {
  NetworkManager* manager = [NetworkManager sharedmanager];
  manager.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
  NSString* url = [NSString stringWithFormat: @"%@/song/url/v1?id=%ld&level=standard",self.baseUrl, model.songId];
  [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
    NSArray *dataArray = responseObject[@"data"];
    if (dataArray.count > 0) {
      NSDictionary *songDict = dataArray[0];
      NSString *url = songDict[@"url"];
      model.audioResources = [url copy];
    }
    completion(YES);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    completion(NO);
    NSLog(@"申请歌曲详细资源出错：%@", error);
  }];
}


- (void)fetchRecommendedArtists:(void(^)(NSArray* arrayOfArtists, NSError* error))completion {
  NetworkManager* manager = [NetworkManager sharedmanager];
  manager.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
  int keyNumber = arc4random_uniform(200);
  NSString* urlString = [NSString stringWithFormat:@"%@/artist/list?area=-1&type=-1&offset=%d&limit=8", self.baseUrl, keyNumber];
  [manager GET:urlString parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
    RecommendationsOfArtistsModel* responseModel = [RecommendationsOfArtistsModel yy_modelWithJSON:responseObject];
    NSArray* array = responseModel.artists;
    completion(array, nil);
    NSLog(@"随机歌手数据：%@", responseObject);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    NSLog(@"申请随机歌手出错：%@", error);
    completion(nil, error);
  }];
}

- (void)fetchRecommendedAlbums:(void(^)(NSArray* arrayOfAlbums, NSError* error))completion {
  NetworkManager* manager = [NetworkManager sharedmanager];
  manager.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
  int num = arc4random_uniform(50);
  NSString *urlString = [NSString stringWithFormat:@"%@/top/playlist?offset=%d&limit=8", self.baseUrl, num];
  [manager GET:urlString parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
    NSLog(@"专辑%@",responseObject);
    RecommendationsOfAlbumsModel* responseModel = [RecommendationsOfAlbumsModel yy_modelWithJSON:responseObject];
    NSArray* albumsArray = responseModel.playlists;
    for (AlbumModel* model in albumsArray) {
      NSLog(@"专辑名称 %@， 专辑图片 %@", model.name, model.coverImgUrl);
    }
    completion(albumsArray, nil);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    completion(nil, error);
  }];
}

- (void)fetchRecommendedSongs:(void(^)(NSArray* arrayOfSongs, NSError* error))completion {
  NetworkManager* manager = [NetworkManager sharedmanager];
  manager.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
  NSString *url = [NSString stringWithFormat:@"%@/personalized/newsong?limit=30", self.baseUrl];
  [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
    RecommendationsResponseModel *responseModel =
    [RecommendationsResponseModel yy_modelWithJSON:responseObject];
    NSArray *allItems = responseModel.result;
    if (allItems.count == 0) {
      completion(@[], nil);
      return;
    }
    NSMutableArray *shuffled = [allItems mutableCopy];
    for (NSInteger i = shuffled.count - 1; i > 0; i--) {
      NSInteger j = arc4random_uniform((uint32_t)(i + 1));
      [shuffled exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
    NSInteger count = MIN(8, shuffled.count);
    NSArray *randomItems = [shuffled subarrayWithRange:NSMakeRange(0, count)];

    for (RecommendedSongsItemModel *item in randomItems) {
      SongModel *model = item.song;
      [self fetchSongResources:model];
    }
    completion(randomItems, nil);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    completion(nil, error);
  }];
}

- (void)fetchSomeSongsWithIndex:(NSInteger)number withCompletion:(void(^)(NSMutableArray* arrayOfSongs, NSError* error))completion {
  NetworkManager* manager = [NetworkManager sharedmanager];
  manager.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
  //NSString *url = @"http://localhost:3000/personalized/newsong?limit=30";
  NSString* url = [NSString stringWithFormat:@"%@/personalized/newsong?limit=%ld", self.baseUrl, number];
  //  NSString* url = [NSString stringWithFormat:@"http://localhost:3000/playlist/track/all?id=2884035&limit=%ld", number];
  [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
    RecommendationsResponseModel *responseModel =
    [RecommendationsResponseModel yy_modelWithJSON:responseObject];
    NSArray *allItems = responseModel.result;
    NSMutableArray* mutableArray = [NSMutableArray arrayWithArray:allItems];
    completion(mutableArray, nil);
    for (RecommendedSongsItemModel* item in allItems) {
      SongModel* songModel = item.song;
      songModel.isLiked = NO;
      AlbumModel* albumModel = songModel.album;
      // [self fetchCommentsOfSongs:songModel];
      NSLog(@"瀑布流歌曲名称:%@, 封面图：%@", songModel.name, albumModel.picUrl);
    }
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    completion(nil, error);
  }];
}



- (void)fetchSongResources:(SongModel* )model {
  NetworkManager* manager = [NetworkManager sharedmanager];
  manager.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
  NSString* url = [NSString stringWithFormat: @"%@/song/url/v1?id=%lld&level=standard", self.baseUrl, model.id];
  [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
    NSArray *dataArray = responseObject[@"data"];
    if (dataArray.count > 0) {
      NSDictionary *songDict = dataArray[0];
      NSString *url = songDict[@"url"];       // 访问字典字段
      //  NSLog(@"播放 URL = %@", url);
      model.audioResources = [url copy];
    }
    // NSLog(@"歌曲详细资源：%@", responseObject);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    NSLog(@"申请歌曲详细资源出错：%@", error);
  }];
}

-  (void)fetchCommentsOfSongs:(SongModel* )songModel withCompletion:(void(^)(NSError* error))completion {
  NetworkManager* manager = [NetworkManager sharedmanager];
  manager.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
  NSString* url = [NSString stringWithFormat:@"%@/comment/music?id=%lld&limit=1", self.baseUrl, songModel.id];
  [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
    CommentListResponseModel* responseModel = [CommentListResponseModel yy_modelWithJSON:responseObject];
    CommentModel* model = responseModel.comments.firstObject;
    CommentUserModel* user= model.user;
    songModel.comments = model;
    //NSLog(@"歌曲评论属性添加成功:%@", songModel.comments.content);
    NSLog(@"评论：%@，用户： %@, 头像：%@", model.content, user.nickname, user.avatarUrl);
    //  NSLog(@"评论区：%@", responseObject);
    completion(nil);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    NSLog(@"平路区获取失败：%@", error);
    completion(error);
  }];
}


- (void)fetchRandomRecommendedPlaylists:(void(^)(NSArray *playlists, NSError *error))completion {

  NetworkManager *manager = [NetworkManager sharedmanager];
  manager.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];

  int limit = 6;
  int randomOffset = arc4random_uniform(30);

  NSString *urlString = [NSString stringWithFormat: @"%@/personalized?limit=%d&offset=%d", self.baseUrl, limit, randomOffset];

  [manager GET:urlString parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    //    NSLog(@"歌单%@", responseObject);
    RecommendationsOfCategoryModel* responseModel = [RecommendationsOfCategoryModel yy_modelWithJSON:responseObject];
    NSArray<CategoryModel* >* array = responseModel.result;
    for (CategoryModel* model in array) {
      NSLog(@"歌单名：%@", [model.name copy]);
    }
    if (completion) {
      completion(array, nil);
    }

  } failure:^(NSURLSessionDataTask *task, NSError *error) {

    NSLog(@"获取随机歌单失败：%@", error);
    if (completion) {
      completion(nil, error);
    }
  }];
}



- (void)searchDataWithKeywords:(NSString* ) str withCompletion:(void(^)(id object, NSError* error))completion {
  NetworkManager *manager = [NetworkManager sharedmanager];
  manager.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];

  NSString *url = [NSString stringWithFormat:@"%@/search", self.baseUrl];
  NSDictionary *params = @{
    @"keywords": str,
    @"type": @(1),
    @"limit": @(20)
  };

  [manager GET:url parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    NSLog(@"%@", responseObject);
    NSArray *songs = responseObject[@"result"][@"songs"];
    completion(songs, nil);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    NSLog(@"%@", error);
    completion(nil, error);
  }];
}


- (void)fetchPlaylistDetailWithId:(NSString *)playlistId completion:(void(^)(id responseObject, NSError *error))completion {
  NetworkManager *manager = [NetworkManager sharedmanager];
  manager.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
  NSString *url = [NSString stringWithFormat:@"%@/playlist/detail", self.baseUrl];
  NSDictionary *params = @{
    @"id": playlistId
  };

  [manager GET:url parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    if (completion) {
      completion(responseObject, nil);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    if (completion) {
      completion(nil, error);
    }
  }];
}

- (void)fetchSongsWithIds:(NSString *)ids completion:(void(^)(NSArray<SongModel *> *songs, NSError *error))completion {
  if (ids.length == 0) {
    if (completion) {
      completion(@[], nil);
    }
    return;
  }
  NetworkManager *manager = [NetworkManager sharedmanager];
  manager.sessionManager.requestSerializer =
  [AFJSONRequestSerializer serializer];
  NSString *url = [NSString stringWithFormat:@"%@/song/detail", self.baseUrl];
  NSDictionary *params = @{ @"ids" : ids };
  [manager GET:url parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    NSArray *songsJSON = responseObject[@"songs"];
    NSArray<SongModel *> *songs = [NSArray yy_modelArrayWithClass:[SongModel class] json:songsJSON];
    if (completion) {
      completion(songs, nil);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    if (completion) {
      completion(nil, error);
    }
  }];
}

- (void)fetchArtistDetailWithId:(long long)artistId ompletion:(void (^)(id responseObject, NSError *error))completion {

  NetworkManager *manager = [NetworkManager sharedmanager];
  manager.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
  NSString *url = [NSString stringWithFormat:@"%@/artists", self.baseUrl];
  NSDictionary *params = @{
    @"id" : @(artistId)
  };

  [manager GET:url parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    if (completion) {
      completion(responseObject, nil);
    }

  } failure:^(NSURLSessionDataTask *task, NSError *error) {

    if (completion) {
      completion(nil, error);
    }
  }];
}

- (void)fetchAllCommentsOfSongs:(SongModel *)songModel offset:(NSInteger)offset limit:(NSInteger)limit withCompletion:(void(^)(id responseObject, NSError *error))completion {
  NetworkManager *manager = [NetworkManager sharedmanager];
  manager.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
  NSString *url = [NSString stringWithFormat:@"%@/comment/music?id=%lld&limit=%ld&offset=%ld", self.baseUrl, songModel.id, (long)limit, (long)offset];

  [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    completion(responseObject, nil);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    NSLog(@"评论获取失败：%@", error);
    completion(nil, error);
  }];
}

- (void)fetchSongLyrics:(NSString* )songId withCompletion:(void(^)(id responseObject, NSError* error))completion {
  NetworkManager* manager = [NetworkManager sharedmanager];
  long long songid = [songId integerValue];
  manager.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
  NSString* url = [NSString stringWithFormat:@"%@/lyric?id=%lld",self.baseUrl, songid];
  [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
      completion(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
      completion(nil, error);
    }];
}

- (void)searchSongs:(NSString *)keywords withCompletion:(void(^)(NSArray *songs, NSError *error))completion {
  NetworkManager *manager = [NetworkManager sharedmanager];
  manager.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
  NSString *url = [NSString stringWithFormat:@"%@/search", self.baseUrl];
  NSDictionary *params = @{
    @"keywords": keywords,
    @"type": @(1),
    @"limit": @(20),
    @"offset": @(0)
  };
  [manager GET:url parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
   // NSArray *songs = responseObject[@"result"][@"songs"];
    NSArray *songsJSON = responseObject[@"result"][@"songs"];
    NSArray<SongModel *> *songs = [NSArray yy_modelArrayWithClass:[SongModel class] json:songsJSON];
    if (completion) {
      completion(songs, nil);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    if (completion) {
      completion(nil, error);
    }
  }];
}


@end

