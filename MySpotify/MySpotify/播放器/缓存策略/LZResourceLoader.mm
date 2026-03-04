//
//  ResourceLoader.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/24.
//

#import "LZResourceLoader.h"
#import "LZCacheRouter.h"
#import "LZStreamingURLBuilder.h"
#import "DBManager.h"
#import "SongDBModel.h"
#import "SongDBModel+WCTTableCoding.h"
#import <AVFoundation/AVFoundation.h>

@interface LZResourceLoader()
@property LZCacheRouter *router;
@end

@implementation LZResourceLoader

+ (instancetype)sharedLoader {
  static LZResourceLoader *loader;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    loader = [[LZResourceLoader alloc] init];
  });
  return loader;
}

- (instancetype)init {
  if (self = [super init]) {
    self.router = [LZCacheRouter new];
  }
  return self;
}

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
  NSLog(@"avplayer fetch");
  NSURL *streamingURL = loadingRequest.request.URL;
  NSString *key = nil;
  if ([streamingURL.scheme isEqualToString:@"streaming"] && streamingURL.host.length > 0) {
    key = streamingURL.host;//歌曲id，具体streamUrl的组成结构在LZStreamingURLBuilder可见
  }
  if (!key.length) {
    NSURL *realURL = [LZStreamingURLBuilder realURL:streamingURL];
    key = realURL.absoluteString;
  }
  NSURL *realURL = [LZStreamingURLBuilder realURLForStreamingURL:streamingURL];
    if (!realURL && key.length > 0) {//如果realURL非法，那就从数据库中读取
      long long sid = [key longLongValue];
      if (sid > 0) {
        SongDBModel *model = [[DBManager shared] querySongWithSongId:(long)sid];
        if (model.url.length > 0) {
          realURL = [NSURL URLWithString:model.url];
        }
      }
    }
  if (!realURL) {
    realURL = [LZStreamingURLBuilder realURL:streamingURL];
  }
  if (!realURL || !key.length) {
    return NO;
  }
  long long offset = loadingRequest.dataRequest.requestedOffset;
  NSUInteger length = loadingRequest.dataRequest.requestedLength;

  if (loadingRequest.contentInformationRequest) {
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    loadingRequest.contentInformationRequest.contentType = AVFileTypeMPEGLayer3;
    loadingRequest.contentInformationRequest.contentLength = 100000000;
  }
  [self.router getDataForKey:key url:realURL offset:(NSUInteger)offset length:length completion:^(NSData *data, NSError *error) {
    if (data.length > 0) {
      [loadingRequest.dataRequest respondWithData:data];
      [loadingRequest finishLoading];
    } else {
      [loadingRequest finishLoadingWithError:error];
    }
  }];
  return YES;
}

@end
