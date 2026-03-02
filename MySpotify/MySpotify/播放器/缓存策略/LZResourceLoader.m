//
//  ResourceLoader.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/24.
//

#import "LZResourceLoader.h"
#import "LZCacheRouter.h"
#import "LZStreamingURLBuilder.h"
#import <AVFoundation/AVFoundation.h>

@interface LZResourceLoader()
@property LZCacheRouter *router;
@end

@implementation LZResourceLoader

- (instancetype)init {
  NSLog(@"当前执行：%s",__func__);
  if(self = [super init]){
    self.router = [LZCacheRouter new];
  }
  return self;
}

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
  NSLog(@"当前执行：%s",__func__);
  NSURL *streamingURL = loadingRequest.request.URL;
  NSURL *realURL = [LZStreamingURLBuilder realURL:streamingURL];
  NSString *key = realURL.absoluteString;
  long long offset = loadingRequest.dataRequest.requestedOffset;
  NSUInteger length = loadingRequest.dataRequest.requestedLength;
  
  if (loadingRequest.contentInformationRequest) {
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    loadingRequest.contentInformationRequest.contentType = AVFileTypeMPEGLayer3;
    loadingRequest.contentInformationRequest.contentLength = 100000000;
  }
  NSLog(@"loading offset:%lld length:%lu", offset, (unsigned long)length);
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
