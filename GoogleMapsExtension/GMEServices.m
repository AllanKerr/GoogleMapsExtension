//
//  GMEServices.m
//  NearMe
//
//  Created by Allan Kerr on 2016-06-09.
//  Copyright © 2016 Allan Kerr. All rights reserved.
//

#import "GMEServices.h"

static NSString *GMEAPIKey;

@interface GMEServices (Private)
+ (NSString *)APIKey;
@end

@implementation GMEServices

+ (NSString *)APIKey {
    return GMEAPIKey;
}

+ (BOOL)provideAPIKey:(NSString *)APIKey {
    GMEAPIKey = APIKey;
    return YES;
}

@end
