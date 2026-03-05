//
//  LyricLine.h
//  MySpotify
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LyricLine : NSObject
@property (nonatomic, assign) NSTimeInterval time;
@property (nonatomic, copy) NSString *text;

- (instancetype)initWithTime:(NSTimeInterval)time text:(NSString *)text;
+ (NSArray<LyricLine *> *)parseLRCString:(NSString *)lrcString;
@end

NS_ASSUME_NONNULL_END
