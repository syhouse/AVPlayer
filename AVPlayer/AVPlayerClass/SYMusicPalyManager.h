//
//  SYMusicPalyManager.h
//  AudioPlayer
//
//  Created by macmini on 2017/12/7.
//  Copyright © 2017年 macmini. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>

@protocol SYMusicPalyManagerDelegate


/**
 获取播放总时间回调

 @param totleTime 播放总时间
 */
- (void)getMusicTotleTime:(CGFloat)totleTime;


/**
 每秒更新UI回调

 @param curruntTime 当前播放时间
 @param progress 播放进度
 */
- (void)updateMusicCurruntTime:(CGFloat)curruntTime prgress:(CGFloat)progress;


/**
 正在播放回调
 */
- (void)statusPlayingMusic;


/**
 暂停播放回调
 */
- (void)statusPausedMusic;


/**
 播放结束回调
 */
- (void)playMusicFinsh;

@optional

/**
 播放缓冲进度回调

 @param progress 缓冲进度
 */
- (void)bufferProgress:(CGFloat)progress;

@end

@interface SYMusicPalyManager : NSObject
+ (instancetype)shareSYMusicPalyManager;

#pragma mark 创建avplayer

/**
 播放网络单个音频

 @param url 网络源
 @param delegate 播放类回调
 @param autoPlay 是否自动播放
 */
- (void)prepareToPlayMusicWithUrl:(NSString *)url delegate:(id)delegate autoPlay:(BOOL)autoPlay;

/**
 
 播放本地单个音频

 @param musicFilePath 音频本地地址
 @param delegate 播放类回调
 @param autoPlay 是否自动播放
 */
- (void)prepareToPlayMusicWithFilePath:(NSString *)musicFilePath delegate:(id)delegate autoPlay:(BOOL)autoPlay;


/**
 播放音频列表

 @param urls 音频地址数组
 @param delegate 播放类回调
 @param autoPlay 是否自动播放
 */
- (void)prepareToPlayMusicWithUrls:(NSArray<NSString *> *)urls delegate:(id)delegate autoPlay:(BOOL)autoPlay;

#pragma mark 播放控制

/**
 播放
 */
- (void)play;

/**
 暂停
 */
- (void)pause;

/**
 跳转指定进度

 @param progress 进度 0-1
 */
- (void)playAtProgress:(CGFloat)progress;

/**
 播放上一首 播放单个音频时就是从头开始播放该音频
 */
- (void)playerPreviouse;

/**
 播放下一首 播放单个音频时就是从头开始播放该音频
 */
- (void)playerNext;


/**
 停止播放
 */
- (void)stopPlay;
@end
