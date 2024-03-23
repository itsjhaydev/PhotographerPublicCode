//
//  PhotoData.h
//  Photographer
//
//  Created by Earl Gerald Mendoza on 3/21/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoData : NSObject


@property (nonatomic, strong) NSString *photoTitle;
@property (nonatomic, strong) NSString *photoDescription;
@property (nonatomic, strong) NSString *photoID;
@property (nonatomic, strong) NSString *photoUrlLarge;
@property (nonatomic, strong) NSDate* timeStamp;


- (instancetype) initWithDictionary: (NSDictionary *) withDictionary;
+ (NSDictionary *)parseDataToDictionary: (NSDictionary *)withDictionary;
+ (NSArray*)saveRecentViewedPhoto:(NSString*)key;

@end

NS_ASSUME_NONNULL_END
