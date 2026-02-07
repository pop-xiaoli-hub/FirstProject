//
//  SongModel.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/8.
//

#import "SongModel.h"
#import "ArtistModel.h"
#import "AlbumModel.h"
#import <YYModel/YYModel.h>
#
@implementation SongModel


+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
      @"artists" : [ArtistModel class],
      @"album" : [AlbumModel class],
      @"ar" : [ArtistModel class]
    };
}
@end
