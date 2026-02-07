//
//  ArtistModel.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/8.
//
#import "ArtistModel.h"
#import <YYModel/YYModel.h>

@implementation ArtistModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"artistId": @"id"};
}

- (NSString *)webUrl {
    return [NSString stringWithFormat:@"https://music.163.com/#/artist?id=%lld", self.id];
}

@end
