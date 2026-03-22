//
//  LZIdleTaskQueue.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/3/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^IdleTask) (void);
@interface LZIdleTaskQueue : NSObject
- (void)addTask:(IdleTask)task;
- (void)start;
- (void)stop;
@end

NS_ASSUME_NONNULL_END
