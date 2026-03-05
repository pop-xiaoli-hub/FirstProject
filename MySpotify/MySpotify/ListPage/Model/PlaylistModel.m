//
//  PlaylistModel.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/21.
//

#import "PlaylistModel.h"
#import "SongModel.h"
#import "PlaylistCreatorModel.h"
#import "TracksIDModel.h"
@implementation PlaylistModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"tracks": [SongModel class],
        @"creator": [PlaylistCreatorModel class],
        @"desc": @"description",
        @"trackIds" : [TracksIDModel class]

    };
}
@end
