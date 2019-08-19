//
//  Target_NotFound.m
//  AFNetworking
//
//  Created by Hayder on 2019/5/8.
//

#import "Target_NotFound.h"
#import "TargetNotFoundViewController.h"

@implementation Target_NotFound

- (UIViewController *)targetNotFundation:(NSDictionary *)params
{
    NSLog(@"*****************************");
    NSLog(@"TargetName: %@ NotFound",params[@"TargetName"]);
    NSLog(@"actionName: %@ NotFound",params[@"actionName"]);
    NSLog(@"*****************************");
    
    TargetNotFoundViewController *vc = [[TargetNotFoundViewController alloc]init];
    vc.errorTitle = [NSString stringWithFormat:@"TargetName: %@ NotFound",params[@"TargetName"]];
    return vc;
}
@end
