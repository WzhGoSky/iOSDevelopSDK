//
//  HHOSSDownloadTool.m
//  AFNetworking
//
//  Created by Hayder on 2018/11/22.
//

#import "HHOSSDownloadCenter.h"
#import "HHOSSNetWorkTool.h"
//#import "globalDefine.h"

@interface HHOSSDownloadCenter()

@property (nonatomic, weak) id<HHOSSDownloadCenterDelegate> delegate;

@property (nonatomic, assign) BOOL isAutoDownload;

@property (nonatomic, strong) NSArray<NSString *> *downLoadFileURLs;

/**已下载的本地文件映射*/
@property (nonatomic, strong) NSMutableDictionary *localDownloadedMap;

@property (nonatomic, strong) NSString *localDownloadMapPath;

@property (nonatomic, strong) NSString *downloadFolder;

@property (nonatomic, strong) NSMutableDictionary *currentDownloadURLTaskMap;

@property (nonatomic, strong) NSMutableDictionary *totalBytesExpectedToSendMap;

//取消下载
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UIView *showView;

@end

@implementation HHOSSDownloadCenter

+ (instancetype)instance
{
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[HHOSSDownloadCenter alloc] init];
    });
    return _instance;
}
/**
 使用默认方式下载文件 带进度条
 @param fileModels 需要下载的文件对象
 @param completion 下载结束
 */
- (void)downloadWithModelFiles:(NSArray <HHOSSDownloadModel *>*)fileModels HUDInView:(UIView *)inView Completion:(void (^)(BOOL isSuccessed,NSArray <HHOSSDownloadModel *> *fileModels)) completion
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.downloadFolder isDirectory:nil]) { //下载文件夹不在 就创建文件夹
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:self.downloadFolder withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    self.currentDownloadURLTaskMap = [NSMutableDictionary dictionary];
    self.totalBytesExpectedToSendMap = [NSMutableDictionary dictionary];
    
    MBProgressHUD *hud = nil;
    hud = [HHOSSToolHelper HH_showProgressWithDescroption:@"文件下载中" withView:inView];
    hud.userInteractionEnabled = YES;
    hud.dimBackground = YES;
    [inView addSubview:self.cancelButton];
    [inView bringSubviewToFront:self.cancelButton];
    self.showView = inView;
    
    dispatch_group_t group = dispatch_group_create();
    for (int i=0; i<fileModels.count; i++) {
        dispatch_group_enter(group);
        HHOSSDownloadModel *file = fileModels[i];
        NSString *urlString = file.fileURL;
        NSString *fileName = [urlString lastPathComponent];
        OSSGetObjectRequest *request = [HHOSSNetWorkTool OSSDownLoadDataWithName:fileName progress:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            CGFloat progress = totalBytesSent/(totalBytesExpectedToSend*1.0);
            [self.totalBytesExpectedToSendMap setObject:[NSString stringWithFormat:@"%lld",totalBytesExpectedToSend] forKey:urlString];
            hud.labelText = [NSString stringWithFormat:@"%@:%d",@"文件",i+1];
            hud.detailsLabelText = [NSString stringWithFormat:@"%@:%.1f%%",@"当前文件进度",progress*100];
        } success:^(OSSTask *task, NSData *downloadedData) {
            //保存下当前已下载的文件
            [self.localDownloadedMap setObject:fileName forKey:urlString];
            [self saveData:self.localDownloadedMap];
            //把文件写到目录
            NSString *filePath = [self.downloadFolder stringByAppendingPathComponent:fileName];
            //保存文件
            [downloadedData writeToFile:filePath atomically:YES];
            //下载完毕
            file.fileLocalpath = filePath;
            //删除request
            [self.currentDownloadURLTaskMap removeObjectForKey:urlString];
            
            dispatch_group_leave(group);
        } error:^(OSSTask *task, NSError *error) {
            [self.currentDownloadURLTaskMap removeObjectForKey:urlString];
            dispatch_group_leave(group);
        }];
        //保存下
        [self.currentDownloadURLTaskMap setObject:request forKey:urlString];
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        [HHOSSToolHelper HH_hideActivityHUDInContainView:inView];
        [self.cancelButton removeFromSuperview];
        
        BOOL isSuccessed = YES;
        for (HHOSSDownloadModel *file in fileModels) {
            if (!file.fileLocalpath) {
                isSuccessed = NO;
                break;
            }
        }
        
        if (completion) {
            completion(isSuccessed,fileModels);
        }
        
        //保存下载的文件映射
        [self saveData:self.localDownloadedMap];
        
    });
}

/**
 使用默认方式下载文件 带进度条
 @param files 需要下载的文件对象
 @param completion 下载结束
 */
- (void)downloadWithFiles:(NSArray <id<HHOSSDownloadAble>>*)files HUDInView:(UIView *)inView Completion:(void (^)(BOOL isSuccessed,NSArray <id<HHOSSDownloadAble>>* files)) completion
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.downloadFolder isDirectory:nil]) { //下载文件夹不在 就创建文件夹
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:self.downloadFolder withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    self.currentDownloadURLTaskMap = [NSMutableDictionary dictionary];
    self.totalBytesExpectedToSendMap = [NSMutableDictionary dictionary];
    
    MBProgressHUD *hud = nil;
    hud = [HHOSSToolHelper HH_showProgressWithDescroption:@"文件下载中" withView:inView];
    hud.userInteractionEnabled = YES;
    hud.dimBackground = YES;
    [inView addSubview:self.cancelButton];
    [inView bringSubviewToFront:self.cancelButton];
    self.showView = inView;
    
    dispatch_group_t group = dispatch_group_create();
    for (int i=0; i<files.count; i++) {
        id<HHOSSDownloadAble> file = files[i];
        if ([file respondsToSelector:@selector(getDownloadURL)]) {
            dispatch_group_enter(group);
            NSString *urlString = [file getDownloadURL];
            NSString *fileName = [urlString lastPathComponent];
            OSSGetObjectRequest *request = [HHOSSNetWorkTool OSSDownLoadDataWithName:fileName progress:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                CGFloat progress = totalBytesSent/(totalBytesExpectedToSend*1.0);
                [self.totalBytesExpectedToSendMap setObject:[NSString stringWithFormat:@"%lld",totalBytesExpectedToSend] forKey:urlString];
                hud.labelText = [NSString stringWithFormat:@"%@:%d",@"文件",i+1];
                hud.detailsLabelText = [NSString stringWithFormat:@"%@:%.1f%%",@"当前文件进度",progress*100];
            } success:^(OSSTask *task, NSData *downloadedData) {
                //保存下当前已下载的文件
                [self.localDownloadedMap setObject:fileName forKey:urlString];
                [self saveData:self.localDownloadedMap];
                //把文件写到目录
                NSString *filePath = [self.downloadFolder stringByAppendingPathComponent:fileName];
                //保存文件
                [downloadedData writeToFile:filePath atomically:YES];
                //下载完毕
                file.fileLocalpath = filePath;
                //删除request
                [self.currentDownloadURLTaskMap removeObjectForKey:urlString];
                
                dispatch_group_leave(group);
            } error:^(OSSTask *task, NSError *error) {
                [self.currentDownloadURLTaskMap removeObjectForKey:urlString];
                dispatch_group_leave(group);
            }];
            //保存下
            [self.currentDownloadURLTaskMap setObject:request forKey:urlString];
        }
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            
            [HHOSSToolHelper HH_hideActivityHUDInContainView:inView];
            [self.cancelButton removeFromSuperview];
            
            BOOL isSuccessed = YES;
            for (id<HHOSSDownloadAble> file in files) {
                if (!file.fileLocalpath) {
                    isSuccessed = NO;
                    break;
                }
            }
            
            if (completion) {
                completion(isSuccessed,files);
            }
            
            //保存下载的文件映射
            [self saveData:self.localDownloadedMap];
        });
    }
}
/**
 下载方法
 @param files 下载文件
 @param delegate 回调代理
 */
- (void)downloadWithFiles:(NSArray <id<HHOSSDownloadAble>>*)files delegate:(id<HHOSSDownloadCenterDelegate>) delegate
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.downloadFolder isDirectory:nil]) { //下载文件夹不在 就创建文件夹
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:self.downloadFolder withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    self.currentDownloadURLTaskMap = [NSMutableDictionary dictionary];
    self.totalBytesExpectedToSendMap = [NSMutableDictionary dictionary];
    
    HHOSSDownloadCenter *center = [HHOSSDownloadCenter instance];
    center.delegate = delegate;
    [self downloadWithFiles:files];
}

/**
 下载方法
 @param files 下载文件
 @param delegate 回调代理
 */
- (void)downloadWithModelFiles:(NSArray <HHOSSDownloadModel *>*)files delegate:(id<HHOSSDownloadCenterDelegate>)delegate
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.downloadFolder isDirectory:nil]) { //下载文件夹不在 就创建文件夹
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:self.downloadFolder withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    self.currentDownloadURLTaskMap = [NSMutableDictionary dictionary];
    self.totalBytesExpectedToSendMap = [NSMutableDictionary dictionary];
    
    HHOSSDownloadCenter *center = [HHOSSDownloadCenter instance];
    center.delegate = delegate;
    [self downloadWithModelFiles:files];
}

- (void)downloadWithModelFiles:(NSArray<HHOSSDownloadModel *> *)files
{
    dispatch_group_t group = dispatch_group_create();
    for (HHOSSDownloadModel *file in files) {
            dispatch_group_enter(group);
            NSString *urlString = file.fileURL;
            NSString *fileName = [urlString lastPathComponent];
            OSSGetObjectRequest *request = [HHOSSNetWorkTool OSSDownLoadDataWithName:fileName progress:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                CGFloat progress = totalBytesSent/(totalBytesExpectedToSend*1.0);
                [self.totalBytesExpectedToSendMap setObject:[NSString stringWithFormat:@"%lld",totalBytesExpectedToSend] forKey:urlString];
                if (progress<1.0) {
                    if ([self.delegate respondsToSelector:@selector(downloadProgress:WithCurrentDownloadUrl:FileTotalSize:)]) {
                        [self.delegate downloadProgress:progress WithCurrentDownloadUrl:urlString FileTotalSize:[self calDownloadFileSize:[NSString stringWithFormat:@"%lld",totalBytesExpectedToSend]]];
                    }
                }
            } success:^(OSSTask *task, NSData *downloadedData) {
                //保存下当前已下载的文件
                [self.localDownloadedMap setObject:fileName forKey:urlString];
                [self saveData:self.localDownloadedMap];
                //把文件写到目录
                NSString *filePath = [self.downloadFolder stringByAppendingPathComponent:fileName];
                //保存文件
                [downloadedData writeToFile:filePath atomically:YES];
                //下载完毕
                file.fileLocalpath = filePath;
                //下载完毕
                if ([self.delegate respondsToSelector:@selector(downloadProgress:WithCurrentDownloadUrl:FileTotalSize:)]) {
                    NSString *totalSize = [self.totalBytesExpectedToSendMap objectForKey:urlString];
                    [self.delegate downloadProgress:1.0 WithCurrentDownloadUrl:urlString FileTotalSize:[self calDownloadFileSize:totalSize]];
                }
                
                //删除request
                [self.currentDownloadURLTaskMap removeObjectForKey:urlString];
                
                dispatch_group_leave(group);
            } error:^(OSSTask *task, NSError *error) {
                [self.currentDownloadURLTaskMap removeObjectForKey:urlString];
                dispatch_group_leave(group);
            }];
            //保存下
            [self.currentDownloadURLTaskMap setObject:request forKey:urlString];
        }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //保存下载的文件映射
        [self saveData:self.localDownloadedMap];
        
    });
}

- (void)downloadWithFiles:(NSArray<id<HHOSSDownloadAble>> *)files
{
    dispatch_group_t group = dispatch_group_create();
    for (id<HHOSSDownloadAble> file in files) {
        if ([file respondsToSelector:@selector(getDownloadURL)]) {
            dispatch_group_enter(group);
            NSString *urlString = [file getDownloadURL];
            NSString *fileName = [urlString lastPathComponent];
            OSSGetObjectRequest *request = [HHOSSNetWorkTool OSSDownLoadDataWithName:fileName progress:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                CGFloat progress = totalBytesSent/(totalBytesExpectedToSend*1.0);
                [self.totalBytesExpectedToSendMap setObject:[NSString stringWithFormat:@"%lld",totalBytesExpectedToSend] forKey:urlString];
                if (progress<1.0) {
                    if ([self.delegate respondsToSelector:@selector(downloadProgress:WithCurrentDownloadUrl:FileTotalSize:)]) {
                        [self.delegate downloadProgress:progress WithCurrentDownloadUrl:urlString FileTotalSize:[self calDownloadFileSize:[NSString stringWithFormat:@"%lld",totalBytesExpectedToSend]]];
                    }
                }
            } success:^(OSSTask *task, NSData *downloadedData) {
                //保存下当前已下载的文件
                [self.localDownloadedMap setObject:fileName forKey:urlString];
                [self saveData:self.localDownloadedMap];
                //把文件写到目录
                NSString *filePath = [self.downloadFolder stringByAppendingPathComponent:fileName];
                //保存文件
                [downloadedData writeToFile:filePath atomically:YES];
                //下载完毕
                file.fileLocalpath = filePath;
                //下载完毕
                if ([self.delegate respondsToSelector:@selector(downloadProgress:WithCurrentDownloadUrl:FileTotalSize:)]) {
                    NSString *totalSize = [self.totalBytesExpectedToSendMap objectForKey:urlString];
                    [self.delegate downloadProgress:1.0 WithCurrentDownloadUrl:urlString FileTotalSize:[self calDownloadFileSize:totalSize]];
                }
                
                //删除request
                [self.currentDownloadURLTaskMap removeObjectForKey:urlString];
                
                dispatch_group_leave(group);
            } error:^(OSSTask *task, NSError *error) {
                [self.currentDownloadURLTaskMap removeObjectForKey:urlString];
                dispatch_group_leave(group);
            }];
            //保存下
            [self.currentDownloadURLTaskMap setObject:request forKey:urlString];
        }
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //保存下载的文件映射
        [self saveData:self.localDownloadedMap];
        
    });
}

- (NSString *)calDownloadFileSize:(NSString *)bytesize
{
    NSInteger size = bytesize.integerValue;
    NSString *sizeStr = @"";
    
    if (size < 1024) {
        sizeStr = [NSString stringWithFormat:@"%ld B", size];
    } else if (size >= 1024 && size < 1024 * 1024) {
        sizeStr = [NSString stringWithFormat:@"%.2f KB", size / 1024.0];
    } else if (size >= 1024 * 1024 && size < 1024 * 1024 * 1024) {
        sizeStr = [NSString stringWithFormat:@"%.2f MB", size / (1024 * 1024.0)];
    } else {
        sizeStr = [NSString stringWithFormat:@"%.2f GB", size / (1024 * 1024 * 1024.0)];
    }
    
    return sizeStr;
}



/**通过url获取本地用户文件 存在返回绝对路径,不存在返回nil*/
+ (NSString *)getLocalFileWithFileURL:(NSString *)url
{
    NSString *fileName = [[HHOSSDownloadCenter instance].localDownloadedMap objectForKey:url];
    if (fileName) {
        return [[HHOSSDownloadCenter instance].downloadFolder stringByAppendingPathComponent:fileName];
    }else
    {
        return nil;
    }
}

/**
 根据url删除本地下载的文件
 */
+ (BOOL)deleteLocalFileWithFileURL:(NSString *)url
{
    NSString *fileName = [[HHOSSDownloadCenter instance].localDownloadedMap objectForKey:url];
    if (fileName) {
        NSString *filePath = [[HHOSSDownloadCenter instance].downloadFolder stringByAppendingPathComponent:fileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) { //下载文件夹不在
            NSError *error;
            [[HHOSSDownloadCenter instance].localDownloadedMap removeObjectForKey:url];
            [[HHOSSDownloadCenter instance] saveData:[HHOSSDownloadCenter instance].localDownloadedMap];
            return [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        }else
        {
            return YES;
        }
    }else
    {
        NSLog(@"=====本地没有这个文件======");
        return YES;
    }
}

/**
 删除本地所有文件
 */
+ (BOOL)deleteLocalFile
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[HHOSSDownloadCenter instance].downloadFolder]) { //下载文件夹不在 就创建文件夹
        NSError *error;
        [[HHOSSDownloadCenter instance].localDownloadedMap removeAllObjects];//移除所有的路径
        //保存
        [[HHOSSDownloadCenter instance] saveData:[HHOSSDownloadCenter instance].localDownloadedMap];
        return [[NSFileManager defaultManager] removeItemAtPath:[HHOSSDownloadCenter instance].downloadFolder error:&error];
    }else
    {
        NSLog(@"=====文件夹已经被删除======");
        return YES;
    }
}
/**
 根据URL取消下载任务
 */
- (void)cancelTaskWithURL:(NSString *)url
{
    OSSGetObjectRequest *request = [self.currentDownloadURLTaskMap objectForKey:url];
    [request cancel];
}

/**
 取消所有的任务
 */
- (void)cancelAllTask
{
    [HHOSSToolHelper HH_hideActivityHUDInContainView:self.showView];
    [self.cancelButton removeFromSuperview];
    
    NSArray *requestList = self.currentDownloadURLTaskMap.allValues;
    for (OSSGetObjectRequest *request in requestList) {
        [request cancel];
    }
}

#pragma mark ---------------------getter-----------------------------------------
- (NSMutableDictionary *)localDownloadedMap
{
    if (!_localDownloadedMap) {
        _localDownloadedMap = [NSMutableDictionary dictionary];
        NSDictionary *map = (NSDictionary *)[self loadLocalDownloadMap];
        if (map) {
            _localDownloadedMap = [NSMutableDictionary dictionaryWithDictionary:map];
        }
    }
    return _localDownloadedMap;
}

//草稿归解档
- (BOOL)saveData:(NSObject *)data
{
    if (data == nil) {
        NSLog(@"-------=====存入的数据不能为nil======--------");
        return NO;
    }
    //不可归档对象
    if ([data isKindOfClass:[NSDictionary class]] || [data isKindOfClass:[NSArray class]]) {
        return [NSKeyedArchiver archiveRootObject:data toFile:self.localDownloadMapPath];
    }else
    {
        return NO;
    }
}
- (NSObject *)loadLocalDownloadMap
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:self.localDownloadMapPath];
}

//保存的下载映射路径
- (NSString *)localDownloadMapPath
{
    if(!_localDownloadMapPath)
    {
        NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        _localDownloadMapPath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"OSSDownloadFolder/%@_downloadMap",@"userId"]];
    }
    return _localDownloadMapPath;
}

//获取下载的文件夹
- (NSString *)downloadFolder
{
    if(!_downloadFolder)
    {
        NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        _downloadFolder = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"OSSDownloadFolder/%@",@"userId"]];
    }
    return _downloadFolder;
}

- (UIButton *)cancelButton
{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:@"取消下载" forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
        _cancelButton.layer.cornerRadius = 5;
        _cancelButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _cancelButton.layer.borderWidth = 1;
        CGFloat w = [UIScreen mainScreen].bounds.size.width;
        CGFloat h = [UIScreen mainScreen].bounds.size.height;
        _cancelButton.frame = CGRectMake((w-80)/2, h-50-30, 80, 50);
        [_cancelButton addTarget:self action:@selector(cancelAllTask) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

@end
