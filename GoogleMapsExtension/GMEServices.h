//
//  GMEServices.h
//  NearMe
//
//  Created by Allan Kerr on 2016-06-09.
//  Copyright © 2016 Allan Kerr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GMEServices : NSObject
/**
 * Provides your browser API key to the Google Places API Web Service.  This key is 
 * generated for your application via the Google APIs Console, and is paired with your
 * application's bundle ID to identify it.  This should be called exactly once
 * by your application, e.g., in application: didFinishLaunchingWithOptions:.
 *
 * @return YES if the APIKey was successfully provided
 */
+ (BOOL)provideAPIKey:(NSString *)APIKey;
@end
