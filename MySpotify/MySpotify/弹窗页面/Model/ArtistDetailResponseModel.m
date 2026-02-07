//
//  ArtistDetailResponseModel.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/23.
//

#import "ArtistDetailResponseModel.h"
#import "SongModel.h"
@implementation ArtistDetailResponseModel
+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
  return @{
    @"hotSongs" : [SongModel class]
  };
}
@end
