//
//  CLWebViewBridgeManager.h
//  CLTableViewDemo
//
//  Created by Apple on 2018/7/27.
//  Copyright © 2018年 chilim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "CLWebBridge.h"

@interface CLWebViewBridgeManager : NSObject<WKNavigationDelegate,CLWebBridgeDelegate>

/**
 初始化一个Bridge实例

 @param webView 当前加载h5的webView
 @param delegate webView的代理
 @return 返回一个实例
 */
- (instancetype)initWithProtocolForWebView:(WKWebView *)webView delegate:(id<WKNavigationDelegate>)delegate;

/**
 H5通过协议向OC发出指令及传输参数

 @param protocol 协议名称
 @param callBack 回调
 */
- (void)registWebProtocolName:(NSString *)protocol callBack:(webProtocolCallback)callBack;

/**
 OC在WebView加载完成之后执行JS函数向JS发出指令及传输参数

 @param handerName JS与OC协商的函数名称
 @param data 要传输的数据
 @param callBack 回调
 */
- (void)callWebHanderName:(NSString *)handerName data:(NSDictionary *)data callBack:(webHandleCallback)callBack;


@end
