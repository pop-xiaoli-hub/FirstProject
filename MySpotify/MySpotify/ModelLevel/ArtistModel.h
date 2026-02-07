//
//  ArtistModel.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/8.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
NS_ASSUME_NONNULL_BEGIN

@interface ArtistModel : NSObject
@property (nonatomic, assign) long long id;
@property (nonatomic, copy)NSString* name;
@property (nonatomic, copy)NSString* img1v1Url;
@property (nonatomic, copy)NSString* picUrl;
@property (nonatomic, strong)UIImage* image;
@property (nonatomic, copy)NSString* briefDesc;
- (NSString *)webUrl;
@end

NS_ASSUME_NONNULL_END
