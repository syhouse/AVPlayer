//
//  SYMusicPalyManager.m
//  AudioPlayer
//
//  Created by macmini on 2017/12/7.
//  Copyright © 2017年 macmini. All rights reserved.
//

#import "SYMusicPalyManager.h"

#import <AVFoundation/AVFoundation.h>

#define kStatusKey  @"status"
#define kTimeControlStatusKey @"timeControlStatus"
#define kLoadedTimeRangesKey  @"loadedTimeRanges"

@interface SYMusicPalyManager()
@property (nonatomic,readonly)AVPlayer *avPlayer;
@property (nonatomic,strong)NSTimer *updateTimer;
@property (nonatomic,weak)id <SYMusicPalyManagerDelegate>delegate;
@property(nonatomic,strong)NSArray *totleMusticItems;
@end

@implementation SYMusicPalyManager

static SYMusicPalyManager *tool = nil;

+ (instancetype)shareSYMusicPalyManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[SYMusicPalyManager alloc] init];
    });
    return tool;
}

#pragma mark 定时器

- (NSTimer *)updateTimer
{
    if (!_updateTimer) {
        _updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setUpTimes) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_updateTimer forMode:NSRunLoopCommonModes];
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

#pragma mark 创建avplayer

- (void)prepareToPlayMusicWithUrl:(NSString *)url delegate:(id)delegate autoPlay:(BOOL)autoPlay{
    [self prepareToPlayMusicWithUrls:@[url] delegate:delegate autoPlay:autoPlay];
}

- (void)prepareToPlayMusicWithFilePath:(NSString *)musicFilePath delegate:(id)delegate autoPlay:(BOOL)autoPlay{
    [self prepareToPlayMusicWithUrls:@[musicFilePath] delegate:delegate autoPlay:autoPlay];
}

- (void)prepareToPlayMusicWithUrls:(NSArray<NSString *> *)urls delegate:(id)delegate autoPlay:(BOOL)autoPlay{
    self.delegate = delegate;
    NSMutableArray *items = [NSMutableArray array];
    for(NSString *url in urls){
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:url]];
        [items addObject:item];
    }
    self.totleMusticItems = items;
    if(self.totleMusticItems.count){
        [self setAVPlayerWithItem:self.totleMusticItems.firstObject];

        if(autoPlay){
            [self play];
        }
    }
}


/**
 根据AVPlayerItem 设置AVPlayer

 @param item 音频包装盒
 */
- (void)setAVPlayerWithItem:(AVPlayerItem *)item{
    if(_avPlayer){
        [self removeKeyPathObserver];
        [_avPlayer replaceCurrentItemWithPlayerItem:item];
    }
    else{
        
        _avPlayer = [AVPlayer playerWithPlayerItem:item];
        
        //当前item播放完成通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(curruntItemFinshPlay) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
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
        [self.delegate updateMusicCurruntTime:[self fetchCurrentTime] prgress:[self fetchProgressValue]];
    }
}

#pragma mark 播放控制

- (void)play{
    [self.avPlayer play];
    [self startTimer];
}

- (void)pause{
    [self.avPlayer pause];
    [self closeTimer];
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
        
        [self setAVPlayerWithItem:self.totleMusticItems[preIndex]];
    }
    else{
        [self playAtProgress:0];
    }
}

- (void)playerNext{
    if(self.totleMusticItems.count >1){
        NSInteger index = [self.totleMusticItems indexOfObject:self.avPlayer.currentItem];
        
        NSInteger nextIndex = index +1 <self.totleMusticItems.count ? index +1 : 0;
        
        [self setAVPlayerWithItem:self.totleMusticItems[nextIndex]];
    }
    else{
        [self playAtProgress:0];
    }
}

- (void)stopPlay{
    [self cleanObserver];
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

 @return 当前时间秒
 */
- (CGFloat)fetchCurrentTime
{
    CMTime time = self.avPlayer.currentItem.currentTime;
    if (time.timescale == 0) {
        return 0;
    }
    return time.value/time.timescale;
}


/**
 获取总时间时间

 @return 总时间秒
 */
- (CGFloat)fetchTotalTime
{
    CMTime time = self.avPlayer.currentItem.duration;
    if (time.timescale == 0) {
        return 0;
    }
    return time.value/time.timescale;
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
- (void)curruntItemFinshPlay{
    if(self.delegate){
        [self.delegate playMusicFinsh];
    }
    
    //最后一次还未执行定时器就停止
//    [self performSelector:@selector(closeTimer) withObject:nil afterDelay:1];
    [self closeTimer];
}

#pragma mark observe

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kStatusKey]) {
        
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey]integerValue];
        
        //获取到音频信息 准备播放
        if (status ==AVPlayerStatusReadyToPlay){
            
            NSLog(@"%ld",self.avPlayer.timeControlStatus);
            
            if(self.delegate){
                [self.delegate getMusicTotleTime:[self fetchTotalTime]];
            }
            
            [self startTimer];
            
        }
        else if (status == AVPlayerStatusFailed) {
            
            NSLog(@"加载失败，网络或者服务器出现问题");
            
        }
        else if (status == AVPlayerItemStatusUnknown) {
            NSLog(@"未知状态，此时不能播放");
        }
    }
    //播放器播放状态
    else if ([keyPath isEqualToString:kTimeControlStatusKey]){
        AVPlayerTimeControlStatus timeStatus = [[change objectForKey:NSKeyValueChangeNewKey]integerValue];
        if(timeStatus == AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate){
            NSLog(@"歌曲信息加载完成 准备播放");
        }else if (timeStatus == AVPlayerTimeControlStatusPlaying){
            if(self.delegate){
                [self.delegate statusPlayingMusic];
            }
        }
        else if (timeStatus == AVPlayerTimeControlStatusPaused){
            if(self.delegate){
                [self.delegate statusPausedMusic];
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
