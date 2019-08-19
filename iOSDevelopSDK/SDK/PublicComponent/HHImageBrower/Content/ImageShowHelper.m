//
//  ImageShowHelper.m
//  iOSDevelop
//
//  Created by Hayder on 2018/10/12.
//

#import "ImageShowHelper.h"
#define MASK_TAG 56000
#define WAIT_CONTENT_TAG 56001
#define WAITING_TAG 56002

@implementation ImageShowHelper

+ (void)showWaitingDialogWithMsg:(NSString *)msg container:(UIView *)containerView
{
    CGFloat contentWidth = 120;
    
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentWidth, contentWidth)];
    content.center = containerView.center;
    content.tag = WAIT_CONTENT_TAG;
    content.backgroundColor = [UIColor blackColor];
    content.alpha = 0.8f;
    content.layer.cornerRadius = 8;
    [containerView addSubview:content];
    
    CGFloat width = contentWidth;
    CGFloat height = 70;
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 10, width, height)];
    activityView.color = [UIColor whiteColor];
    activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    activityView.tag = WAITING_TAG;
    [content addSubview:activityView];
    [activityView startAnimating];
    
    UILabel *Label = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, contentWidth, 20)];
    Label.font = [UIFont systemFontOfSize:17];
    Label.textColor = [UIColor whiteColor];
    Label.textAlignment = NSTextAlignmentCenter;
    Label.text = msg;
    [content addSubview:Label];
}

+ (void)dismissWaitingDialogOnContainer:(UIView *)containerView
{
    UIView *mask = [containerView viewWithTag:MASK_TAG];
    UIView *content = [containerView viewWithTag:WAIT_CONTENT_TAG];
    UIView *waitingView = [containerView viewWithTag:WAITING_TAG];
    
    if (mask) {
        [mask removeFromSuperview];
    }
    
    if (content) {
        [content removeFromSuperview];
    }
    
    if (waitingView) {
        [waitingView removeFromSuperview];
    }
}

+ (void)showMessage:(NSString *)msg container:(UIView *)containerView
{
    UILabel *label = [[UILabel alloc] init];
    label.text = msg;
    label.font = [UIFont systemFontOfSize:15.f];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    
    label.layer.cornerRadius = 3.f;
    label.layer.masksToBounds = YES;
    
    CGSize size = [msg boundingRectWithSize:CGSizeMake(200.0f,MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : label.font} context:nil].size;
    
    CGFloat width = size.width + 10 * 2;
    CGFloat height = size.height + 20;
    
    label.frame = CGRectMake((CGRectGetWidth(containerView.frame) - width) / 2, (CGRectGetHeight(containerView.frame) - height)/2, width, height);
    [containerView addSubview:label];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:1.0f animations:^{
            label.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
    });
    
}
@end
