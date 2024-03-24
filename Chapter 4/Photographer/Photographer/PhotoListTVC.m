//
//  PhotoListTVC.m
//  Photographer
//
//  Created by Earl Gerald Mendoza on 3/21/24.
//

#import "PhotoListTVC.h"
#import "FlickrFetcher/FlickrFetcher.h"
#import "Model/PhotoData.h"
#import "ImageViewController.h"
#import "Model/RecentPhoto.h"

#define RECENT_PHOTO_KEY @"recent_photo"
#define TIMESTAMP_KEY @"timestamp"

@interface PhotoListTVC()
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation PhotoListTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [[NSString alloc] initWithFormat:@"%@ Photos", self.photographer.name];
    [self fetchPhotographerPhotos];
}


- (NSArray *)arrayOfPhoto
{
    if(!_arrayOfPhoto) {
        _arrayOfPhoto = [[NSArray alloc] init];
    }
    
    return _arrayOfPhoto;
}


- (void)fetchPhotographerPhotos
{
    [self.spinner startAnimating];
    
    NSURL *urlforPhotographersPhotos = [FlickrFetcher URLforImagesFromUserID:self.photographer.userID];
    
    dispatch_queue_t  fetchQ = dispatch_queue_create("fetch_photographer_images", NULL);
    dispatch_async(fetchQ, ^{
        NSData *jsonResults = [NSData dataWithContentsOfURL:urlforPhotographersPhotos];
        if( jsonResults == nil ) {
            return;
        }
        NSDictionary *propertyListResult = [NSJSONSerialization JSONObjectWithData:jsonResults options:0 error:NULL];
        NSArray *photos = [propertyListResult valueForKeyPath:FLICKR_RESULTS_PHOTOS];
        NSMutableArray *newPhotoMutableArray = [[NSMutableArray alloc] init];
        
        for(NSDictionary *photoData in photos) {
            NSDictionary *imageDetails = [PhotoData parseDataToDictionary:photoData];
            [newPhotoMutableArray addObject:imageDetails];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
            self.arrayOfPhoto = newPhotoMutableArray;
            [self.tableView reloadData];
        });
    });
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayOfPhoto count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photo_cell" forIndexPath:indexPath];
    
    // Configure the cell...
    PhotoData *data = [[PhotoData alloc] initWithDictionary:self.arrayOfPhoto[indexPath.row]];
    
    NSString *titleLable = [[NSString alloc] init];
    NSString *descriptionLabel = [[NSString alloc] init];
    
    titleLable = [NSString stringWithFormat:@"%d. %@", (int)(indexPath.row + 1), data.photoTitle];
    descriptionLabel = [ NSString stringWithFormat:@"%@", data.photoDescription];
    
    if([data.photoTitle isEqualToString:@""] || data.photoTitle == nil) {
        titleLable = [NSString stringWithFormat:@"%d. Unknown", (int)indexPath.row + 1];
        descriptionLabel = [NSString stringWithFormat:@""];
    }
    if([data.photoDescription length]) {
        titleLable = [NSString stringWithFormat:@"%d. %@", (int)indexPath.row + 1, data.photoDescription];
    }

    
    cell.textLabel.text = titleLable;
    cell.detailTextLabel.text = descriptionLabel;
    
    return cell;
}

- (void)prepareImageViewController:(ImageViewController *)imageViewController photoToDisplay:(PhotoData *)photo
{
    imageViewController.imageURL = [[NSURL alloc] initWithString:photo.photoUrlLarge];
    imageViewController.title = photo.photoTitle;
    if([photo.photoTitle isEqualToString:@""] || photo.photoTitle == nil) {
        imageViewController.title = @"Unknown";
    }
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if(indexPath) {
            if([segue.identifier isEqualToString:@"dispay_single_photo"]) {
                if([segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
                    NSDictionary *photoInfo = self.arrayOfPhoto[indexPath.row];
                    PhotoData *photoData = [[PhotoData alloc] initWithDictionary:photoInfo];
                    [self addPhotoToRecentTabBar:photoInfo];
                    [self prepareImageViewController:segue.destinationViewController photoToDisplay:photoData];
                }
            }
        }
    }
}



- (void)addPhotoToRecentTabBar:(NSDictionary *)withDictionary
{
    if(![self.title isEqualToString:RECENT_PHOTO_KEY]) {
        
        NSMutableDictionary *newMutableDictionary = [[NSMutableDictionary alloc] initWithDictionary:withDictionary];
        NSMutableArray *recentPhoto = [[NSMutableArray alloc] initWithArray:[PhotoData saveRecentViewedPhoto:RECENT_PHOTO_KEY]];
        NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
        NSNumber *timestampData = [NSNumber numberWithDouble:timestamp];
        [newMutableDictionary setValue:timestampData forKey:TIMESTAMP_KEY];
        
        for(NSDictionary *data in recentPhoto) {
            
            PhotoData *dataToCompare = [[PhotoData alloc] initWithDictionary:data];
            PhotoData *currentData = [[PhotoData alloc] initWithDictionary:newMutableDictionary];
            
            if([dataToCompare.photoID isEqualToString:currentData.photoID]) {
                
                [recentPhoto removeObject:data];
                break;
            }
        }
        
        [recentPhoto addObject:newMutableDictionary];
        [RecentPhoto saveDataWithKey:RECENT_PHOTO_KEY withValue:recentPhoto];
    }
}


@end


