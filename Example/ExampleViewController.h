//
//  ExampleViewController.h
//  Example
//
//  Created by mtmta on 13/05/26.
//  Copyright (c) 2013年 501dev.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NEETActionWebView/NEETActionWebView.h>

@interface ExampleViewController : UIViewController <NAWActionWebViewDelegate>

@property (strong, nonatomic) UIWebView *selectedWebView;

@property (strong, nonatomic) UISegmentedControl *webViewSelector;

@end
