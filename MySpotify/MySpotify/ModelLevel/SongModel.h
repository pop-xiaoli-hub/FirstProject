//
//  SongModel.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/8.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

@class ArtistModel, AlbumModel, CommentModel;

NS_ASSUME_NONNULL_BEGIN

@interface SongModel : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) long long id;
@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, strong) NSArray<ArtistModel *> *artists;
@property (nonatomic, strong) AlbumModel *album;
@property (nonatomic, strong)UIImage* image;
@property (nonatomic, strong)NSString* audioResources;
@property (nonatomic, strong)CommentModel* comments;
@property (nonatomic, assign) BOOL isFetchingComments;
@property (nonatomic, assign) BOOL isLiked;
@property (nonatomic, strong) NSArray<ArtistModel *> *ar;
@property (nonatomic, copy) NSString* picUrl;
@property (nonatomic, copy) NSString* artistName;
@end

NS_ASSUME_NONNULL_END
