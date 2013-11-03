//
//  GOICalloutInfo.m
//  NEETActionWebView
//
//  Created by mtmta on 13/05/26.
//  Copyright (c) 2013年 501dev.org. All rights reserved.
//

#import "NAWAction.h"

@implementation NAWAction

- (id)initWithJSONDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        
        _javaScriptContext = [NSString stringWithFormat:@"(window['%@'])", dict[@"contextName"]];
        
        if (0 < [dict[@"linkURL"] length]) {
            _linkURL = dict[@"linkURL"];
        }
        
        if (0 < [dict[@"imageURL"] length]) {
            _imageURL = dict[@"imageURL"];
        }
    }
    return self;
}

@end
