//
//  UIApplication+NEETActionWebView.m
//  WebActionSheet
//
//  Created by mtmta on 13/05/19.
//  Copyright (c) 2013年 501dev.org. All rights reserved.
//

#import "UIApplication+NEETActionWebView.h"
#import <objc/runtime.h>

static void NAWSwizzleMethod(Class cls, SEL orgSelector, SEL newSelector) {
    
    Method orgMethod = class_getInstanceMethod(cls, orgSelector);
    Method newMethod = class_getInstanceMethod(cls, newSelector);
    
    if (class_addMethod(cls, orgSelector, method_getImplementation(newMethod),
                       method_getTypeEncoding(newMethod))) {
        
        class_replaceMethod(cls, newSelector, method_getImplementation(orgMethod),
                            method_getTypeEncoding(orgMethod));
        
    } else {
        
        method_exchangeImplementations(orgMethod, newMethod);
        
    }
}

static NSTimer *_longPressTimer;
static CGPoint _pressingLocation;

@implementation UIApplication (NEETActionWebView)

+ (void)load {
    NAWSwizzleMethod(self, @selector(sendEvent:), @selector(NEETActionWebView_sendEvent:));
}

- (void)NEETActionWebView_sendEvent:(UIEvent *)event {
    [self NEETActionWebView_sendEvent:event];
    
    if (event.type == UIEventTypeTouches) {
        UIWindow *window = self.keyWindow;
        
        NSSet *touches = [event touchesForWindow:window];
        
        if (touches.count == 1) {
            UITouch *touch = [touches anyObject];
            
            switch (touch.phase) {
                case UITouchPhaseBegan:
                    _pressingLocation = [touch locationInView:nil];
                    [_longPressTimer invalidate];
                    
                    // UIWebView のメニューは約0.75秒で表示されるので、その前にカスタムメニューを表示する
                    _longPressTimer = [NSTimer
                                       scheduledTimerWithTimeInterval:0.69
                                       target:self
                                       selector:@selector(NEETActionWebView_longPressAction:)
                                       userInfo:window
                                       repeats:NO];
                    break;
                    
                case UITouchPhaseStationary:
                    break;
                    
                case UITouchPhaseEnded:
                case UITouchPhaseMoved:
                case UITouchPhaseCancelled:
                    [_longPressTimer invalidate];
                    _longPressTimer = nil;
                    break;
            }
            
        } else {
            [_longPressTimer invalidate];
            _longPressTimer = nil;
        }
    }
}

- (void)NEETActionWebView_longPressAction:(NSTimer *)timer {
    _longPressTimer = nil;
    
    NSDictionary *userInfo = @{ @"location": [NSValue valueWithCGPoint:_pressingLocation] };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNAWUIApplicationDidLongPressNotification
                                                        object:timer.userInfo // window
                                                      userInfo:userInfo];
}

@end
