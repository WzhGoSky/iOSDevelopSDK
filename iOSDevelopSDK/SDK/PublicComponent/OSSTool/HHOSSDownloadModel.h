//
//  HHOSSDownloadModel.h
//  AFNetworking
//
//  Created by Hayder on 2018/12/18.
//

#import <Foundation/Foundation.h>

@interface HHOSSDownloadModel : NSObject
/**
 需要下载的url
 */
@property (nonatomic, copy) NSString *fileURL;

/**下载完后*/
@property (nonatomic, copy) NSString *fileLocalpath;

@end

