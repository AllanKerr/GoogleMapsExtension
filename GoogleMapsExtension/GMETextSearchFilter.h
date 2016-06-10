//
//  GMETextSearchFilter.h
//  NearMe
//
//  Created by Allan Kerr on 2016-06-09.
//  Copyright © 2016 Allan Kerr. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
@import GoogleMaps;

@interface GMETextSearchFilter : NSObject
/*
 The latitude/longitude around which to retrieve place information.
 This must be specified as latitude,longitude. If you specify a 
 location parameter, you must also specify a radius parameter.
 */
@property (nonatomic) CLLocationCoordinate2D location;

/*
 Defines the distance (in meters) within which to bias place results. 
 The maximum allowed radius is 50 000 meters. Results inside of this 
 region will be ranked higher than results outside of the search circle; 
 however, prominent results from outside of the search radius may be included.
 */
@property (nonatomic) NSUInteger radius;

/*
 The language code, indicating in which language the results should be returned, 
 if possible. Searches are also biased to the selected language; results in the 
 selected language may be given a higher ranking. See GMELanguageTypes for a list
 of supported languages.
 */
@property (nonatomic, strong) NSString *language;

/*
 Restricts results to only those places within the specified price level. Valid values 
 are in the range from 0 (most affordable) to 4 (most expensive), inclusive. The exact 
 amount indicated by a specific value will vary from region to region.
 */
@property (nonatomic) GMSPlacesPriceLevel minPrice;
@property (nonatomic) GMSPlacesPriceLevel maxPrice;

/*
 Returns only those places that are open for business at the time the query is sent. 
 Places that do not specify opening hours in the Google Places database will not be 
 returned if you include this parameter in your query.
*/
@property (nonatomic) BOOL isOpenNow;

/*
 Restricts the results to places matching the specified type. Only one type may be specified
 (if more than one type is provided, all types following the first entry are ignored).
 See GMSPlaceTypes.h for a list of supported types.
 */
@property (nonatomic, strong) NSString *type;
@end
