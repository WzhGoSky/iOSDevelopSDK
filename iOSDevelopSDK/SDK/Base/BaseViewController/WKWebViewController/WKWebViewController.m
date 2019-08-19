//
//  WebViewController.m
//  Pods
//
//  Created by sun on 2017/7/18.
//
//

#import "WKWebViewController.h"
#import "globalDefine.h"

NSString *const kEstimatedProgressKey = @"estimatedProgress";
NSString *const kYtxUrlScheme = @"ytx"; //预留的特殊scheme

@interface WKWebViewController () <UIWebViewDelegate, WKUIDelegate>
{
    BOOL isInit; //是否初始化
}
@property (nonatomic, copy) WKWebViewControllerShareBlock shareBlock;



@end

@implementation WKWebViewController

#pragma mark - cycle


- (void)viewDidLoad {
    [super viewDidLoad];
    isInit = YES;
    [self setUpView];
    [self setUpKVO]; //监听
    [self initBridge];
    if (self.url) {
        [self loadPage];
    }
}

- (void)dealloc {
    if(isInit) {
        [self.webView removeObserver:self forKeyPath:kEstimatedProgressKey];
    }
    self.progressView.hidden = YES;
}
#pragma mark - setupUI

- (void)setUpView {
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.webView];
    [self setUpProgress];
    
}

- (void) setUpProgress {
    if (!self.progressView.hidden) {
        CGFloat progressBarHeight = 2.f;
        CGRect navigaitonBarBounds = CGRectMake(0, 0, SCREEN_WIDTH, NavBar_Height);
        CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height, navigaitonBarBounds.size.width, progressBarHeight);
        
        [self.view addSubview:self.progressView];
        self.progressView.frame = barFrame;
    }
}

- (WKWebView *)webView {
    if (!_webView) {
        
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.userContentController = [WKUserContentController new];
        
        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        configuration.preferences = preferences;
        
        _webView = [[WKWebView alloc]initWithFrame:CGRectZero configuration:configuration];
        _webView.UIDelegate = self;
        [_webView setBackgroundColor:[UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1.0]];
        [_webView setOpaque:NO];
        [self.view addSubview:_webView];
        
        _webView.frame = CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT - NavBar_Height);
        
    }
    return _webView;
}

- (void)onBackBtnClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - loadPage

- (void)setUrl:(NSURL *)url {
    //注意！！！这一步现在应该由外面注入 URLByAppendingUserBehaviorData
    _url = url;
    if ([self isViewLoaded]) {
        [self loadPage];
    }
}

- (void)loadPage {
    [self.webView stopLoading];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:0];
    
    [self.webView loadRequest:request];
    
    [self QXWebLoadPage];
    
    if ([self.delegate respondsToSelector:@selector(loadPage)]) {
        [self.delegate loadPage];
    }
}


#pragma mark - 进度条

- (UIProgressView *)progressView {
    if (_progressView == nil) {
        _progressView = [UIProgressView new];
        _progressView.progressViewStyle = UIProgressViewStyleBar;
        _progressView.tintColor = kThemeColor;
        _progressView.trackTintColor = self.navigationController.navigationBar.barTintColor;
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    return _progressView;
}

- (void)hideProgress {
    self.progressView.hidden = YES;
    [self.progressView setProgress:0];
}

#pragma mark - KVO

- (void)setUpKVO {
    [self.webView addObserver:self forKeyPath:kEstimatedProgressKey options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:kEstimatedProgressKey]) {
        self.progressView.hidden = (self.webView.estimatedProgress == 1);
        [self.progressView setProgress:self.webView.estimatedProgress];
    }
}

#pragma mark - bridge
- (void)initBridge {
    self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:self.webView];
    [self.bridge setWebViewDelegate:self];
    
}
#pragma mark - 追踪加载过程

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self QXWebDidStartLoadPage];
    if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.delegate webViewDidStartLoad:webView];
    }
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    [self QXWebCommitLoadPage];
    if ([self.delegate respondsToSelector:@selector(webViewCommitLoad:)]) {
        [self.delegate webViewCommitLoad:webView];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self QXWebDidEndLoadPage];
    if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.delegate webViewDidFinishLoad:webView];
    }
}

// 加载错误
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self hideProgress];
    [self QXWebErrorLoad];
    if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:webView didFailLoadWithError:error];
    }
}

#pragma mark - 页面处理的代理方法
// 在发送请求之前决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    NSURL *url = navigationAction.request.URL;
    NSString *scheme = [url scheme];
    if ([scheme isEqualToString:@"tel"] || [scheme isEqualToString:@"sms"]) {
        UIApplication * app = [UIApplication sharedApplication];
        if ([app canOpenURL:url]) {
            if ([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0) {
                [app openURL:url options:@{} completionHandler:nil];
            }else {
                [app openURL:url];
            }
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 在收到响应后决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
    
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    self.url = webView.URL;
    WKFrameInfo *frameInfo = navigationAction.targetFrame;
    if (![frameInfo isMainFrame]) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

#pragma mark - 页面弹出提示框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:prompt message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor redColor];
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[alert.textFields lastObject] text]);
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - 一些方法

- (void)goback {
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }else {
        [self QXWebBackWebView];
        if ([self.delegate respondsToSelector:@selector(webViewBack:)])
            [self.delegate webViewBack:self.webView];
    }
}

- (void)goForward {
    [self.webView goForward];
}

- (void)reload {
    // 第一次加载reload无法使用, 所以用这个
    NSURLRequest *request = [NSURLRequest requestWithURL:self.webView.URL ?: self.url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:0];
    [self.webView loadRequest:request];
}

#pragma mark - 给子类重写

- (void)QXWebLoadPage {}
- (void)QXWebDidStartLoadPage {}
- (void)QXWebCommitLoadPage {}
- (void)QXWebDidEndLoadPage {}
- (void)QXWebWebView:(WKWebView *)webView didFailLoadPage:(NSError *)error {}
- (void)QXWebErrorLoad {}

- (void)QXWebBackWebView {}

#pragma mark - 分享
- (void)enableShareAction {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(shareActionButttonTapped:)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13], NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
}

- (void)ngtEnableShareActionWithCompletionHandler:(WKWebViewControllerShareBlock)handler {
    [self enableShareAction];
    self.shareBlock = handler;
}

- (void)shareActionButttonTapped:(id)sender {
    if (self.shareBlock) {
        self.shareBlock();
    }
}
@end

