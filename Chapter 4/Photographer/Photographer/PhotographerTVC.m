//
//  PhotographerTVC.m
//  Photographer
//
//  Created by Earl Gerald Mendoza on 3/21/24.
//

#import "PhotographerTVC.h"
#import "FlickrFetcher/FlickrFetcher.h"
#import "Model/PhotoData.h"
#import "Model/PhotographerData.h"
#import "PhotoListTVC.h"

@interface PhotographerTVC ()
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end



@implementation PhotographerTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchRecentPhotos];
}



- (void)setPhotographerInfo:(NSArray *)photographerInfo
{
    NSArray *descriptor = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSArray *sortedArray = [photographerInfo sortedArrayUsingDescriptors:descriptor];
    [self sortPhotographerInfoByName:sortedArray];
    _photographerInfo = photographerInfo;
    [self.tableView reloadData];
}



- (void)fetchRecentPhotos
{
    [self.spinner startAnimating];
    NSURL *urlRecentPhotos = [FlickrFetcher URLforRecentPhotos];
    dispatch_queue_t fetchQ = dispatch_queue_create("fetch_photos", NULL);
    dispatch_async(fetchQ, ^{
        NSData *jsonResults = [NSData dataWithContentsOfURL:urlRecentPhotos];
        if( jsonResults == nil ) {
            return;
        }
        NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults options:0 error:NULL];
        NSArray *photos = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PHOTOS];
        NSMutableArray *newPhotoArray = [[NSMutableArray alloc] init];

        for (NSDictionary *photoData in photos) {
            [newPhotoArray addObject:[PhotoData parseDataToDictionary:photoData]];
        }

        [self fetchPhotographerInfo:photos];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = newPhotoArray;
        });
    });
}



- (void)fetchPhotographerInfo:(NSArray *)withPhotos
{
    NSMutableArray *photographerInfoHolder = [[NSMutableArray alloc] init];

    for (NSDictionary *photographerId in withPhotos) {
        NSString *photographerIdString = [[NSString alloc] initWithFormat:@"%@", [photographerId valueForKeyPath:FLICKR_PHOTO_OWNER]];

        NSURL *urlPhotographerInfo = [FlickrFetcher URLforInformationAboutPhotographer:photographerIdString];
        dispatch_queue_t fetchQ = dispatch_queue_create("photographer_fetch", NULL);
        dispatch_async(fetchQ, ^{
            NSData *jsonResults = [NSData dataWithContentsOfURL:urlPhotographerInfo];
            if( jsonResults == nil ) {
                return;
            }
            NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults options:0 error:NULL];
            NSDictionary *data = [PhotographerData parseDataToDictionary:propertyListResults];
            if(data != nil){
                [photographerInfoHolder addObject:data];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if(photographerId == [withPhotos lastObject]) {
                    [self.spinner stopAnimating];
                    self.photographerInfo = photographerInfoHolder;
                }
            });
        });
    }
}


- (void)sortPhotographerInfoByName:(NSArray *)infoList
{
    NSMutableDictionary *photographerHolder = [[NSMutableDictionary alloc] init];
    
    for( NSDictionary *dataResult in infoList ) {
        if( [[PhotographerData getNameFromDictionary:dataResult] isEqualToString:@""] || [PhotographerData getNameFromDictionary:dataResult] == nil ) {
            continue;
        }
        NSString *getFirstLetterOfPhotographerName = [[[PhotographerData getNameFromDictionary:dataResult] uppercaseString] substringToIndex:1];
        if( photographerHolder[getFirstLetterOfPhotographerName] ) {
            NSMutableArray *mutableArrayHolder = [[NSMutableArray alloc] initWithArray:[photographerHolder valueForKey:getFirstLetterOfPhotographerName]];
            [mutableArrayHolder addObject:dataResult];
            [photographerHolder setObject:mutableArrayHolder forKey:getFirstLetterOfPhotographerName];
            continue;
        }
        [photographerHolder setObject:@[dataResult] forKey:getFirstLetterOfPhotographerName];
    }
    
    NSArray *keyHolder = [[photographerHolder allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    NSMutableArray *arrangePhotographerData = [[NSMutableArray alloc] init];
    for( NSString *key in keyHolder ) {
        [arrangePhotographerData addObject:@[key, [photographerHolder objectForKey:key]]];
    }
    self.sortedPhotograherinfoList = arrangePhotographerData;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [self.sortedPhotograherinfoList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [[self.sortedPhotograherinfoList[section] lastObject] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photographer_cell" forIndexPath:indexPath];
    
//     Configure the cell...
    NSArray *photographerList = [self.sortedPhotograherinfoList[indexPath.section] lastObject];
    PhotographerData *photographer = [[PhotographerData alloc] initWithDictionary:photographerList[indexPath.row]];
    
    cell.textLabel.text = photographer.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", photographer.photoCount];
    
    return cell;
}



#pragma mark - Navigation


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *data = [self.sortedPhotograherinfoList[section] firstObject];
    return data;
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender 
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if( [sender isKindOfClass:[UITableViewCell class]] ) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if(indexPath) {
            if([segue.identifier isEqualToString:@"show photo list"]) {
                if([segue.destinationViewController isKindOfClass:[PhotoListTVC class]]) {
                    NSDictionary *photographerInfo = self.sortedPhotograherinfoList[indexPath.section][1][indexPath.row];
                    PhotographerData *data = [[PhotographerData alloc] initWithDictionary:photographerInfo];
                    PhotoListTVC *photoListTVC = (PhotoListTVC *)segue.destinationViewController;
                    photoListTVC.photographer = data;
                }
            }
        }
    }
    
}


@end


