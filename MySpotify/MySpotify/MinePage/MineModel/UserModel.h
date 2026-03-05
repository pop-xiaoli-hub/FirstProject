//
//  UserModel.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface UserModel : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic, assign) BOOL isVIP;
@end

NS_ASSUME_NONNULL_END
