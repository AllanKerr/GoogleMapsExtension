//
//  GMETextSearchFetcher.h
//  NearMe
//
//  Created by Allan Kerr on 2016-06-09.
//  Copyright © 2016 Allan Kerr. All rights reserved.
//

#import "GMETextSearchFilter.h"
@import GoogleMaps;

@protocol GMETextSearchFetcherDelegate <NSObject>
@required
- (void)didSearchWithPlaces:(NSArray <GMSPlace *>*)places;
- (void)didFailSearchWithError:(NSError *)error;
@end

@interface GMETextSearchFetcher : NSObject
/** Delegate to be notified with text search results. */
@property(nonatomic, weak) id <GMETextSearchFetcherDelegate>delegate;
/** Filter to apply to search suggestions (can be nil). */
@property(nonatomic, strong) GMETextSearchFilter *textSearchFilter;
/**
 * Initialise the fetcher
 * @param filter The filter to apply to the results. This parameter may be nil.
 */
- (instancetype)initWithFilter:(GMETextSearchFilter *)filter;
/**
 * Notify the fetcher that the source text to search has changed. This method is non-blocking.
 * @param text The partial text to autocomplete.
 */
- (void)sourceTextHasChanged:(NSString *)text;
@end
