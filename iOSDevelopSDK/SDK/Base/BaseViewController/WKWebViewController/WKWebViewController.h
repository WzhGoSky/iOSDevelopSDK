//
//  WebViewController.h
//  Pods
//
//  Created by sun on 2017/7/18.
//
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "WKWebViewJavascriptBridge.h"
#import "HHBaseViewController.h"

typedef void(^WKWebViewControllerShareBlock)(void);
@protocol WKWebViewControllerDelegate <NSObject>

@optional
- (void)loadPage;

- (void)webViewDidStartLoad:(WKWebView *)webView;
- (void)webViewCommitLoad:(WKWebView *)webView;
- (void)webViewDidFinishLoad:(WKWebView *)webView;
- (void)webView:(WKWebView *)webView didFailLoadWithError:(NSError *)error;

// 不能返回的时候的代理
- (void)webViewBack:(WKWebView *)webView;
@end

@interface WKWebViewController : HHBaseViewController

/**标题*/
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView * progressView;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) UIViewController *containerViewController;
@property (nonatomic, strong) WKWebViewJavascriptBridge *bridge;
@property (weak, nonatomic) id <WKWebViewControllerDelegate>delegate;

- (void)ngtEnableShareActionWithCompletionHandler:(WKWebViewControllerShareBlock)handler;


- (void)goback;
- (void)goForward;
- (void)reload;

// 子类调用
- (void)QXWebLoadPage;
- (void)QXWebDidStartLoadPage;
- (void)QXWebCommitLoadPage;
- (void)QXWebDidEndLoadPage;
- (void)QXWebWebView:(WKWebView *)webView didFailLoadPage:(NSError *)error;
- (void)QXWebErrorLoad;

- (void)QXWebBackWebView;
@end
