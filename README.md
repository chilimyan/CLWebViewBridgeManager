# CLWebViewBridgeManager
一个简单的webview和h5的桥接组建

#### 安装方法：
1、支持cocoaPods安装：pod 'CLWebViewBridgeManager'

2、下载下来直接拖进项目工程中

#### 功能介绍：
首先在加载h5的Controller中初始化组建
`- (instancetype)initWithProtocolForWebView:(WKWebView *)webView delegate:(id<WKNavigationDelegate>)delegate;`
如下：

```
__weak __typeof(&*self)weakSelf = self;
    _bridgeManager = [[CLWebViewBridgeManager alloc] initWithProtocolForWebView:self.webView delegate:weakSelf];
```
然后当你想要接收h5指令的时候注册一个协议，协议名称必须和h5协商好

```
[_bridgeManager registWebProtocolName:@"tel" callBack:^(NSURLComponents *components) {
        NSLog(@"%@--%@",components.scheme,components.path);
    }];
```
在h5加载完成之后可以通过

```
[_bridgeManager callWebHanderName:@"alertTest" data:@{@"bb":@"123"} callBack:^(id item, NSError * _Nullable error) {
        
    }];
```
方法执行js函数，并传递参数。

#### 不足与改进
这只是第一个版本，功能比较寒酸，后续会不断进行修改拓展。
目前只支持WKWebView，没有对UIWebView进行适配。
还有不好的地方欢迎大家指正，渴望与大家一起学习，一起提高。


