//
//  ZLCommentResponseModel.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/28.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>
@class ZLCommentModel;
NS_ASSUME_NONNULL_BEGIN

@interface ZLCommentResponseModel : NSObject<YYModel>
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) BOOL more;

@property (nonatomic, strong) NSArray<ZLCommentModel *> *hotComments;
@property (nonatomic, strong) NSArray<ZLCommentModel *> *comments;
@end

NS_ASSUME_NONNULL_END
