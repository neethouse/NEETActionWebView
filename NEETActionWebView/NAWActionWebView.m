//
//  NAWActionWebView.m
//  NEETActionWebView
//
//  Created by mtmta on 13/01/01.
//  Copyright (c) 2013 501dev.org. All rights reserved.
//

#import "NAWActionWebView.h"
#import "UIApplication+NEETActionWebView.h"

/// here document macro
#define _DOC(...) @#__VA_ARGS__

@implementation NAWActionWebView

@dynamic delegate;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didMoveToWindow {
    
    [super didMoveToWindow];
    
    if (self.window) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidLongPress:)
                                                     name:kNAWUIApplicationDidLongPressNotification
                                                   object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)applicationDidLongPress:(NSNotification *)note {
    
    if (note.object == self.window) {
        CGPoint location = [note.userInfo[@"location"] CGPointValue];
        location = [self convertPoint:location fromView:nil];
        
        [self longPressActionWithViewLocation:location];
    }
}

- (void)longPressActionWithViewLocation:(CGPoint)location {
    
    CGPoint offset = [self scrollOffset];
    CGPoint domOffset  = [self domScrollOffset];
    
    CGSize viewSize = self.frame.size;
    CGSize windowSize = [self domWindowSize];
    
    CGFloat scale = windowSize.width / viewSize.width;
    
    CGPoint domLocation = (CGPoint){
        (location.x - offset.x) * scale + domOffset.x,
        (location.y - offset.y) * scale + domOffset.y };
    
    [self longPressActionWithDOMLocation:domLocation scale:scale];
}

- (void)longPressActionWithDOMLocation:(CGPoint)domLocation scale:(CGFloat)scale {
    
    NSString *script = _DOC(function(global, x, y, scale) {
        
        function main() {
            var result = {
            contextName: createRandomVarName()
            };
            
            try {
                /* 周囲 12 px まで調べる */
                for (var i = 0; i < 3; i++) {
                    var margin = (i + 1) * 5 * scale;
                    var found = getLinkOrImageInfo(x, y, margin, result);
                    if (found) {
                        break;
                    }
                }
                
            } catch(e) {
                result.error = e;
            }
            
            result.found = found;
            
            global[result.contextName] = result;
            return JSON.stringify(createJSONSafeObject(result));
        }
        
        var deltas = [[  0,  0 ], /* 中心 */
                      [  0, -1 ], /* 中上 */
                      [  1, -1 ], /* 右上 */
                      [  1,  0 ], /* 以下時計回り */
                      [  1,  1 ],
                      [  0,  1 ],
                      [ -1,  1 ],
                      [ -1,  0 ],
                      [ -1, -1 ],
                      ];
        
        /**
         * 指定した座標にあるリンクまたは画像の URL を取得する.
         * @return 指定された座標にリンクまたは画像が存在する場合に YES を返す.
         */
        function getLinkOrImageInfo(x, y, margin, result) {
            var found = deltas.some(function(dxy, i) {
                var stop = false;
                
                var cx = x + dxy[0] * margin;
                var cy = y + dxy[1] * margin;
                
                var elem = document.elementFromPoint(cx, cy);
                
                if (elem) {
                    var linkElem = findAncestorElement(elem, "A");
                    
                    if (elem.tagName == "IMG") {
                        result.image = elem;
                        result.imageURL = elem.src;
                        stop = true;
                    }
                    
                    if (linkElem && linkElem.href && 0 < linkElem.href.length) {
                        result.link = linkElem;
                        result.linkURL = linkElem.href;
                        stop = true;
                    }
                }
                
                return stop;
            });
            
            return found;
        }
        
        /* elem の祖先 (または elem 自身) からタグ名が ancestorTag の要素を探す.
         * ancestorTag は大文字で指定する.
         */
        function findAncestorElement(elem, ancestorTag) {
            if (!elem) {
                return null;
                
            } else if (elem.tagName == ancestorTag) {
                return elem;
            }
            
            return findAncestorElement(elem.parentNode, ancestorTag);
        }
        
        function createRandomVarName() {
            return ".NEETActionWebView" + ("" + Math.round(Math.random() * 10*1000*1000*1000)).substr(0, 10);
        }
        
        function createJSONSafeObject(obj) {
            var jsonObj = {};
            
            for (var name in obj) {
                if (obj.hasOwnProperty(name)) {
                    if (typeof obj[name] != "object") {
                        jsonObj[name] = obj[name];
                    } else {
                        jsonObj[name] = "" + obj[name];
                    }
                }
            }
            
            return jsonObj;
        }
        
        return main();
    });
    
    script = [NSString stringWithFormat:@"(%@)(this, %.0f, %.0f, %.3f)",
              script, domLocation.x, domLocation.y, scale];
    
    NSString *resultJSON = [self stringByEvaluatingJavaScriptFromString:script];
    
    NSDictionary *result = [NSJSONSerialization
                            JSONObjectWithData:[resultJSON dataUsingEncoding:NSUTF8StringEncoding]
                            options:0
                            error:NULL];
    
    if ([result[@"found"] boolValue]) {
        // タッチ、範囲選択をキャンセル
        [self cancelTouching];
        [self endEditing:YES];
        
        if ([self.delegate respondsToSelector:@selector(webView:didAction:)]) {
            NAWAction *info = [[NAWAction alloc] initWithJSONDictionary:result];
            [self.delegate webView:self didAction:info];
        }
    }
    
    NSString *finalizeScript = [NSString stringWithFormat:@"delete this['%@']", result[@"contextName"]];
    [self stringByEvaluatingJavaScriptFromString:finalizeScript];
}

- (void)cancelTouching {
    UIView *superview = self.superview;
    NSUInteger viewIndex = [superview.subviews indexOfObject:self];
    
    [self removeFromSuperview];
    
    [superview insertSubview:self atIndex:viewIndex];
}


#pragma mark - DOM measuring

- (CGSize)domWindowSize {
    CGSize size;
    size.width = [[self stringByEvaluatingJavaScriptFromString:@"window.innerWidth"] integerValue];
    size.height = [[self stringByEvaluatingJavaScriptFromString:@"window.innerHeight"] integerValue];
    return size;
}

- (CGPoint)domScrollOffset {
    
    return CGPointZero;
    
    // iOS5 以降はスクロール位置の補正は必要ない？
    // http://j-apps.sakura.ne.jp/prototype/2011/10/13/ios5%E3%81%AEuiwebview%E3%81%A7document-elementfrompointxy%E3%81%AE%E4%BB%95%E6%A7%98%E3%81%8C%E5%A4%89%E3%82%8F%E3%81%A3%E3%81%9F/
    // CGPoint pt;
    // pt.x = [[self stringByEvaluatingJavaScriptFromString:@"window.pageXOffset"] integerValue];
    // pt.y = [[self stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] integerValue];
    // return pt;
}

- (CGPoint)scrollOffset {
    
    UIEdgeInsets inset = self.scrollView.contentInset;
    return (CGPoint){ inset.left, inset.top };
}

@end
