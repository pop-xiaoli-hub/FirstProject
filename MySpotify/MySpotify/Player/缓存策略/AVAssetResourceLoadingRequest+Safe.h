//
//  AVAssetResourceLoadingRequest+Safe.h
//  GCD
//
//  Created by xiaoli pop on 2026/2/26.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVAssetResourceLoadingRequest (Safe)
@property (atomic, assign) BOOL lz_finished;
@end

NS_ASSUME_NONNULL_END
