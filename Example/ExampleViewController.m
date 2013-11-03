//
//  ExampleViewController.m
//  Example
//
//  Created by mtmta on 13/05/26.
//  Copyright (c) 2013年 501dev.org. All rights reserved.
//

#import "ExampleViewController.h"

@interface ExampleViewController ()

@end

@implementation ExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
    }
    
    // Web view selector
    NSArray *selectorItems = @[
                               NSStringFromClass([NAWActionWebView class]),
                               NSStringFromClass([UIWebView class])
                               ];
    self.webViewSelector = [[UISegmentedControl alloc] initWithItems:selectorItems];
    self.webViewSelector.segmentedControlStyle = UISegmentedControlStyleBar;
    
    [self.webViewSelector addTarget:self
                             action:@selector(selectWebView:)
                   forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.titleView = self.webViewSelector;
    
    self.webViewSelector.selectedSegmentIndex = 0;
    [self selectWebView:self.webViewSelector];
    
    // Refresh bar button item
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc]
                                initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                target:self
                                action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = refresh;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        _selectedWebView.scrollView.contentInset = (UIEdgeInsets){
            self.topLayoutGuide.length, 0, self.bottomLayoutGuide.length, 0,
        };
    }
}

- (void)selectWebView:(id)sender {
    
    NSString *webViewClassName = [self.webViewSelector titleForSegmentAtIndex:self.webViewSelector.selectedSegmentIndex];
    Class webViewClass = NSClassFromString(webViewClassName);
    
    [_selectedWebView removeFromSuperview];
    
    _selectedWebView = [[webViewClass alloc] initWithFrame:self.view.bounds];
    _selectedWebView.delegate = self;
    
    [self.view addSubview:_selectedWebView];
    
    [self refresh];
}

- (void)refresh {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self.selectedWebView loadRequest:request];
}


#pragma mark - NEETActionWebView delegate

- (void)webView:(NAWActionWebView *)webView didAction:(NAWAction *)action {
    
    NSString *msg = [NSString stringWithFormat:
                     @"link = %@\n"
                     @"image = %@",
                     action.linkURL, action.imageURL];
    
    UIAlertView *alertView = [UIAlertView.alloc initWithTitle:@"NEETActionWebView"
                                                      message:msg
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [alertView show];
}


#pragma mark - UIWebView delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
