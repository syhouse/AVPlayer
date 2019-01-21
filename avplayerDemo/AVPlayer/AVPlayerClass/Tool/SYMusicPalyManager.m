//
//  SYMusicPalyManager.m
//  AudioPlayer
//
//  Created by macmini on 2017/12/7.
//  Copyright © 2017年 macmini. All rights reserved.
//

#import "SYMusicPalyManager.h"

#import "SYMusicModel.h"
#import "SYLrcModel.h"
#import "SYLrcDataTool.h"
#import "SYMusicMessageModel.h"

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, SYMusicPalyManagerStatus) {
    SYMusicPalyManagerStatusNone,    //初始状态
    SYMusicPalyManagerStatusFailed,  //音频播放失败
    SYMusicPalyManagerStatusPaused,  //音频暂停播放
    SYMusicPalyManagerStatusReadyToPlay,//音频准备播放
    SYMusicPalyManagerStatusPlaying //音频正在播放
};

#define kStatusKey  @"status"
#define kTimeControlStatusKey @"timeControlStatus"
#define kLoadedTimeRangesKey  @"loadedTimeRanges"

@interface SYMusicPalyManager()
@property (nonatomic,readonly)AVPlayer *avPlayer;
@property (nonatomic,strong)NSTimer *updateTimer;
@property (nonatomic,weak)id <SYMusicPalyManagerDelegate>delegate;
@property (nonatomic,strong)NSArray *totleMusticItems;

/** 负责更新歌词的定时器 */
@property (nonatomic, strong) CADisplayLink *updateLrcLink;

/**
    监测播放状态
 */
@property (nonatomic)SYMusicPalyManagerStatus managerStatus;
@end

@implementation SYMusicPalyManager

@synthesize messageModel = _messageModel;

static SYMusicPalyManager *manager = nil;

+ (instancetype)shareSYMusicPalyManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SYMusicPalyManager alloc] init];
    });
    return manager;
}

/**
 *  更新音乐信息数据模型
 *
 */
- (SYMusicMessageModel *)messageModel
{
    if (!_messageModel) {
        _messageModel = [[SYMusicMessageModel alloc] init];
    }
    
    // 已播放时长
    _messageModel.costTime = [self fetchCurrentTime];
    
    // 总时长
    _messageModel.totalTime = [self fetchTotalTime];
    
    // 播放状态
    _messageModel.isPlaying = self.managerStatus == SYMusicPalyManagerStatusPlaying;
    return _messageModel;
}

#pragma mark 定时器

- (NSTimer *)updateTimer
{
    if (!_updateTimer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setUpTimes) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:_updateTimer forMode:NSRunLoopCommonModes];
            
        });
        
    }
    return _updateTimer;
}


/**
 开启定时器
 */
- (void)startTimer
{
    [self.updateTimer fire];
}

/**
 关闭定时器
 */
- (void)closeTimer
{
    [self.updateTimer invalidate];
    self.updateTimer = nil;
}


/**
 开启歌词定时器
 */
- (void)startLink
{
    [self.updateLrcLink setPaused:NO];
}

/**
 关闭歌词定时器
 */
- (void)closeLink
{
    [self.updateLrcLink setPaused:YES];
}

/**
 移除歌词定时器
 */
- (void)removeLink
{
    [self.updateLrcLink invalidate];
    self.updateLrcLink = nil;
}

/**
 *  负责更新歌词的时钟
 *
 *  @return updateLrcLink
 */
- (CADisplayLink *)updateLrcLink
{
    if (!_updateLrcLink) {
        _updateLrcLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLrc)];
        [_updateLrcLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _updateLrcLink;
}

#pragma mark 创建avplayer

- (void)prepareToPlayMusicWithSong:(SYMusicModel *)song delegate:(id)delegate autoPlay:(BOOL)autoPlay{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self prepareToPlayMusicWithSongs:@[song] delegate:delegate autoPlay:autoPlay];
    });
}

- (void)prepareToPlayMusicWithSongs:(NSArray<SYMusicModel *> *)songs delegate:(id)delegate autoPlay:(BOOL)autoPlay{
    self.delegate = delegate;
    self.totleMusticItems = songs;
    if(self.totleMusticItems.count){
        [self setAVPlayerWithSong:songs.firstObject];
        if(autoPlay){
            [self play];
        }
    }
}


/**
 根据AVPlayerItem 设置AVPlayer

 @param song 歌曲模型
 */
- (void)setAVPlayerWithSong:(SYMusicModel *)song{
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:song.url];
    if(!item){
        NSLog(@"歌曲地址有误");
        return;
    }
    
    self.messageModel.musicModel = song;
    
    if(_avPlayer){
        [self removeKeyPathObserver];
        [_avPlayer replaceCurrentItemWithPlayerItem:item];
    }
    else{
        
        _avPlayer = [AVPlayer playerWithPlayerItem:item];
        
        //当前item播放完成通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(curruntItemFinshPlay:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.avPlayer.currentItem];
    }
    
    //监听播放状态
    [_avPlayer.currentItem addObserver:self forKeyPath:kStatusKey options:NSKeyValueObservingOptionNew context:nil];
    
    //监听播放器状态
    [_avPlayer addObserver:self forKeyPath:kTimeControlStatusKey options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    //监听缓冲进度
    [_avPlayer.currentItem addObserver:self forKeyPath:kLoadedTimeRangesKey options:NSKeyValueObservingOptionNew context:nil];
}

#pragma action

- (void)setUpTimes{
    if(self.delegate){
        [self.delegate updateMusicByOneSecend];
    }
}

- (void)updateLrc{
    if(self.delegate){
        [self.delegate updateLrcByOneFrame];
    }
}

#pragma mark 播放控制

- (void)play{
    [self.avPlayer play];
    [self startTimer];
    [self startLink];
    
    if(@available(iOS 10.0, *)){
    }else{
        if(self.managerStatus == SYMusicPalyManagerStatusNone ||self.managerStatus == SYMusicPalyManagerStatusReadyToPlay){
            self.managerStatus = SYMusicPalyManagerStatusReadyToPlay;
        }
        else if (self.managerStatus != SYMusicPalyManagerStatusFailed){
            if(self.delegate){
                [self.delegate statusPlayingMusic];
            }
        }
    }
}

- (void)pause{
    [self.avPlayer pause];
    [self closeTimer];
    [self closeLink];
    
    if(@available(iOS 10.0, *)){
    }else{
        if(self.managerStatus == SYMusicPalyManagerStatusPlaying){
            self.managerStatus = SYMusicPalyManagerStatusPaused;
            if(self.delegate){
                [self.delegate statusPausedMusic];
            }
        }
    }
}

- (void)playAtProgress:(CGFloat)progress{
    __weak typeof(self) weakself = self;
    [self pause];
    CGFloat fps = self.avPlayer.currentTime.timescale;
    CMTime time = CMTimeMakeWithSeconds(CMTimeGetSeconds(self.avPlayer.currentItem.asset.duration) * progress, fps);
    [self.avPlayer seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if(finished){
            [weakself play];
        }
    }];
}

- (void)playerPreviouse{
    if(self.totleMusticItems.count >1){
        NSInteger index = [self.totleMusticItems indexOfObject:self.avPlayer.currentItem];
        
        NSInteger preIndex = index -1 >=0 ? index -1 : self.totleMusticItems.count-1;
        
        [self setAVPlayerWithSong:self.totleMusticItems[preIndex]];
        //avplayeritem 未被播放完成 会从之前进度开始
        [self playAtProgress:0];
    }
    else{
        [self playAtProgress:0];
    }
}

- (void)playerNext{
    if(self.totleMusticItems.count >1){
        NSInteger index = [self.totleMusticItems indexOfObject:self.avPlayer.currentItem];
        
        NSInteger nextIndex = index +1 <self.totleMusticItems.count ? index +1 : 0;
        
        [self setAVPlayerWithSong:self.totleMusticItems[nextIndex]];
        
        [self playAtProgress:0];
    }
    else{
        [self playAtProgress:0];
    }
}

- (void)stopPlay{
    [self cleanObserver];
    
    [self closeTimer];
    
    [self removeLink];
    
    _avPlayer = nil;
}

- (void)cleanObserver{
    [self removeKeyPathObserver];
    [self removeNSNotificationObserver];
}

- (void)removeKeyPathObserver{
    [self.avPlayer.currentItem removeObserver:self forKeyPath:kStatusKey];
    [self.avPlayer.currentItem removeObserver:self forKeyPath:kLoadedTimeRangesKey];
    [self.avPlayer removeObserver:self forKeyPath:kTimeControlStatusKey];
}

- (void)removeNSNotificationObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark 播放时间 进度

/**
 获取当前时间

 @return 当前帧时间（s）
 */
- (CGFloat)fetchCurrentTime
{
    CMTime time = self.avPlayer.currentItem.currentTime;
    if (time.timescale == 0) {
        return 0;
    }
    return time.value/(float)time.timescale;
}


/**
 获取总时间时间

 @return 总帧时间（s）
 */
- (CGFloat)fetchTotalTime
{
    CMTime time = self.avPlayer.currentItem.duration;
    if (time.timescale == 0) {
        return 0;
    }
    return time.value/(float)time.timescale;
}


/**
 获取当前播放进度

 @return 当前播放进度 0-1
 */
- (CGFloat)fetchProgressValue
{
    if([self fetchTotalTime] == 0){
        return 0;
    }
    return [self fetchCurrentTime]/[self fetchTotalTime];
}


/**
 获取缓冲进度

 @return 缓冲进度 0-1
 */
- (float)fetchBufferProgress
{
    NSArray *loadedTimeRanges = [[self.avPlayer currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    float loadedTime = startSeconds + durationSeconds;// 计算缓冲总时间
    
    if([self fetchTotalTime] == 0){
        return 0;
    }
    return loadedTime/[self fetchTotalTime];
}

#pragma mark  NSNotificationCenter
- (void)curruntItemFinshPlay:(NSNotification *)notification{
    if([[notification object] isEqual:self.avPlayer.currentItem]){
        if(self.delegate){
            [self.delegate playMusicFinsh];
        }
        [self closeTimer];
    }
}

#pragma mark observe

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kStatusKey]) {
        
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey]integerValue];
        
        //获取到音频信息 准备播放
        if (status ==AVPlayerStatusReadyToPlay){
            if(self.delegate){
                [self.delegate startGetMusicTotleTime];
            }

            if(self.delegate){
                [self.delegate readyLrc];
            }
            
            [self startTimer];
            
            [self startLink];
            
            if(@available(iOS 10.0,*)){
            }else{
                if(self.managerStatus == SYMusicPalyManagerStatusReadyToPlay){
                    self.managerStatus = SYMusicPalyManagerStatusPlaying;
                    [self play];
                }
                else if (self.managerStatus == SYMusicPalyManagerStatusNone){
                    self.managerStatus = SYMusicPalyManagerStatusReadyToPlay;
                }
            }
            
        }
        else if (status == AVPlayerStatusFailed) {
            
            NSLog(@"加载失败，网络或者服务器出现问题");
            self.managerStatus = SYMusicPalyManagerStatusFailed;
            
        }
        else if (status == AVPlayerItemStatusUnknown) {
            NSLog(@"未知状态，此时不能播放");
            self.managerStatus = SYMusicPalyManagerStatusFailed;
        }
    }
    //播放器播放状态
    else if ([keyPath isEqualToString:kTimeControlStatusKey]){
        if (@available(iOS 10.0, *)) {
            AVPlayerTimeControlStatus timeStatus = [[change objectForKey:NSKeyValueChangeNewKey]integerValue];
            if(timeStatus == AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate){
                NSLog(@"歌曲信息加载完成 准备播放");
            }else if (timeStatus == AVPlayerTimeControlStatusPlaying){
                if(self.delegate){
                    [self.delegate statusPlayingMusic];
                }
                self.managerStatus = SYMusicPalyManagerStatusPlaying;
            }
            else if (timeStatus == AVPlayerTimeControlStatusPaused){
                if(self.delegate){
                    [self.delegate statusPausedMusic];
                }
                self.managerStatus = SYMusicPalyManagerStatusPaused;
            }
        }
    }
    
    //缓冲进度
    else if ([keyPath isEqualToString:kLoadedTimeRangesKey]){
        if(self.delegate){
            [self.delegate bufferProgress:[self fetchBufferProgress]];
        }
    }
    
}
@end
