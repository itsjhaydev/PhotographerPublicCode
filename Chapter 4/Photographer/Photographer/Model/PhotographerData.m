//
//  PhotographerData.m
//  Photographer
//
//  Created by Earl Gerald Mendoza on 3/21/24.
//

#import "PhotographerData.h"
#import "../FlickrFetcher/FlickrFetcher.h"


#define NAME_KEY @"name"
#define USER_ID_KEY @"userID"
#define PHOTO_COUNT_KEY @"photoCount"

@interface PhotographerData()
@property (nonatomic, readwrite) NSInteger photoCount;
@end


@implementation PhotographerData

- (void)setPhotoCount:(NSInteger)photoCount
{
    _photoCount = photoCount;
}


- (instancetype) initWithDictionary: (NSDictionary*) withDictionary
{
    self = [super init];
    
    if (self) {
        _name       = [withDictionary valueForKeyPath:NAME_KEY];
        _photoCount = [[withDictionary valueForKeyPath:PHOTO_COUNT_KEY] intValue];
        _userID     = [withDictionary valueForKeyPath:USER_ID_KEY];
    }
    return self;
}



+ (NSDictionary *) parseDataToDictionary: (NSDictionary*) withDictionary
{
    NSString *photographerName = [withDictionary valueForKeyPath:FLICKR_OWNER_NAME];
    NSNumber *photographerPhotoCount = [withDictionary valueForKeyPath:FLICKR_OWNER_PHOTOS_COUNT];
    NSString *photographerUserID = [withDictionary valueForKeyPath:FLICKR_OWNER_ID];
    
    NSDictionary *photographerInfo = @{
        @"name": photographerName ? photographerName : @"",
        @"userID": photographerUserID ? photographerUserID : @"",
        @"photoCount": photographerPhotoCount ? photographerPhotoCount : @""
    };
    return photographerInfo;
}



+ (NSString *)getNameFromDictionary:(NSDictionary *)withDictionary
{
    NSString *stringName = [withDictionary valueForKeyPath:NAME_KEY];
    return stringName;
}





@end





