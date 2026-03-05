//
//  ResourceLoader.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/24.
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVFoundation.h"
NS_ASSUME_NONNULL_BEGIN

@interface LZResourceLoader : NSObject<AVAssetResourceLoaderDelegate>
/// 单例，供 MusicPlayerManager 等设置到 AVURLAsset.resourceLoader
+ (instancetype)sharedLoader;
@end

NS_ASSUME_NONNULL_END
