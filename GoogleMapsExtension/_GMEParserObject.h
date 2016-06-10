//
//  _GMEParserObject.h
//  NearMe
//
//  Created by Allan Kerr on 2016-06-09.
//  Copyright © 2016 Allan Kerr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface _GMEParserObject : NSObject
- (NSDictionary *)dictionaryRepresentation;
- (void)addObject:(id)object forKey:(NSString *)key;
- (id)valueForKey:(NSString *)key;
@end
