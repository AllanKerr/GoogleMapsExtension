//
//  _GMEResponseParser.m
//  NearMe
//
//  Created by Allan Kerr on 2016-06-09.
//  Copyright © 2016 Allan Kerr. All rights reserved.
//

#import "_GMEResponseParser.h"
#import "_GMEParserObject.h"

NSString *const kGMEResponseParserStatus                    = @"status";
NSString *const kGMEResponseParserStatusOK                  = @"OK";
NSString *const kGMEResponseParserStatusZeroResults         = @"ZERO_RESULTS";
NSString *const kGMEResponseParserStatusOverLimit           = @"OVER_QUERY_LIMIT";
NSString *const kGMEResponseParserStatusRequestDenied       = @"REQUEST_DENIED";
NSString *const kGMEResponseParserStatusInvalidRequest      = @"INVALID_REQUEST";

NSString *const kGMEResponseParserResult                    = @"result";
NSString *const kGMEResponseParserResultName                = @"name";
NSString *const kGMEResponseParserResultPlaceID             = @"place_id";
NSString *const kGMEResponseParserResultFormattedAddress    = @"formatted_address";
NSString *const kGMEResponseParserResultHTMLAttribution     = @"html_attribution";
NSString *const kGMEResponseParserResultType                = @"type";
NSString *const kGMEResponseParserResultGeometry            = @"geometry";
NSString *const kGMEResponseParserResultLocation            = @"location";
NSString *const kGMEResponseParserResultViewport            = @"viewport";
NSString *const kGMEResponseParserResultOpeningHours        = @"opening_hours";
NSString *const kGMEResponseParserResultPriceLevel          = @"price_level";
NSString *const kGMEResponseParserResultLatitude            = @"lat";
NSString *const kGMEResponseParserResultLongitude           = @"lng";
NSString *const kGMEResponseParserResultNorthEastCoordinate = @"northeast";
NSString *const kGMEResponseParserResultSouthWestCoordinate = @"southwest";
NSString *const kGMEResponseParserResultOpenNow             = @"open_now";
NSString *const kGMEResponseParserResultOpenNowTrue         = @"true";
NSString *const kGMEResponseParserResultOpenNowFalse        = @"false";

@interface GMSPlace (Private)
- (instancetype)initWithName:(NSString *)name coordinate:(CLLocationCoordinate2D)coordinate openNowStatus:(GMSPlacesOpenNowStatus)openNowStatus priceLevel:(GMSPlacesPriceLevel)priceLevel phoneNumber:(NSString *)phoneNumber formattedAddress:(NSString *)formattedAddress website:(NSURL *)website placeID:(NSString *)placeID htmlAttributions:(id)htmlAttributions types:(NSArray *)types nearbyZones:(id)nearbyZones addressComponents:(NSArray *)addressComponents viewport:(GMSCoordinateBounds *)viewport;
@end

@interface _GMEResponseParser () <NSXMLParserDelegate>
@property (nonatomic, strong) NSMutableString *currentValue;
@property (nonatomic, strong) _GMEParserObject *currentObject;
@property (nonatomic, strong) _GMEParserObject *rootObject;
@property (nonatomic, strong) NSMutableArray <_GMEParserObject *>*objectStack;
@property (nonatomic, strong) NSXMLParser *parser;
@end

@implementation _GMEResponseParser

- (instancetype)initWithResponseData:(NSData *)responseData {
    if (self = [super init]) {
        self.objectStack = [NSMutableArray array];
        self.parser = [[NSXMLParser alloc] initWithData:responseData];
        self.parser.delegate = self;
    }
    return self;
}

- (BOOL)parse {
    return [self.parser parse];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    self.currentObject = [[_GMEParserObject alloc] init];
    if (self.rootObject == nil) {
        self.rootObject = self.currentObject;
    }
    [self.objectStack addObject:self.currentObject];
}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    NSString *value = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (value.length > 0) {
        if (self.currentValue == nil) {
            self.currentValue = [NSMutableString stringWithString:string];
        } else {
            [self.currentValue appendString:string];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    [self.objectStack removeLastObject];
    _GMEParserObject *topObject = [self.objectStack lastObject];
    if (self.currentValue) {
        [topObject addObject:self.currentValue forKey:elementName];
        self.currentValue = nil;
    } else {
        [topObject addObject:self.currentObject forKey:elementName];
    }
    self.currentObject = topObject;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    [self.delegate parser:self didFailWithError:parseError];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    NSString *status = [self.rootObject valueForKey:kGMEResponseParserStatus];
    if ([self _validateStatus:status]) {
        
        // If only one result is found it won't be grouped into an array.
        // In that case, create an array for the single result.
        
        NSArray *results;
        id result = [self.rootObject valueForKey:kGMEResponseParserResult];
        NSAssert2(result != nil, @"%@ finished with status %@ but no contains no results.", [self class], status);
        if (![result conformsToProtocol:@protocol(NSFastEnumeration)]) {
            results = [NSArray arrayWithObject:result];
        } else {
            results = result;
        }
        [self _parseResults:results];
    }
}

- (BOOL)_validateStatus:(NSString *)status {
    BOOL isValid = [status isEqualToString:kGMEResponseParserStatusOK];
    if (!isValid) {
        if ([status isEqualToString:kGMEResponseParserStatusZeroResults]) {
            [self.delegate parser:self didFinishWithPlaces:@[]];
        } else {
            NSError *error = [self _parseErrorStatus:status];
            [self.delegate parser:self didFailWithError:error];
        }
    }
    return isValid;
}

- (NSError *)_parseErrorStatus:(NSString *)status {
    GMSPlacesErrorCode errorCode;
    if ([status isEqualToString:kGMEResponseParserStatusOverLimit]) {
        errorCode = kGMSPlacesUsageLimitExceeded;
    } else if ([status isEqualToString:kGMEResponseParserStatusRequestDenied]) {
        errorCode = kGMSPlacesKeyInvalid;
    } else if ([status isEqualToString:kGMEResponseParserStatusInvalidRequest]) {
        errorCode = kGMSPlacesInternalError;
    }
    NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey : status};
    return [NSError errorWithDomain:NSCocoaErrorDomain code:errorCode userInfo:userInfo];
}

- (void)_parseResults:(NSArray *)results {
    NSMutableArray <GMSPlace *>*places = [NSMutableArray arrayWithCapacity:results.count];
    for (_GMEParserObject *result in results) {
        NSString *name = [result valueForKey:kGMEResponseParserResultName];
        NSString *placeID = [result valueForKey:kGMEResponseParserResultPlaceID];
        NSString *formattedAddress = [result valueForKey:kGMEResponseParserResultFormattedAddress];
        NSString *htmlAttribution = [result valueForKey:kGMEResponseParserResultHTMLAttribution];
        NSArray *types = [result valueForKey:kGMEResponseParserResultType];

        _GMEParserObject *locationObject = [[result valueForKey:kGMEResponseParserResultGeometry] valueForKey:kGMEResponseParserResultLocation];
        CLLocationCoordinate2D location = [self _parseLocationObject:locationObject];
        
        _GMEParserObject *viewportObject = [result valueForKey:kGMEResponseParserResultViewport];
        GMSCoordinateBounds *viewport = [self _parseViewportObject:viewportObject];
    
        _GMEParserObject *openingHoursObject = [result valueForKey:kGMEResponseParserResultOpeningHours];
        GMSPlacesOpenNowStatus openNowStatus = [self _parseOpeningHoursObject:openingHoursObject];
        GMSPlacesPriceLevel priceLevel = [[result valueForKey:kGMEResponseParserResultPriceLevel] integerValue];
        
        GMSPlace *place = [[GMSPlace alloc] initWithName:name coordinate:location openNowStatus:openNowStatus priceLevel:priceLevel phoneNumber:nil formattedAddress:formattedAddress website:nil placeID:placeID htmlAttributions:htmlAttribution types:types nearbyZones:nil addressComponents:nil viewport:viewport];
        [places addObject:place];
    }
    [self.delegate parser:self didFinishWithPlaces:places];
}

- (CLLocationCoordinate2D)_parseLocationObject:(_GMEParserObject *)locationObject {
    CLLocationCoordinate2D location = kCLLocationCoordinate2DInvalid;
    if (locationObject != nil) {
        CLLocationDegrees latitude = [[locationObject valueForKey:kGMEResponseParserResultLatitude] doubleValue];
        CLLocationDegrees longitude = [[locationObject valueForKey:kGMEResponseParserResultLongitude] doubleValue];
        location = CLLocationCoordinate2DMake(latitude, longitude);
    }
    return location;
}

- (GMSCoordinateBounds *)_parseViewportObject:(_GMEParserObject *)viewportObject {
    GMSCoordinateBounds *viewport = nil;
    if (viewportObject != nil) {
        _GMEParserObject *northEastObject = [viewportObject valueForKey:kGMEResponseParserResultNorthEastCoordinate];
        CLLocationDegrees northEastLatitude = [[northEastObject valueForKey:kGMEResponseParserResultLatitude] doubleValue];
        CLLocationDegrees northEastLongitude = [[northEastObject valueForKey:kGMEResponseParserResultLongitude] doubleValue];
        CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(northEastLatitude, northEastLongitude);
        
        _GMEParserObject *southWestObject = [viewportObject valueForKey:kGMEResponseParserResultSouthWestCoordinate];
        CLLocationDegrees southWestLatitude = [[southWestObject valueForKey:kGMEResponseParserResultLatitude] doubleValue];
        CLLocationDegrees southWestLongitude = [[southWestObject valueForKey:kGMEResponseParserResultLongitude] doubleValue];
        CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(southWestLatitude, southWestLongitude);
        
        viewport = [[GMSCoordinateBounds alloc] initWithCoordinate:northEast coordinate:southWest];
    }
    return viewport;
}

- (GMSPlacesOpenNowStatus)_parseOpeningHoursObject:(_GMEParserObject *)openingHoursObject {
    GMSPlacesOpenNowStatus openNowStatus;
    NSString *openNowStatusString = [openingHoursObject valueForKey:kGMEResponseParserResultOpenNow];
    if ([openNowStatusString isEqualToString:kGMEResponseParserResultOpenNowTrue]) {
        openNowStatus = kGMSPlacesOpenNowStatusYes;
    } else if ([openNowStatusString isEqualToString:kGMEResponseParserResultOpenNowFalse]) {
        openNowStatus = kGMSPlacesOpenNowStatusNo;
    } else {
        openNowStatus = kGMSPlacesOpenNowStatusUnknown;
    }
    return openNowStatus;
}

@end
