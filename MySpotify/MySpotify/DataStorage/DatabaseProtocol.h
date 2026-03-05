//
//  DatabaseProtocal.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DatabaseProtocol <NSObject>
- (NSString*)tableName;
- (NSString*)primaryKey;
- (long)primaryKeyValue;
@end

NS_ASSUME_NONNULL_END
