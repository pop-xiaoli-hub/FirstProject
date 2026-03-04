/*
 将真实音频URL和提供给AVPlayer的自定义URL做映射，让AVPlayer走自定义的缓存逻辑
 内部维持一个_urlMap：键：songID 值：真实URL、还维持着一个串行队列，避免并发问题，所有对map的读写都发生在这个串行队列中
 */

#import "LZStreamingURLBuilder.h"

static NSMutableDictionary<NSString *, NSURL *> *_urlMap;
static dispatch_queue_t _urlMapQueue;

@implementation LZStreamingURLBuilder

+ (void)initialize {
  if (self == [LZStreamingURLBuilder class]) {
    _urlMap = [NSMutableDictionary dictionary];
    _urlMapQueue = dispatch_queue_create("com.lz.streamingurl.map", DISPATCH_QUEUE_SERIAL);
  }
}

+ (NSURL *)buildStreamingURL:(NSURL *)url {
  NSString *s = url.absoluteString;
  s = [s stringByReplacingOccurrencesOfString:@"https://" withString:@"streaming://"];
  s = [s stringByReplacingOccurrencesOfString:@"http://" withString:@"streaming://"];
  return [NSURL URLWithString:s];
}

+ (NSURL *)realURL:(NSURL *)url {
  NSString *s = url.absoluteString;
  s = [s stringByReplacingOccurrencesOfString:@"streaming://" withString:@"https://"];
  return [NSURL URLWithString:s];
}

+ (NSURL *)buildStreamingURLWithSongId:(long)songId realURL:(NSURL *)url {
  if (!url) {
    return nil;
  }
  NSString *key = [NSString stringWithFormat:@"%ld", songId];
  dispatch_sync(_urlMapQueue, ^{
    _urlMap[key] = url;
  });
  NSString *streaming = [NSString stringWithFormat:@"streaming://%ld", songId];
  return [NSURL URLWithString:streaming];
}

+ (NSURL *)realURLForStreamingURL:(NSURL *)streamingURL {
  if (!streamingURL || ![streamingURL.scheme isEqualToString:@"streaming"]) {
    return nil;
  }
  NSString *key = streamingURL.host;
  if (!key.length) return nil;
  __block NSURL *res = nil;
  dispatch_sync(_urlMapQueue, ^{
    res = _urlMap[key];
  });
  return res;
}

@end
