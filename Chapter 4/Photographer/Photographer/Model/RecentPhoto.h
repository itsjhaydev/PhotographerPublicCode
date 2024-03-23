//
//  RecentPhoto.h
//  Photographer
//
//  Created by Earl Gerald Mendoza on 3/21/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecentPhoto : NSObject

+ (void)saveDataWithKey:(NSString *)key withValue:(id)withValue;
+ (id)getData:(NSString*)key;


@end

NS_ASSUME_NONNULL_END
