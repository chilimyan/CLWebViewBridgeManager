//
//  CLWebViewBridgeManager.m
//  CLTableViewDemo
//
//  Created by Apple on 2018/7/27.
//  Copyright © 2018年 chilim. All rights reserved.
//

#import "CLWebViewBridgeManager.h"

@implementation CLWebViewBridgeManager{
    WKWebView* _webView;
    id _webViewDelegate;
    CLWebBridge  *_webBridge;
}

- (void)dealloc{
    _webView = nil;
    _webViewDelegate = nil;
    _webView.navigationDelegate = nil;
    _webBridge = nil;
}

- (instancetype)initWithProtocolForWebView:(WKWebView *)webView delegate:(id<WKNavigationDelegate>)delegate{
    if (self = [super init]) {
        _webView = webView;
        _webViewDelegate = delegate;
        _webView.navigationDelegate = self;
        _webBridge = [[CLWebBridge alloc] init];
        _webBridge.delegate = self;
    }
    return self;
}

- (void)registWebProtocolName:(NSString *)protocol callBack:(webProtocolCallback)callBack{
    if (protocol) {
        if (![protocol isEqualToString:@""]) {
            _webBridge.callBackDic[protocol] = callBack;
            return;
        }
    }
    NSLog(@"Web协议不能为空！");
}

- (void)callWebHanderName:(NSString *)handerName data:(NSDictionary *)data callBack:(webHandleCallback)callBack{
    if (handerName) {
        if (![handerName isEqualToString:@""]) {
            [_webBridge sendData:data handleName:handerName callBack:callBack];
            return;
        }
    }
    NSLog(@"函数名称不能为空！");
}

- (void)evaluateJavascript:(NSString*)javascriptCommand callBack:(webHandleCallback)callBack{
    [_webView evaluateJavaScript:javascriptCommand completionHandler:callBack];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:navigationAction.request.URL.absoluteString];
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    if (_webBridge.callBackDic[components.scheme]) {
        if (![components.scheme isEqualToString:@"http"] && ![components.scheme isEqualToString:@"https"]) {
            [_webBridge protocolMatch:components];
            decisionHandler(WKNavigationActionPolicyCancel);
        }
    }else if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)]){
        [_webViewDelegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    }
    else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if (webView != _webView) { return; }
    
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didFinishNavigation:)]) {
        [strongDelegate webView:webView didFinishNavigation:navigation];
    }
    ///向JS传值
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if (webView != _webView) { return; }
    
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didStartProvisionalNavigation:)]) {
        [strongDelegate webView:webView didStartProvisionalNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView
didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    if (webView != _webView) { return; }
    
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didFailNavigation:withError:)]) {
        [strongDelegate webView:webView didFailNavigation:navigation withError:error];
    }
}

@end

