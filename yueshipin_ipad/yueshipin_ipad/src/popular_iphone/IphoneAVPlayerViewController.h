//
//  IphoneAVPlayerViewController.h
//  mediaplayer
//
//  Created by 08 on 13-2-26.
//  Copyright (c) 2013年 iplusjoy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"
@interface IphoneAVPlayerViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    UIToolbar *topToolBar_;
    UIToolbar *bottomToolBar_;
    AVPlayerView *avplayerView_;
    NSURL* mURL;
	AVPlayer* mPlayer;
    AVPlayerItem * mPlayerItem;
    BOOL seekToZeroBeforePlay;
    UISlider* mScrubber;
    id mTimeObserver;
    float mRestoreAfterScrubbingRate;
    UIImageView *playCacheView_;
    
    UIButton *selectButton_;
    UIButton *clarityButton_;
    UIButton *playButton_;
    UIButton *pauseButton_;
    UIImageView *bottomView_;
    UILabel *seeTimeLabel_;
    UILabel *totalTimeLable_;
    NSString *nameStr_;
    UIImageView *clearBgView_;
    
    NSMutableArray *sortEpisodesArr_;
    NSArray *episodesArr_;
    int playNum;
    
    UITableView *tableList_;
    NSMutableArray *superClearArr;
    NSMutableArray *highClearArr;
    NSMutableArray *plainClearArr;
    
    NSMutableArray *play_index_tag;
    
    int play_url_index;
    
    NSString *local_file_path_;
    BOOL islocalFile_;
    
    int clear_type;
    CMTime lastPlayTime_;
    
    NSTimer *myTimer_;
    
    int videoType_;
    
    MBProgressHUD *myHUD;
    
    NSString *prodId_;
    NSString *webPlayUrl_;
    
    NSTimer *timeLabelTimer_;
}
@property (nonatomic, strong) UIToolbar *topToolBar;
@property (nonatomic, strong) UIToolbar *bottomToolBar;
@property (nonatomic, strong) AVPlayerView *avplayerView;
@property (nonatomic, strong) AVPlayerItem *mPlayerItem;
@property (readwrite, retain, setter=setPlayer:, getter=player) AVPlayer* mPlayer;
@property (nonatomic, strong) NSURL* mURL;
@property (nonatomic, strong) UISlider* mScrubber;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) UIButton *clarityButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UILabel *seeTimeLabel;
@property (nonatomic, strong) UILabel *totalTimeLablel;
@property (nonatomic, strong) UIImageView *playCacheView;
@property (nonatomic, strong) UIImageView *bottomView;
@property (nonatomic, strong) UIImageView *clearBgView;
@property (nonatomic, strong) NSString *nameStr;
@property (nonatomic, strong) NSArray *episodesArr;
@property (nonatomic, assign) int playNum;
@property (nonatomic, strong) NSMutableArray *sortEpisodesArr;
@property (nonatomic, strong) UITableView *tableList;
@property (nonatomic, strong) NSMutableArray *superClearArr;
@property (nonatomic, strong) NSMutableArray *highClearArr;
@property (nonatomic, strong) NSMutableArray *plainClearArr;
@property (nonatomic, strong) NSMutableArray *play_index_tag;
@property (nonatomic, strong) NSString *local_file_path;
@property (nonatomic, assign)  BOOL islocalFile;
@property (nonatomic, strong) NSTimer *myTimer;
@property (nonatomic, strong) NSTimer *timeLabelTimer;
@property (nonatomic, assign) int videoType;
@property (nonatomic, strong) MBProgressHUD *myHUD;
@property (nonatomic, strong)  NSString *prodId;
@property (nonatomic, strong) NSString *webPlayUrl;
@property (nonatomic, assign) CMTime lastPlayTime;
- (void)setURL:(NSURL*)URL;
- (NSURL*)URL;

@end