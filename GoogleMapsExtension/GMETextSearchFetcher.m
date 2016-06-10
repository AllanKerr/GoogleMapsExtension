//
//  GMETextSearchFetcher.m
//  NearMe
//
//  Created by Allan Kerr on 2016-06-09.
//  Copyright © 2016 Allan Kerr. All rights reserved.
//

#import "GMETextSearchFetcher.h"
#import "GMEServices.h"
#import "_GMEResponseParser.h"

NSString *const kGMETextSearchFetcherComponentBasePath  = @"https://maps.googleapis.com/maps/api/place/textsearch/";
NSString *const kGMETextSearchFetcherComponentFormat    = @"xml";
NSString *const kGMETextSearchFetcherComponentQuery     = @"query";
NSString *const kGMETextSearchFetcherComponentKey       = @"key";

@interface GMEServices (Private)
+ (NSString *)APIKey;
@end

@interface GMETextSearchFilter (Private)
@property (nonatomic, strong) NSMutableDictionary *filterComponents;
@end

@interface GMETextSearchFetcher () <_GMEResponseParserDelegate>
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) _GMEResponseParser *parser;
@end

@implementation GMETextSearchFetcher

- (instancetype)initWithFilter:(GMETextSearchFilter *)filter {
    if (self = [super init]) {
        self.textSearchFilter = filter;
    }
    return self;
}

- (void)sourceTextHasChanged:(NSString *)text {
    NSString *query = [text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self _performTextSearchForQuery:query];
}

- (NSString *)_buildPathForQuery:(NSString *)query {
    NSString *queryComponent = [NSString stringWithFormat:@"%@=%@", kGMETextSearchFetcherComponentQuery, query];
    NSMutableString *path = [[NSMutableString alloc] initWithFormat:@"%@%@?%@", kGMETextSearchFetcherComponentBasePath, kGMETextSearchFetcherComponentFormat, queryComponent];
    [self.textSearchFilter.filterComponents enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *component, BOOL *stop) {
        [path appendFormat:@"&%@", component];
    }];
    NSString *keyComponent = [NSString stringWithFormat:@"%@=%@", kGMETextSearchFetcherComponentKey, [GMEServices APIKey]];
    [path appendFormat:@"&%@", keyComponent];
    return path;
}

- (void)_performTextSearchForQuery:(NSString *)query {
    [self.task cancel];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSString *path = [self _buildPathForQuery:query];
    NSURL *url = [NSURL URLWithString:path];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    self.task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", newStr);
        self.parser = [[_GMEResponseParser alloc] initWithResponseData:data];
        self.parser.delegate = self;
        [self.parser parse];
    }];
    [self.task resume];
}

- (void)parser:(_GMEResponseParser *)parser didFinishWithPlaces:(NSArray <GMSPlace *>*)places {
    [self.delegate didSearchWithPlaces:places];
}

- (void)parser:(_GMEResponseParser *)parser didFailWithStatus:(NSString *)status {
    NSDictionary *userInfo = @{status : NSLocalizedDescriptionKey};
    NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:1000 userInfo:userInfo];
    [self.delegate didFailSearchWithError:error];
}

@end
