//
//  NetWorkManager.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/11/17.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
NS_ASSUME_NONNULL_BEGIN

@interface NetworkManager : NSObject
@property (nonatomic, strong)AFHTTPSessionManager* sessionManager;
+ (instancetype)sharedmanager;


- (void)GET:(NSString* )URLString parameters:(nullable id)parameters headers:(nullable NSDictionary<NSString *,NSString *> *)headers progress:(nullable void (^)(NSProgress * _Nonnull))downloadProgress success:(nullable void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure;
- (void)POST:(NSString* )URLString parameters:(nullable id)parameters headers:(nullable NSDictionary<NSString *,NSString *> *)headers progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress success:(nullable void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure;
@end

NS_ASSUME_NONNULL_END
