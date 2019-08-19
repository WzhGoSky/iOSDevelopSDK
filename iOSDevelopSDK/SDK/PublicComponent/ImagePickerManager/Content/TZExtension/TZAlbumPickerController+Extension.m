//
//  TZAlbumPickerController+Extension.m
//  PublicComponent
//
//  Created by Hayder on 2018/10/15.
//

#import "TZAlbumPickerController+Extension.h"
#import "TZImagePickerController+Extension.h"
#import "TZPhotoPickerController+Extension.h"
#import <objc/runtime.h>

//static char *needGetModelsKey = "AlbumPickerNeedGetModelsKey";
//static char *needOriginalKey = "AlbumPickerNeedOriginalKey";


@implementation TZAlbumPickerController (Extension)

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    self.isFirstAppear = YES;
//    self.view.backgroundColor = [UIColor whiteColor];
//
//    TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.navigationController;
//    self.needGetModels = imagePickerVc.needGetModels;
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:imagePickerVc.cancelBtnTitleStr style:UIBarButtonItemStylePlain target:imagePickerVc action:@selector(cancelButtonClick)];
//}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    TZPhotoPickerController *photoPickerVc = [[TZPhotoPickerController alloc] init];
//    photoPickerVc.columnNumber = [[self valueForKey:@"columnNumber"] integerValue];
//    TZAlbumModel *model = [self valueForKey:@"albumArr"][indexPath.row];
//    photoPickerVc.model = model;
//    photoPickerVc.needGetModels = self.needGetModels;
//    photoPickerVc.needOriginal = self.needOriginal;
//    [self.navigationController pushViewController:photoPickerVc animated:YES];
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//}

//-(void)setNeedGetModels:(BOOL)needGetModels{
//    objc_setAssociatedObject(self, needGetModelsKey, [NSString stringWithFormat:@"%d",needGetModels], OBJC_ASSOCIATION_ASSIGN);
//}
//
//-(void)setNeedOriginal:(BOOL)needOriginal{
//    objc_setAssociatedObject(self, needOriginalKey, [NSString stringWithFormat:@"%d",needOriginal], OBJC_ASSOCIATION_ASSIGN);
//}
//
//-(BOOL)needOriginal{
//
//    id temp1 = objc_getAssociatedObject(self, needOriginalKey);
//    BOOL temp = [temp1 boolValue];
//    return temp;
//}
//
//
//-(BOOL)needGetModels{
//    id temp1 = objc_getAssociatedObject(self, needGetModelsKey);
//    BOOL temp = [temp1 boolValue];
//    return temp;
//}


@end
