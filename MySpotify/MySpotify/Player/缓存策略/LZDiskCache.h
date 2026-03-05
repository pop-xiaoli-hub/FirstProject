//
//  DiskCache.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/24.
//
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface LZDiskCache : NSObject
+ (instancetype)sharedInstance;
/// 某 key 对应的磁盘缓存文件完整路径
- (NSString *)filePath:(NSString *)key;
- (NSData *)readDataForKey:(NSString *)key offset:(NSUInteger)offset length:(NSUInteger)length;
- (void)writeData:(NSData *)data offset:(NSUInteger)offset key:(NSString *)key;
/// 带完成回调的写盘，completion 在 ioQueue 上执行；传 nil 则行为同 writeData:offset:key:
- (void)writeData:(NSData *)data offset:(NSUInteger)offset key:(NSString *)key completion:(void (^ _Nullable)(void))completion;
@end
NS_ASSUME_NONNULL_END
