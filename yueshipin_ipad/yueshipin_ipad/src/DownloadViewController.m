//
//  DownloadViewController.m
//  yueshipin
//
//  Created by joyplus1 on 12-12-19.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "DownloadViewController.h"
#import "CommonHeader.h"
#import "DownloadItem.h"
#import "GMGridView.h"
#import "SubdownloadViewController.h"
#import "SQLiteInstanceManager.h"
#import "MyMediaPlayerViewController.h"
#import "AFDownloadRequestOperation.h"
#import "AVPlayerViewController.h"

@interface DownloadViewController ()<GMGridViewDataSource, GMGridViewActionDelegate, DownloadingDelegate>{
    UIImageView *topImage;
    UIImageView *topIcon;
    UIImageView *bgImage;
    UIImageView *nodownloadImage;
    
    int leftWidth;
    
    UIButton *editBtn;
    UIButton *doneBtn;;
    
    __gm_weak GMGridView *_gmGridView;
}
@end

@implementation DownloadViewController


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    topImage = nil;
    bgImage = nil;
    _gmGridView = nil;
    
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    closeMenuRecognizer.delegate = self;
//    [self.view addGestureRecognizer:closeMenuRecognizer];
    [self.view addGestureRecognizer:swipeCloseMenuRecognizer];
    [self.view addGestureRecognizer:openMenuRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]){
        return NO;
    } else if([NSStringFromClass([touch.view class]) isEqualToString:@"UIButton"]){
        return NO;
    } else {
        for (int i = 0; i < [AppDelegate instance].downloadItems.count; i++) {
            CGPoint pt = [touch locationInView:self.view];
            GMGridViewCell *cell = [_gmGridView cellForItemAtIndex:i];
            CGPoint ptInbtn = [self.view convertPoint:pt toView:cell];
            BOOL inor = [cell pointInside:ptInbtn withEvent:nil];
            if (inor) {
                return inor;
            }        
        }
        return YES;
    }
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
		[self.view setFrame:frame];
        [self.view setBackgroundColor:[UIColor clearColor]];
        
        bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 24)];
        bgImage.image = [UIImage imageNamed:@"left_background"];
        [self.view addSubview:bgImage];
        
        nodownloadImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
        nodownloadImage.center = CGPointMake(bgImage.center.x, bgImage.center.y - 100);
        nodownloadImage.image = [UIImage imageNamed:@"nodownload"];
        [self.view addSubview:nodownloadImage];
        
        leftWidth = 80;
        [self.view addSubview:menuBtn];
        
        topImage = [[UIImageView alloc]initWithFrame:CGRectMake(leftWidth + 50, 40, 143, 35)];
        topImage.image = [UIImage imageNamed:@"download_title"];
        [self.view addSubview:topImage];
        
        topIcon = [[UIImageView alloc]initWithFrame:CGRectMake(leftWidth, 40, 32, 32)];
        topIcon.image = [UIImage imageNamed:@"download_icon"];
        [self.view addSubview:topIcon];
        
        editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        editBtn.frame = CGRectMake(410, 80, 74, 26);
        [editBtn setBackgroundImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
        [editBtn setBackgroundImage:[UIImage imageNamed:@"edit_pressed"] forState:UIControlStateHighlighted];
        [editBtn addTarget:self action:@selector(editBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:editBtn];
        
        doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        doneBtn.frame = editBtn.frame;
        [doneBtn setBackgroundImage:[UIImage imageNamed:@"done"] forState:UIControlStateNormal];
        [doneBtn setBackgroundImage:[UIImage imageNamed:@"done_pressed"] forState:UIControlStateHighlighted];
        [doneBtn addTarget:self action:@selector(doneBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [doneBtn setHidden:YES];
        [self.view addSubview:doneBtn];
        
        [self reloadItems];
        GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:CGRectMake(LEFT_WIDTH, 110, 450, 610)];
        gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        gmGridView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:gmGridView];
        _gmGridView = gmGridView;
        
        NSInteger spacing = 30;
        _gmGridView.style = GMGridViewStyleSwap;
        _gmGridView.itemSpacing = spacing;
        _gmGridView.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
        _gmGridView.centerGrid = NO;
        _gmGridView.actionDelegate = self;
        _gmGridView.dataSource = self;
        _gmGridView.mainSuperView = self.view;
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([AppDelegate instance].closed) {
        [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu_btn"] forState:UIControlStateNormal];
    } else {
        [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu_btn_pressed"] forState:UIControlStateNormal];
    }
    _gmGridView.editing = NO;
    if ([AppDelegate instance].downloadItems.count > 0) {
        [editBtn setHidden:NO];
        [nodownloadImage setHidden:YES];
    }
    [self reloadItems];
    [AppDelegate instance].padDownloadManager.delegate = self;
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
}

- (void)reloadItems
{
    if ([AppDelegate instance].downloadItems.count == 0) {
        [editBtn setHidden:YES];
        [nodownloadImage setHidden:NO];
    } else {
        [editBtn setHidden:NO];
        [nodownloadImage setHidden:YES];
    }
    [_gmGridView reloadData];
}

- (void)downloadFailure:(NSString *)operationId error:(NSError *)error
{
    [AppDelegate instance].currentDownloadingNum--;
    if([AppDelegate instance].currentDownloadingNum < 0){
        [AppDelegate instance].currentDownloadingNum = 0;
    }
}

- (void)downloadSuccess:(NSString *)operationId
{
    for (int i = 0; i < [AppDelegate instance].downloadItems.count; i++) {
        DownloadItem *item = [[AppDelegate instance].downloadItems objectAtIndex:i];
        if (item.type == 1 && [item.itemId isEqualToString:operationId]) {
            [AppDelegate instance].currentDownloadingNum--;
            if([AppDelegate instance].currentDownloadingNum < 0){
                [AppDelegate instance].currentDownloadingNum = 0;
            }
            item.downloadStatus = @"done";
            item.percentage = 100;
            [item save];
            [_gmGridView reloadData];
            [[AppDelegate instance].padDownloadManager startDownloadingThreads];
            break;
        }
    }
}

- (void)updateProgress:(NSString *)operationId progress:(float)progress
{
    for (int i = 0; i < [AppDelegate instance].downloadItems.count; i++) {
        DownloadItem *item = [[AppDelegate instance].downloadItems objectAtIndex:i];
        if (item.type == 1 && [item.itemId isEqualToString:operationId]) {
            if (progress * 100 - item.percentage > 5) {
                NSLog(@"percent = %f", progress);
                item.percentage = (int)(progress*100);
                [item save];
            }
            GMGridViewCell *cell = [_gmGridView cellForItemAtIndex:i];
            UIProgressView *progressView = (UIProgressView *)[cell.contentView viewWithTag:operationId.intValue + 20000000];
            if(progressView != nil){
                progressView.progress = progress;
                UILabel *progressLabel = (UILabel *)[cell viewWithTag:operationId.intValue + 10000000];
                progressLabel.text = [NSString stringWithFormat:@"下载中：%i%%", (int)(progress*100)];
            }
            break;
            
        }
    }
}

- (void)movieImageClicked:(NSInteger)index
{
    if(index >= [AppDelegate instance].downloadItems.count){
        return;
    }
    GMGridViewCell *cell = [_gmGridView cellForItemAtIndex:index];
    DownloadItem *item = [[AppDelegate instance].downloadItems objectAtIndex:index];
    UILabel *progressLabel = (UILabel *)[cell.contentView viewWithTag:item.itemId.intValue + 10000000];
    UIProgressView *progressView = (UIProgressView *)[cell.contentView viewWithTag:item.itemId.intValue + 20000000];
    item.percentage = (int)(progressView.progress*100);
    if([item.downloadStatus isEqualToString:@"start"] || [item.downloadStatus isEqualToString:@"waiting"]){
        [[AppDelegate instance].padDownloadManager stopDownloading];
        progressLabel.text = [NSString stringWithFormat:@"暂停：%i%%", (int)(progressView.progress*100)];
        item.downloadStatus = @"stop";
        [item save];
        [AppDelegate instance].currentDownloadingNum--;
        if([AppDelegate instance].currentDownloadingNum < 0){
            [AppDelegate instance].currentDownloadingNum = 0;
        }
    } else if([item.downloadStatus isEqualToString:@"stop"]){
        progressLabel.text = [NSString stringWithFormat:@"等待中：%i%%", (int)(progressView.progress*100)];
        item.downloadStatus = @"waiting";
        [item save];
    }
    [[AppDelegate instance].padDownloadManager startDownloadingThreads];
}

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return fmax([[AppDelegate instance].downloadItems count], 9);
}

- (CGSize)sizeForItemsInGMGridView:(GMGridView *)gridView
{
    return CGSizeMake(110, 165);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    if(index >= [AppDelegate instance].downloadItems.count){
        return nil;
    }
    CGSize size = [self sizeForItemsInGMGridView:gridView];
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    if (!cell) {
        cell = [[GMGridViewCell alloc] init];
        cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
        cell.deleteButtonOffset = CGPointMake(-15, -15);
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.backgroundColor = [UIColor clearColor];
        cell.contentView = view;
    }
    DownloadItem *item = [[AppDelegate instance].downloadItems objectAtIndex:index];
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    imageView.frame = CGRectMake(0, 0, 105, 146);
    [cell.contentView addSubview:imageView];
    
    UIImageView *contentImage = [[UIImageView alloc]initWithFrame:CGRectMake(3, 3, 98, 138)];
    [contentImage setImageWithURL:[NSURL URLWithString:item.imageUrl] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
    [cell.contentView addSubview:contentImage];
    
    if (item.type == 1) {
        imageView.image = [UIImage imageNamed:@"movie_frame"];
        
        UILabel *bgLabel = [[UILabel alloc]initWithFrame:CGRectMake(3, 102, 98, 40)];
        bgLabel.tag = item.itemId.intValue + 30000000;
        bgLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        if(![item.downloadStatus isEqualToString:@"done"]){
            [cell.contentView addSubview:bgLabel];
        }
        
        UILabel *progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(3, 100, 98, 25)];
        progressLabel.tag = item.itemId.intValue + 10000000;
        progressLabel.backgroundColor = [UIColor clearColor];
        progressLabel.font = [UIFont boldSystemFontOfSize:13];
        progressLabel.textColor = [UIColor whiteColor];
        if([item.downloadStatus isEqualToString:@"start"]){
            progressLabel.text = [NSString stringWithFormat:@"下载中：%i%%", item.percentage];
        } else if([item.downloadStatus isEqualToString:@"stop"]){
            progressLabel.text = [NSString stringWithFormat:@"暂停：%i%%", item.percentage];
        } else if([item.downloadStatus isEqualToString:@"done"]){
//            progressLabel.text = @"下载完成";
        } else if([item.downloadStatus isEqualToString:@"waiting"]){
            progressLabel.text = [NSString stringWithFormat:@"等待中：%i%%", item.percentage];
        } else if([item.downloadStatus isEqualToString:@"error"]){
            progressLabel.text = @"下载片源失效";
        }
        
        progressLabel.textAlignment = NSTextAlignmentCenter;
        progressLabel.shadowColor = [UIColor blackColor];
        progressLabel.shadowOffset = CGSizeMake(1, 1);
        if(![item.downloadStatus isEqualToString:@"done"]){
            [cell.contentView addSubview:progressLabel];
        }
        
        if([item.downloadStatus isEqualToString:@"start"] || [item.downloadStatus isEqualToString:@"stop"] || [item.downloadStatus isEqualToString:@"waiting"]){
            UIProgressView *progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(5, 125, 94, 5)];
            progressView.progress = item.percentage/100.0;
            progressView.tag = item.itemId.intValue + 20000000;
            [cell.contentView addSubview:progressView];
        }
    } else {
        imageView.frame = CGRectMake(0, 0, 110, 150);
        contentImage.frame = CGRectMake(10, 5, 88, 130);
        imageView.image = [UIImage imageNamed:@"moviecard_list"];
    }
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(4, 150, 105, 30)];
    nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = item.name;
    nameLabel.center = CGPointMake(imageView.center.x, nameLabel.center.y);
    [cell.contentView addSubview:nameLabel];
    return cell;
}

- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index
{
    DownloadItem *item = [[AppDelegate instance].downloadItems objectAtIndex:index];
    [[AppDelegate instance].downloadItems removeObject:item];
    [item deleteObject];
    if ([item.downloadStatus isEqualToString:@"start"]) {
        [[AppDelegate instance].padDownloadManager stopDownloading];
        [AppDelegate instance].currentDownloadingNum--;
        if([AppDelegate instance].currentDownloadingNum < 0){
            [AppDelegate instance].currentDownloadingNum = 0;
        }
    }
    
    NSString *extension = @"mp4";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        if(item.type == 1){
            if ([filename hasPrefix:[NSString stringWithFormat:@"%@.%@", item.itemId, extension]]) {
                [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
            }
        } else {
            if ([filename hasPrefix:[NSString stringWithFormat:@"%@_", item.itemId]]) {
                [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
            }
        }
    }
    
    NSMutableArray *tempsubitems = [[NSMutableArray alloc]initWithCapacity:10];
    for (SubdownloadItem *subitem in [AppDelegate instance].subdownloadItems) {
        if ([subitem.itemId isEqualToString:item.itemId]) {
            [tempsubitems addObject:subitem];
            [subitem deleteObject];
        }
    }
    [[AppDelegate instance].subdownloadItems removeObjectsInArray:tempsubitems];
    for (SubdownloadItem *subitem in tempsubitems) {
        if ([subitem.downloadStatus isEqualToString:@"start"]) {
            [[AppDelegate instance].padDownloadManager stopDownloading];
            [AppDelegate instance].currentDownloadingNum--;
            if([AppDelegate instance].currentDownloadingNum < 0){
                [AppDelegate instance].currentDownloadingNum = 0;
            }
        }
    }
    
    item = nil;
    if ([AppDelegate instance].downloadItems.count > 0) {
        [[AppDelegate instance].padDownloadManager startDownloadingThreads];
    } else {
        [editBtn setHidden:YES];
        [doneBtn setHidden:YES];
        [nodownloadImage setHidden:NO];
    }
}

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    [self closeMenu];
    if(position < [AppDelegate instance].downloadItems.count){
        DownloadItem *item = [[AppDelegate instance].downloadItems objectAtIndex:position];
        if([item.downloadStatus isEqualToString:@"done"] && item.type == 1){
            NSString *extension = @"mp4";
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
            NSEnumerator *e = [contents objectEnumerator];
            NSString *filename;
            NSString *filePath;
            while ((filename = [e nextObject])) {
                if ([filename hasPrefix:[NSString stringWithFormat:@"%@.%@", item.itemId, extension]]) {
                    filePath = [documentsDirectory stringByAppendingPathComponent:filename];
                    break;
                }
            }
            
//            MyMediaPlayerViewController *viewController = [[MyMediaPlayerViewController alloc]init];
//            viewController.prodId = item.itemId;
//            viewController.type = 1;
//            viewController.name = item.name;
//            viewController.subname = @"";
//            
//            [[AppDelegate instance].rootViewController pesentMyModalView:[[UINavigationController alloc]initWithRootViewController:viewController]];
            
            AVPlayerViewController *viewController = [[AVPlayerViewController alloc]init];
            viewController.isDownloaded = YES;
            viewController.closeAll = YES;
            NSMutableArray *urlsArray = [[NSMutableArray alloc]initWithCapacity:1];
            [urlsArray addObject:filePath];
            viewController.videoUrlsArray = urlsArray;
            viewController.type = 1;
            viewController.name = item.name;
            viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
            [[AppDelegate instance].rootViewController pesentMyModalView:viewController];
        } else {
            if(item.type == 1){
                if (![item.downloadStatus hasPrefix:@"error"]) {
                    [self movieImageClicked:position];
                }
                [[AppDelegate instance].rootViewController.stackScrollViewController removeViewToViewInSlider:self.class];
            } else {
                SubdownloadViewController *viewController = [[SubdownloadViewController alloc] initWithFrame:CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height)];
                viewController.parentDelegate = self;
                viewController.titleContent = item.name;
                viewController.itemId = item.itemId;
                [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
            }
        }
    }
}

- (void)editBtnClicked
{
    [self closeMenu];
    [[AppDelegate instance].rootViewController.stackScrollViewController removeViewToViewInSlider:self.class];
    _gmGridView.editing = YES;
    [editBtn setHidden:YES];
    [doneBtn setHidden:NO];
}

- (void)doneBtnClicked
{
    [self closeMenu];
    _gmGridView.editing = NO;
    [editBtn setHidden:NO];
    [doneBtn setHidden:YES];
}

@end
