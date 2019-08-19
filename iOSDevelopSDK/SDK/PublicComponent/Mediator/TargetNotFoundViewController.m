//
//  TargetNotFoundViewController.m
//  AFNetworking
//
//  Created by Hayder on 2019/5/27.
//

#import "TargetNotFoundViewController.h"

@interface TargetNotFoundViewController ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation TargetNotFoundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.titleLabel];
}

-(void)setErrorTitle:(NSString *)errorTitle{
    _errorTitle = errorTitle;
    self.titleLabel.text = errorTitle;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:self.view.bounds];
        _titleLabel.font = [UIFont systemFontOfSize:20];
    }
    return _titleLabel;
}


@end
