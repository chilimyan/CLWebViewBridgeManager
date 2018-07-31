//
//  ViewController.m
//  CLWebViewBridgeManagerDemo
//
//  Created by Apple on 2018/7/31.
//  Copyright © 2018年 chilim. All rights reserved.
//

#import "ViewController.h"
#import "CLWebViewBridgeManager.h"

@interface ViewController ()<WKNavigationDelegate,WKUIDelegate>

@property (nonatomic, strong)WKWebView *webView;
@property (nonatomic, strong) CLWebViewBridgeManager *bridgeManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"WebView测试";
    self.view.backgroundColor = [UIColor whiteColor];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"webviewTest" ofType:@"html"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    __weak __typeof(&*self)weakSelf = self;
    _bridgeManager = [[CLWebViewBridgeManager alloc] initWithProtocolForWebView:self.webView delegate:weakSelf];
    ///JS向OC发出指令
    [_bridgeManager registWebProtocolName:@"tel" callBack:^(NSURLComponents *components) {
        NSLog(@"%@--%@",components.scheme,components.path);
    }];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WKUIDelegate

- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    WKFrameInfo *frameInfo = navigationAction.targetFrame;
    if (![frameInfo isMainFrame]) {
        if (navigationAction.request) {
            [webView loadRequest:navigationAction.request];
        }
    }
    return nil;
}

///JavaScript调用alert方法后回调的方法 message中为alert提示的信息 必须要在其中调用completionHandler()
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    // Get host name of url.
    NSString *host = webView.URL.host;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:host?:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if (completionHandler != NULL) {
            completionHandler();
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        if (completionHandler != NULL) {
            completionHandler();
        }
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

///JavaScript调用confirm方法后回调的方法 confirm是js中的确定框，需要在block中把用户选择的情况传递进去
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    // Get the host name.
    NSString *host = webView.URL.host;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:host?:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if (completionHandler != NULL) {
            completionHandler(YES);
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        if (completionHandler != NULL) {
            completionHandler(NO);
        }
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

///JavaScript调用prompt方法后回调的方法 prompt是js中的输入框 需要在block中把用户输入的信息传入
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    // Get the host of url.
    NSString *host = webView.URL.host;
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:prompt?:@"提示" message:host preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = defaultText?:@"请输入";
        textField.font = [UIFont systemFontOfSize:12];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:NULL];
        NSString *string = [alert.textFields firstObject].text;
        if (completionHandler != NULL) {
            completionHandler(string?:defaultText);
        }
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:NULL];
        NSString *string = [alert.textFields firstObject].text;
        if (completionHandler != NULL) {
            completionHandler(string?:defaultText);
        }
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:NULL];
}

#pragma -mark WKNavigationDelegate
/////========================以下方法按顺序调用==========================///
///webview跳转之前调用，可以根据navigationAction决定是否要进行跳转，即webview是否需要加载新的request。
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"1");
    // Disable all the '_blank' target in page's target.
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView evaluateJavaScript:@"var a = document.getElementsByTagName('a');for(var i=0;i<a.length;i++){a[i].setAttribute('target','');}" completionHandler:nil];
    }
    
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:navigationAction.request.URL.absoluteString];
    if ([[NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] 'https://itunes.apple.com/' OR SELF BEGINSWITH[cd] 'mailto:' OR SELF BEGINSWITH[cd] 'tel:' OR SELF BEGINSWITH[cd] 'telprompt:'"] evaluateWithObject:components.URL.absoluteString]) {
        // 监测到AppStore的链接自动跳转到AppStore
        if ([[NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] 'https://itunes.apple.com/'"] evaluateWithObject:components.URL.absoluteString]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"即将前往AppStore" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"前往" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[components.URL.absoluteString stringByReplacingOccurrencesOfString:@"https" withString:@"itms-apps"]] options:@{} completionHandler:NULL];
                }else{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[components.URL.absoluteString stringByReplacingOccurrencesOfString:@"https" withString:@"itms-apps"]]];
                }
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                
            }]];
            [self presentViewController:alert animated:YES completion:nil];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
        // 监测到拨打电话或者发邮件
        if ([[UIApplication sharedApplication] canOpenURL:components.URL]) {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:components.URL.absoluteString] options:@{} completionHandler:NULL];
            }else{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:components.URL.absoluteString]];
            }
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    } else if (![[NSPredicate predicateWithFormat:@"SELF MATCHES[cd] 'https' OR SELF MATCHES[cd] 'http' OR SELF MATCHES[cd] 'file' OR SELF MATCHES[cd] 'about'"] evaluateWithObject:components.scheme]) {// For any other schema but not `https`、`http` and `file`.
        if ([[UIApplication sharedApplication] canOpenURL:components.URL]) {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:components.URL.absoluteString] options:@{} completionHandler:NULL];
            }else{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:components.URL.absoluteString]];
            }
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

///webview开始加载新页面时调用此方法，该方法调用时页面还没有变化
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"2");
}

///webview在获取到页面返回信息后决定是否跳转的代理方法。如果此时decisionHandler(WKNavigationResponsePolicyCancel),则webview不加载新的请求，不显示新的界面。
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
    NSLog(@"3");
}

//当主机接收到的服务重定向时调用
-(void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"4");
}

//主页数据加载发生错误时调用
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(nonnull NSError *)error{
    NSLog(@"5");
    if (error.code == NSURLErrorCancelled) {
        return;
    }
}

///// 需要响应身份验证时调用 同样在block中需要传入用户身份凭证
//- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler {
//
//}

///webview开始加载新页面时调用此方法，当进入新页面（显示新页面）时，此方法被调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"6");
}

///webView新页面加载完成，页面元素完全显示后调用此方法。
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"7");
    ///OC向JS发出指令并且传递参数
    [_bridgeManager callWebHanderName:@"alertTest" data:@{@"bb":@"123"} callBack:^(id item, NSError * _Nullable error) {
        
    }];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"8");
}



@end
