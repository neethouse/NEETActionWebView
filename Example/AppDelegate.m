//
//  AppDelegate.m
//  Example
//
//  Created by daichi on 2013/11/03.
//  Copyright (c) 2013年 The Neet House. All rights reserved.
//

#import "AppDelegate.h"

#import "ExampleViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    ExampleViewController *viewController = [[ExampleViewController alloc] init];
    
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
