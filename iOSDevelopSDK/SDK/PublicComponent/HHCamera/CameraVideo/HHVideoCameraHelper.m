//
//  HHVideoCameraHelper.m
//  AFNetworking
//
//  Created by Hayder on 2018/11/21.
//

#import "HHVideoCameraHelper.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import "globalDefine.h"

@interface HHVideoCameraHelper()

@property (nonatomic, copy) generateGifImageBlock generateGifImage;

@property (strong, nonatomic) NSURL *videoUrl; // 视频的 url
@property (strong, nonatomic) AVAsset *videoAsset; // 视频的 AVAsset
@property (nonatomic, assign) Float64 frameRate; // 帧率
@property (assign, nonatomic) Float64 maxDuration; // 截取视频的最长时间
@property (nonatomic, assign) Float64 totalSeconds; // 总秒数
@property (nonatomic, assign) Float64 screenSeconds; // 当前屏幕显示的秒数
@property (assign, nonatomic) NSUInteger minImageCount;
@property (strong, nonatomic) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, strong) NSMutableArray *imagesArray;
@property (nonatomic, strong) NSString *gifName;
@end

@implementation HHVideoCameraHelper

+ (instancetype)getHelper
{
    return [[HHVideoCameraHelper alloc] init];
}

- (instancetype)init
{
    if (self = [super init]) {
        
        //创建folder
        NSString *imageDir = [NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)firstObject],@"gifCacheImages"];
        BOOL isDir = NO;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
        if ( !(isDir == YES && existed == YES) )
        {
            [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        [self addObserver:self forKeyPath:@"imagesArray" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

- (void)generateImagesInAsset:(AVAsset *)asset Completion:(generateGifImageBlock)completion
{
    self.generateGifImage = completion;
    self.imagesArray = [NSMutableArray array];
    CGFloat duration = CMTimeGetSeconds(asset.duration);
    self.maxDuration = duration;
    self.minImageCount = self.maxDuration*10;
    [self initFramesData:asset];
    
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    self.gifName = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
    
}

/**
 通过videoURL生成gif
 */
- (void)generateImagesWithVideoPath:(NSString *)videoPath Completion:(generateGifImageBlock)completion
{
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    self.generateGifImage = completion;
    self.imagesArray = [NSMutableArray array];
    CGFloat duration = CMTimeGetSeconds(asset.duration);
    self.maxDuration = duration;
    self.minImageCount = self.maxDuration*10;
    [self initFramesData:asset];
    
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    self.gifName = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
}

- (void)initFramesData:(AVAsset *)asset {
    CMTime cmtime = asset.duration;
    self.totalSeconds = CMTimeGetSeconds(cmtime);
    self.frameRate = [[asset tracksWithMediaType:AVMediaTypeVideo][0] nominalFrameRate];
    self.imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    NSUInteger imageCount = 0;
    if (self.totalSeconds <= self.maxDuration) {
        imageCount = _minImageCount;
        self.screenSeconds = self.totalSeconds;
    } else {
        imageCount = ceil(self.totalSeconds * _minImageCount / self.maxDuration);
        self.screenSeconds = self.maxDuration;
    }
    __weak typeof(self) weakSelf = self;
    [self getImagesCount:imageCount imageBackBlock:^(UIImage *image) {
        if ([image isKindOfClass:[UIImage class]]) {
            UIImage *scaledImg = [self OriginImage:image scaleToSize:150]; //不压缩，按原画质显示
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.imagesArray.count < 11) { //取10张
                    [[self mutableArrayValueForKey:@"imagesArray"] addObject:scaledImg];
                }
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.imagesArray.count < 11) { //取10张
                    [[self mutableArrayValueForKey:@"imagesArray"] addObject:[NSNull null]];
                }
            });
        }
    }];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"imagesArray"])
    {
        if (self.imagesArray.count == 10) {
            [self.imageGenerator cancelAllCGImageGeneration];
            __weak typeof(self) weakSelf = self;
            NSString *path = [self generalGifImgViewAction];
            if (weakSelf.generateGifImage) {
                weakSelf.generateGifImage(YES,path);
            }
        }
    }
}

- (void)getImagesCount:(NSUInteger)imageCount imageBackBlock:(void (^)(UIImage *))imageBackBlock {
    Float64 durationSeconds = self.totalSeconds;
    float fps = self.frameRate;
    
    NSMutableArray *times = [NSMutableArray array];
    Float64 totalFrames = durationSeconds * fps; //获得视频总帧数
    Float64 perFrames = totalFrames / imageCount; // 一共切imageCount张图
    Float64 frame = 0;
    
    CMTime timeFrame;
    while (frame < totalFrames) {
        timeFrame = CMTimeMake(frame, fps); //第i帧  帧率
        NSValue *timeValue = [NSValue valueWithCMTime:timeFrame];
        [times addObject:timeValue];
        
        frame += perFrames;
    }
    
    // 防止时间出现偏差
    self.imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    self.imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    self.imageGenerator.appliesPreferredTrackTransform = YES;  // 截图的时候调整到正确的方向
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
            switch (result) {
                    case AVAssetImageGeneratorCancelled:
                    {
                        
                    }
                    break;
                    case AVAssetImageGeneratorFailed:
                {
                    !imageBackBlock ? : imageBackBlock([NSNull null]);
                }
                    break;
                    case AVAssetImageGeneratorSucceeded: {
                        UIImage *displayImage = [UIImage imageWithCGImage:image];
                        !imageBackBlock ? : imageBackBlock(displayImage);
                    }
                    break;
            }
    }];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"imagesArray"];
}


-(UIImage*)OriginImage:(UIImage *)image scaleToSize:(CGFloat)width
{
    CGFloat orWidth = image.size.width;
    CGFloat orHeight = image.size.height;
    CGFloat height = width*orHeight/orWidth;
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContext(size);  //size 为CGSize类型，即你所需要的图片尺寸
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;   //返回的就是已经改变的图片
}

-(NSString *)generalGifImgViewAction{
    //图像目标
    NSString *imageDir = [NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)firstObject],@"gifCacheImages"];
    NSString *path = [imageDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.gif",self.gifName]];
    
    CFURLRef url = CFURLCreateWithFileSystemPath (kCFAllocatorDefault,
                                               (CFStringRef)path,
                                                kCFURLPOSIXPathStyle,
                                                  false);
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, self.imagesArray.count, NULL);
    
    NSDictionary *frameProperties = [NSDictionary
                                     dictionaryWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:0.1], (NSString *)kCGImagePropertyGIFDelayTime, nil]
                                     forKey:(NSString *)kCGImagePropertyGIFDictionary];
    
    //设置gif信息
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInt:0] forKey:(NSString*)kCGImagePropertyGIFLoopCount];
    [dict setObject:[NSNumber numberWithBool:YES] forKey:(NSString*)kCGImagePropertyGIFHasGlobalColorMap];
    [dict setObject:(NSString *)kCGImagePropertyColorModelRGB forKey:(NSString *)kCGImagePropertyColorModel];
    [dict setObject:[NSNumber numberWithInt:8] forKey:(NSString*)kCGImagePropertyDepth];
    NSDictionary *gifProperties = [NSDictionary dictionaryWithObject:dict
                                                              forKey:(NSString *)kCGImagePropertyGIFDictionary];
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)gifProperties);
    //合成gif
    for (UIImage* dImg in self.imagesArray)
    {
        if ([dImg isKindOfClass:[UIImage class]]) {
            CGImageDestinationAddImage(destination, dImg.CGImage, (__bridge CFDictionaryRef)frameProperties);
        }
    }
    
    CGImageDestinationFinalize(destination);
    CFRelease(destination);
    
    return path;
}


+ (BOOL)deleteFileWithName:(NSString *)gifName
{
    NSString *imageDir = [NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)firstObject],@"gifCacheImages"];
    NSString *filePath = nil;
    if ([gifName containsString:@".gif"]) {
        filePath = [imageDir stringByAppendingString:gifName];
    }else
    {
        filePath = [imageDir stringByAppendingString:[NSString stringWithFormat:@"%@.gif",gifName]];
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]) {
       return [manager removeItemAtPath:filePath error:nil];
    }else
    {
        return NO;
    }
}

//获取对应的时间
+ (NSString *)currentDateStringWithFormat:(NSString *)formatterStr {
    // 获取系统当前时间
    NSDate *currentDate = [NSDate date];
    // 用于格式化NSDate对象
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置格式：yyyy-MM-dd HH:mm:ss
    formatter.dateFormat = formatterStr;
    // 将 NSDate 按 formatter格式 转成 NSString
    NSString *currentDateStr = [formatter stringFromDate:currentDate];
    // 输出currentDateStr
    return currentDateStr;
}

@end
