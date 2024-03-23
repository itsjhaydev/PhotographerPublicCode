//
//  RecentPhoto.m
//  Photographer
//
//  Created by Earl Gerald Mendoza on 3/21/24.
//

#import "RecentPhoto.h"

@implementation RecentPhoto

+ (void)saveDataWithKey:(NSString *)key withValue:(id)withValue
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
    [defaults setValue:withValue forKey:key];
}

+ (id)getData:(NSString*)key 
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
    return [defaults arrayForKey:key];
}


@end
