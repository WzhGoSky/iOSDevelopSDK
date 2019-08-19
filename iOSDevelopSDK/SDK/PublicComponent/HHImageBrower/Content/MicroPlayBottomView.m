
//
//  MicroPlayBottomView.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/6/7.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "MicroPlayBottomView.h"

#define imageNamed(imageName) [UIImage imageWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:[NSString stringWithFormat:@"%@@2x",imageName] ofType:@"png" inDirectory:@"KDImageShowManager.bundle"]]

@interface MicroPlayBottomView()


@end

@implementation MicroPlayBottomView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.startButton];
        [self addSubview:self.currentTime];
        [self addSubview:self.totalTime];
        [self addSubview:self.seekProgress];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

+ (instancetype) bottomView
{
    MicroPlayBottomView *view = [[MicroPlayBottomView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
    return view;
//    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
//    return [bundle loadNibNamed:@"MicroPlayBottomView" owner:self options:nil].firstObject;
}

- (void)seekTime:(UISlider *)sender {
    if ([self.delegate respondsToSelector:@selector(bottomBar:sliderChanged:)]) {
        if (sender.value >= sender.maximumValue) {
            
            [self.delegate bottomBar:self sliderChanged:sender.maximumValue];
            
        }else if(sender.value <= sender.minimumValue)
        {
            [self.delegate bottomBar:self sliderChanged:0.1];
        }else
        {
            [self.delegate bottomBar:self sliderChanged:sender.value];
        }
    }
    self.currentTime.text =  [NSString stringWithFormat:@"%02d:%02d",
                              (int)(sender.value * self.duration)/60.0,(int)(sender.value * self.duration)%60];
    
}
- (void)touchDown:(UISlider *)sender {
    
    if ([self.delegate respondsToSelector:@selector(bottomBarSliderTouchDown:)]) {
        [self.delegate bottomBarSliderTouchDown:self];
    }
}


- (void)touchUpInside:(UISlider *)sender {
    

    
    if ([self.delegate respondsToSelector:@selector(bottomBarSliderTouchUpInside:)]) {
        [self.delegate bottomBarSliderTouchUpInside:self];
    }
}

//- (IBAction)didClickSwitchEvent:(UIButton *)sender {
//
//    sender.selected = !sender.selected;
//
//    if ([self.delegate respondsToSelector:@selector(bottomBarDidClickSwitchButton:)]) {
//        [self.delegate bottomBarDidClickSwitchButton:self.startButton];
//    }
//
//}

-(void)startBtnClick:(UIButton *)btn{
    btn.selected = !btn.selected;

    if ([self.delegate respondsToSelector:@selector(bottomBarDidClickSwitchButton:)]) {
        [self.delegate bottomBarDidClickSwitchButton:self.startButton];
    }
}


#pragma lazy
-(UIButton *)startButton{
    if (!_startButton) {
        _startButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _startButton.frame = CGRectMake(0, 0, 40, self.frame.size.height);
        [_startButton addTarget:self action:@selector(startBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_startButton setImage:imageNamed(@"pause") forState:UIControlStateNormal];
        [_startButton setImage:imageNamed(@"play") forState:UIControlStateSelected];
    }
    return _startButton;
}

-(UILabel *)currentTime{
    if (!_currentTime) {
        _currentTime = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.startButton.frame), 0, 50, self.frame.size.height)];
        _currentTime.text = @"00:00";
        _currentTime.font = [UIFont systemFontOfSize:15];
        _currentTime.textColor = [UIColor whiteColor];
    }
    return _currentTime;
}

-(UILabel *)totalTime{
    if (!_totalTime) {
        _totalTime = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width - 10 - 50 , 0, 50, self.frame.size.height)];
        _totalTime.text = @"00:00";
        _totalTime.font = [UIFont systemFontOfSize:15];
        _totalTime.textColor = [UIColor whiteColor];
    }
    return _totalTime;
}


-(UISlider *)seekProgress{
    if (!_seekProgress) {
        _seekProgress = [[UISlider alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.currentTime.frame) + 10, 0, self.totalTime.frame.origin.x  - CGRectGetMaxX(self.currentTime.frame)  - 20, self.frame.size.height)];
        _seekProgress.tintColor = [UIColor colorWithRed:255.0 / 255.0 green:128 / 255.0 blue:0 alpha:1];
        [_seekProgress addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [_seekProgress addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_seekProgress addTarget:self action:@selector(seekTime:) forControlEvents:UIControlEventValueChanged];
    }
    return _seekProgress;
}


@end
