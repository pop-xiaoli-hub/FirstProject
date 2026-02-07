//
//  AlbumModel.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/8.
//
#import "AlbumModel.h"
#import <YYModel/YYModel.h>

@implementation AlbumModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"albumId": @"id", @"descriptionText": @"description"};
}


@end
