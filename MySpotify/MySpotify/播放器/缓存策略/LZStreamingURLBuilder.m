#import "LZStreamingURLBuilder.h"

@implementation LZStreamingURLBuilder

+ (NSURL *)buildStreamingURL:(NSURL *)url {
  NSLog(@"当前执行：%s",__func__);
  NSString *s = url.absoluteString;
  s = [s stringByReplacingOccurrencesOfString:@"https://" withString:@"streaming://"];
  s = [s stringByReplacingOccurrencesOfString:@"http://" withString:@"streaming://"];
  return [NSURL URLWithString:s];
}

+ (NSURL *)realURL:(NSURL *)url {
  NSLog(@"当前执行：%s",__func__);
  NSString *s = url.absoluteString;
  s = [s stringByReplacingOccurrencesOfString:@"streaming://" withString:@"https://"];
  return [NSURL URLWithString:s];
}

@end
