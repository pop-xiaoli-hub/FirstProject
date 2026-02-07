//
//  CommentListResponseModel.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/21.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>
NS_ASSUME_NONNULL_BEGIN
@class CommentModel;
@interface CommentListResponseModel : NSObject<YYModel>
@property (nonatomic, strong) NSArray<CommentModel *> *comments;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) BOOL more;
@property (nonatomic, assign) NSInteger code;
@end

NS_ASSUME_NONNULL_END
