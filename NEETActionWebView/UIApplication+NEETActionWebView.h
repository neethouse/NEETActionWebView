//
//  UIApplication+NEETActionWebView.h
//  WebActionSheet
//
//  Created by mtmta on 13/05/19.
//  Copyright (c) 2013年 501dev.org. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kNAWUIApplicationDidLongPressNotification @"kNAWUIApplicationDidLongPressNotification"

@interface UIApplication (NEETActionWebView)

- (void)NEETActionWebView_sendEvent:(UIEvent *)event;

@end
