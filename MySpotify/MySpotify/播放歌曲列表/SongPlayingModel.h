//
//  SongPlayingModel.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SongPlayingModel : NSObject
@property(nonatomic, assign)long songId;
@property (nonatomic, copy)NSString* artistName;
@property (nonatomic, copy)NSString* headerUrl;
@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSString* audioResources;
@property (nonatomic, assign)BOOL isDownload;
- (instancetype)initWithSongName:(NSString* )songName andArtistName:(NSString* )artistName andSongId:(long)id andPicUrl:(NSString* )picUrl andMusicSource:(NSString* )resource andIsDownloaded:(BOOL)isDownload;
@end

NS_ASSUME_NONNULL_END
