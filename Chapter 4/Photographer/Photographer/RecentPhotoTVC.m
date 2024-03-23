//
//  RecentPhotoTVC.m
//  Photographer
//
//  Created by Earl Gerald Mendoza on 3/21/24.
//

#import "RecentPhotoTVC.h"
#import "Model/PhotoData.h"

#define RECENT_PHOTO_KEY @"recent_photo"


@implementation RecentPhotoTVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = [NSString stringWithFormat:@"Recent Photo"];
    [self fetchPhotographerPhotos];
}



- (void)fetchPhotographerPhotos
{
    self.arrayOfPhoto = @[];
    NSArray *recentPhoto = [PhotoData saveRecentViewedPhoto:RECENT_PHOTO_KEY];
    if(recentPhoto) {
        self.arrayOfPhoto = recentPhoto;
    }
    [self.tableView reloadData];
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


@end
