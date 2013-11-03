//
//  GOICalloutInfo.h
//  NEETActionWebView
//
//  Created by mtmta on 13/05/26.
//  Copyright (c) 2013年 501dev.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NAWAction : NSObject

@property (readonly, nonatomic) NSString *linkURL;

@property (readonly, nonatomic) NSString *imageURL;

@property (readonly, nonatomic) NSString *javaScriptContext;

- (id)initWithJSONDictionary:(NSDictionary *)dict;

@end
