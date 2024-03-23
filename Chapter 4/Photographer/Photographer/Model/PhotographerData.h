//
//  PhotographerData.h
//  Photographer
//
//  Created by Earl Gerald Mendoza on 3/21/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotographerData : NSObject

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* userID;
@property (nonatomic, readonly) NSInteger photoCount;

- (instancetype) initWithDictionary: (NSDictionary*) withDictionary;
+ (NSDictionary *) parseDataToDictionary: (NSDictionary*) withDictionary;
+ (NSString *) getNameFromDictionary: (NSDictionary*) withDictionary;

@end

NS_ASSUME_NONNULL_END







