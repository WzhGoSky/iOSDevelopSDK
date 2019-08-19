//
//  ViewController.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/5.
//  Copyright © 2019 Hayder. All rights reserved.
//

#import "ViewController.h"
#import "HHNormalCamera.h"
#import "globalDefine.h"
#import "HHVideoCamera.h"
#import "ExampleTableRefreshView.h"
#import "PickerManager.h"

@interface ViewController ()<HHNormalCameraDelegate,HHVideoCameraDelegate>

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    PickerManagerConfig *config = [PickerManagerConfig defaultPickerConfig];
    config.type = PickerMangerTypeAlbum | PickerMangerTypeTakePhoto | PickerMangerTypeShortVideo;
    config.allowPickingVideo = YES;
    config.takePhotoEdit = NO;
    config.qualityLevel = QualityLevelHigh;
    config.maxPhotoCount = 12;
    
    [PickerManager showPickerWithConfig:config selectArray:[NSMutableArray array] containView:self.view complete:^(NSMutableArray<PickerModel *> *datas, NSError *error, BOOL isSelectOriginalPhoto) {
        
        [datas removeAllObjects];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
//    [button setTitle:@"测试" forState:UIControlStateNormal];
//    button.frame = CGRectMake(100, 100, 100, 100);
//    [button addTarget:self action:@selector(cameraEvent:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button];
    
//    ExampleTableRefreshView *view = [[ExampleTableRefreshView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
//    view.tableView.backgroundColor = [UIColor redColor];
//    [self.view addSubview:view];
    /*
     PickerMangerTypeAlbum                                                         = 1 << 0,//相册
     PickerMangerTypeTakePhoto                                                          = 1 << 1,//拍照
     PickerMangerTypeShortVideo
     */
}


- (void)cameraEvent:(UIButton *)sender {
    
    //照相机
//    HHAVKitOption *option = [[HHAVKitOption alloc] initOnPhotoModeWithSessionPreset:SessionPresetMedium MaxPhotoCount:12];
//    HHNormalCamera *camera = [[HHNormalCamera alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) Option:option];
//    camera.delegate = self;
//    [camera showOnContainer:self.view];
    
    //摄像机
    HHAVKitOption *option = [[HHAVKitOption alloc] initOnVideoModeWithQualityLevel:QualityLevelMedium MaxSecond:15];
    HHVideoCamera *videoCamera = [[HHVideoCamera alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) Option:option];
    videoCamera.delegate = self;
    [videoCamera showOnContainer:self.view];
}

#pragma mark ---------------------HHNormalCameraDelegate----------------------------
- (void)normalCamera:(HHNormalCamera *)camera didFinishedTakingPhoto:(NSArray *)photos
{
    NSLog(@"%@",photos);
}

- (void)microVideoPath:(NSString *)savePath thumbImage:(UIImage *)image gifFaceURL:(NSString *)imagePath
{
    NSLog(@"%@",savePath);
    NSLog(@"%@",image);
    NSLog(@"%@",imagePath);
}

@end
