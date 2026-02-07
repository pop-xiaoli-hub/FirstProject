//
//  NetWorkManager.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/11/17.
//

#import "NetworkManager.h"

static NetworkManager* sharedManager = nil;
@implementation NetworkManager
+ (instancetype)sharedmanager {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedManager = [[super allocWithZone:NULL] init];
  });
  return sharedManager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedManager = [super allocWithZone:zone];
  });
  return sharedManager;
}

- (instancetype)init {
  if (self = [super init]) {
    _sessionManager = [AFHTTPSessionManager manager];
    //_sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    _sessionManager.requestSerializer.timeoutInterval = 15.0;
    _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    _sessionManager.responseSerializer.acceptableContentTypes =  [NSSet setWithObjects:@"application/json", @"text/plain", @"text/html", nil];
  }
  return self;
}


- (void)GET:(NSString *)URLString parameters:(id)parameters headers:(NSDictionary<NSString *,NSString *> *)headers progress:(void (^)(NSProgress * _Nonnull))downloadProgress success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
  [self.sessionManager GET:URLString parameters:parameters headers:headers progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    if (success) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    if (failure) {
      failure(task, error);
    }
  }];
}


- (void)POST:(NSString *)URLString parameters:(id)parameters headers:(NSDictionary<NSString *,NSString *> *)headers progress:(void (^)(NSProgress * _Nonnull))uploadProgress success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
  [self.sessionManager POST:URLString parameters:parameters headers:headers progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    if (success) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    if (failure) {
      failure(task, error);
    }
  }];
}




@end
