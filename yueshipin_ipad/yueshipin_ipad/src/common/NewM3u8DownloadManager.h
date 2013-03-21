//
//  DownloadManager.h
//  yueshipin
//
//  Created by joyplus1 on 13-1-31.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFDownloadRequestOperation.h"
#import "DownloadItem.h"

@interface NewM3u8DownloadManager : NSObject <DownloadingDelegate, SubdownloadingDelegate>
@property (nonatomic, strong)NSOperationQueue *queue;
@property (nonatomic, weak)id<DownloadingDelegate>delegate;
@property (nonatomic, weak)id<SubdownloadingDelegate>subdelegate;
- (void)startDownloadingThreads:(DownloadItem *)item;
- (void)stopDownloading;

@end
