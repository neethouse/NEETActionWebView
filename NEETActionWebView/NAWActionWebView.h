//
//  NAWActionWebView.h
//  NEETActionWebView
//
//  Created by mtmta on 13/01/01.
//  Copyright (c) 2013 501dev.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NAWAction.h"

@class NAWActionWebView;

@protocol NAWActionWebViewDelegate <UIWebViewDelegate>

@optional

- (void)webView:(NAWActionWebView *)webView didAction:(NAWAction *)action;

@end


#pragma mark -

@interface NAWActionWebView : UIWebView

@property (weak, nonatomic) id<NAWActionWebViewDelegate> delegate;

@end
