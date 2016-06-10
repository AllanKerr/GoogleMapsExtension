//
//  _GMEParserObject.m
//  NearMe
//
//  Created by Allan Kerr on 2016-06-09.
//  Copyright © 2016 Allan Kerr. All rights reserved.
//

#import "_GMEParserObject.h"

@interface _GMEParserObject ()
@property (nonatomic, strong) NSMutableDictionary *keyedValues;
@end

@implementation _GMEParserObject

- (NSString *)description {
    return [self.keyedValues description];
}

- (id)init {
    if (self = [super init]) {
        self.keyedValues = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    return [NSDictionary dictionaryWithDictionary:self.keyedValues];
}

- (void)addObject:(id)object forKey:(NSString *)key {
    id currentValue = [self.keyedValues valueForKey:key];
    if (currentValue != nil) {
        NSMutableArray *values = currentValue;
        if (![values respondsToSelector:@selector(addObject:)]) {
            values = [NSMutableArray arrayWithObjects:currentValue, object, nil];
            [self.keyedValues setValue:values forKey:key];
        } else {
            [values addObject:object];
        }
    } else {
        [self.keyedValues setValue:object forKey:key];
    }
}

- (id)valueForKey:(NSString *)key {
    return [self.keyedValues valueForKey:key];
}

@end
