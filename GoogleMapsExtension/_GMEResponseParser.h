//
//  _GMEResponseParser.h
//  NearMe
//
//  Created by Allan Kerr on 2016-06-09.
//  Copyright © 2016 Allan Kerr. All rights reserved.
//

#import <Foundation/Foundation.h>
@import GoogleMaps;

@class _GMEResponseParser;
@protocol _GMEResponseParserDelegate <NSObject>
@required
- (void)parser:(_GMEResponseParser *)parser didFinishWithPlaces:(NSArray <GMSPlace *>*)places;
- (void)parser:(_GMEResponseParser *)parser didFailWithStatus:(NSString *)status;
@end

@interface _GMEResponseParser : NSObject
@property (nonatomic, weak) id <_GMEResponseParserDelegate>delegate;
- (instancetype)initWithResponseData:(NSData *)responseData;
- (BOOL)parse;	// called to start the event-driven parse. Returns YES in the event of a successful parse, and NO in case of error.
@end
