//
//  LyricLine.m
//  MySpotify
//

#import "LyricLine.h"

@implementation LyricLine

- (instancetype)initWithTime:(NSTimeInterval)time text:(NSString *)text {
  if (self = [super init]) {
    _time = time;
    _text = text ?: @"";
  }
  return self;
}

+ (NSArray<LyricLine *> *)parseLRCString:(NSString *)lrcString {
  if (!lrcString || lrcString.length == 0) return @[];
  NSMutableArray<LyricLine *> *result = [NSMutableArray array];
  NSArray<NSString *> *lines = [lrcString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
  NSError *err = nil;
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[(\\d{1,2}):(\\d{2})(?:\\.(\\d{2,3}))?\\](.*)" options:0 error:&err];
  if (!regex) return @[];
  for (NSString *line in lines) {
    NSString *trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmed.length == 0) continue;
    NSTextCheckingResult *match = [regex firstMatchInString:trimmed options:0 range:NSMakeRange(0, trimmed.length)];
    if (!match || match.numberOfRanges < 5) continue;
    NSInteger min = [[trimmed substringWithRange:[match rangeAtIndex:1]] integerValue];
    NSInteger sec = [[trimmed substringWithRange:[match rangeAtIndex:2]] integerValue];
    NSString *msStr = [match rangeAtIndex:3].location != NSNotFound ? [trimmed substringWithRange:[match rangeAtIndex:3]] : @"0";
    NSInteger ms = 0;
    if (msStr.length == 3) ms = [msStr integerValue];
    else if (msStr.length >= 2) ms = [[msStr substringToIndex:2] integerValue];
    else if (msStr.length == 1) ms = [msStr integerValue] * 10;
    NSString *text = [match rangeAtIndex:4].location != NSNotFound ? [trimmed substringWithRange:[match rangeAtIndex:4]] : @"";
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSTimeInterval time = min * 60.0 + sec + ms / 1000.0;
    [result addObject:[[LyricLine alloc] initWithTime:time text:text]];
  }
  [result sortUsingComparator:^NSComparisonResult(LyricLine *a, LyricLine *b) {
    if (a.time < b.time) return NSOrderedAscending;
    if (a.time > b.time) return NSOrderedDescending;
    return NSOrderedSame;
  }];
  return [result copy];
}

@end
