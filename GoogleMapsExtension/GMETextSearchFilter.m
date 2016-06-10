//
//  GMETextSearchFilter.m
//  NearMe
//
//  Created by Allan Kerr on 2016-06-09.
//  Copyright © 2016 Allan Kerr. All rights reserved.
//

#import "GMETextSearchFilter.h"

NSString *const kGMETextSearchFilterComponentLocation   = @"location";  //location=52.1332,-106.6700
NSString *const kGMETextSearchFilterComponentRadius     = @"radius";    //radius=50000
NSString *const kGMETextSearchFilterComponentLanguage   = @"language";  //language=en
NSString *const kGMETextSearchFilterComponentMinPrice   = @"minprice";  //maxprice=2
NSString *const kGMETextSearchFilterComponentMaxPrice   = @"maxprice";  //minprice=4
NSString *const kGMETextSearchFilterComponentOpenNow    = @"opennow";   //opennow
NSString *const kGMETextSearchFilterComponentType       = @"type";      //type=establishment

@interface GMETextSearchFilter (Private)
@property (nonatomic, strong) NSMutableDictionary *filterComponents;
@end

@implementation GMETextSearchFilter

- (void)setLocation:(CLLocationCoordinate2D)location {
    _location = location;
    [self _updateLocationComponent];
}

- (void)setRadius:(NSUInteger)radius {
    _radius = radius;
    [self _updateRadiusComponent];
}

- (void)setLanguage:(NSString *)language {
    _language = language;
    [self _updateLanguageComponent];
}

- (void)setMinPrice:(GMSPlacesPriceLevel)minPrice {
    _minPrice = minPrice;
    [self _updateMinPriceComponent];
}

- (void)setMaxPrice:(GMSPlacesPriceLevel)maxPrice {
    _maxPrice = maxPrice;
    [self _updateMaxPriceComponent];
}

- (void)setIsOpenNow:(BOOL)isOpenNow {
    _isOpenNow = isOpenNow;
    [self _updateIsOpenNowComponent];
}

- (void)setType:(NSString *)type {
    _type = type;
    [self _updateTypeComponent];
}

- (void)_updateLocationComponent {
    NSString *component = [NSString stringWithFormat:@"%@=%f,%f", kGMETextSearchFilterComponentLocation, self.location.latitude, self.location.longitude];
    [self.filterComponents setValue:component forKey:kGMETextSearchFilterComponentLocation];
}

- (void)_updateRadiusComponent {
    NSString *component = [NSString stringWithFormat:@"%@=%lu", kGMETextSearchFilterComponentRadius, (unsigned long)self.radius];
    [self.filterComponents setValue:component forKey:kGMETextSearchFilterComponentRadius];
}

- (void)_updateLanguageComponent {
    NSString *component = [NSString stringWithFormat:@"%@=%@", kGMETextSearchFilterComponentLanguage, self.language];
    [self.filterComponents setValue:component forKey:kGMETextSearchFilterComponentLanguage];
}

- (void)_updateMinPriceComponent {
    if (self.minPrice == kGMSPlacesPriceLevelUnknown) {
        [self.filterComponents removeObjectForKey:kGMETextSearchFilterComponentMinPrice];
    } else {
        NSString *component = [NSString stringWithFormat:@"%@=%li", kGMETextSearchFilterComponentMinPrice, (long)self.minPrice];
        [self.filterComponents setValue:component forKey:kGMETextSearchFilterComponentMinPrice];
    }
}

- (void)_updateMaxPriceComponent {
    if (self.maxPrice == kGMSPlacesPriceLevelUnknown) {
        [self.filterComponents removeObjectForKey:kGMETextSearchFilterComponentMaxPrice];
    } else {
        NSString *component = [NSString stringWithFormat:@"%@=%li", kGMETextSearchFilterComponentMaxPrice, (long)self.maxPrice];
        [self.filterComponents setValue:component forKey:kGMETextSearchFilterComponentMaxPrice];
    }
}

- (void)_updateIsOpenNowComponent {
    if (self.isOpenNow) {
        [self.filterComponents setValue:kGMETextSearchFilterComponentOpenNow forKey:kGMETextSearchFilterComponentOpenNow];
    } else {
        [self.filterComponents removeObjectForKey:kGMETextSearchFilterComponentOpenNow];
    }
}

- (void)_updateTypeComponent {
    NSString *component = [NSString stringWithFormat:@"%@=%@", kGMETextSearchFilterComponentType, self.type];
    [self.filterComponents setValue:component forKey:kGMETextSearchFilterComponentType];
}

- (instancetype)init {
    if (self = [super init]) {
        self.filterComponents = [[NSMutableDictionary alloc] init];
    }
    return self;
}

@end
