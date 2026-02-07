//
//  AlbumModel.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlbumModel : NSObject
@property (nonatomic, assign) long long id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *picUrl; 
@property (nonatomic, copy) NSString *company;
@property (nonatomic, assign) long long publishTime;
@property (nonatomic, copy)NSString* coverImgUrl;
@end

NS_ASSUME_NONNULL_END
