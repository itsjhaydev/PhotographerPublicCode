//
//  PhotoData.m
//  Photographer
//
//  Created by Earl Gerald Mendoza on 3/21/24.
//

#import "PhotoData.h"
#import "../FlickrFetcher/FlickrFetcher.h"
#import "RecentPhoto.h"


#define TITLE_KEY @"title"
#define DESCRIPTION_KEY @"description"
#define PHOTO_ID_KEY @"photoID"
#define PHOTO_URL_LARGE_KEY @"photoUrlLarge"
#define ID_KEY @"id"
#define TIMESTAMP_KEY @"timestamp"


@implementation PhotoData


- (instancetype)initWithDictionary:(NSDictionary *)withDictionary
{
    self = [super init];
    
    if (self) {
        
        NSString *photoTitle       =    [withDictionary valueForKeyPath:TITLE_KEY];
        NSString *photoDescription =    [withDictionary valueForKeyPath:DESCRIPTION_KEY];
        NSString *photoID          =    [withDictionary valueForKeyPath:PHOTO_ID_KEY];
        NSString *photoURLLarge    =    [withDictionary valueForKeyPath:PHOTO_URL_LARGE_KEY];
        self.photoTitle            = photoTitle;
        self.photoDescription      = photoDescription;
        self.photoID               = photoID;
        self.photoUrlLarge         = photoURLLarge;
        self.timeStamp             = [[NSDate alloc] init];
    }
    return self;
}



+ (NSDictionary *)parseDataToDictionary:(NSDictionary *)withDictionary
{
    NSString *photoTitle = [withDictionary valueForKeyPath:TITLE_KEY];
    NSString *photoDescription = [withDictionary valueForKeyPath:DESCRIPTION_KEY];
    NSString *photoID = [withDictionary valueForKeyPath:ID_KEY];
    NSURL *photosURLLarge = [FlickrFetcher URLforPhoto:withDictionary format:FlickrPhotoFormatLarge];
    
    NSDictionary* photoDetails = @{
        @"title": photoTitle ? photoTitle : @"",
        @"description": photoDescription ? photoDescription : @"",
        @"photoID": photoID ? photoID : @"",
        @"photoUrlLarge": photosURLLarge ? [photosURLLarge absoluteString] : @"",
        @"timestamp": @""
    };
    
    return photoDetails;
}


+ (NSArray*)saveRecentViewedPhoto:(NSString*)key
{
    NSArray* recentViewedPhotos = [RecentPhoto getData:key];
    NSMutableArray *recentPhotoHolder = [[NSMutableArray alloc] init];
    for (NSDictionary *data in recentViewedPhotos) {
        [recentPhotoHolder addObject:data];
    }

    if([recentPhotoHolder count] > 20) {
        [recentPhotoHolder removeObject:[recentPhotoHolder firstObject]];
    }

    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:TIMESTAMP_KEY  ascending:YES];
    NSMutableArray *sortDescriptor = [[NSMutableArray alloc] initWithArray: @[descriptor]];
    NSArray *sortedData = [recentPhotoHolder sortedArrayUsingDescriptors:sortDescriptor];

    return sortedData;
}



@end
