//
//  SYMusicMessageModel.h
//  AVPlayer
//
//  Created by macmini on 2017/12/15.
//  Copyright © 2017年 macmini. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SYMusicModel;

@interface SYMusicMessageModel : NSObject
/** 当前正在播放的音乐数据模型 */
@property (nonatomic ,strong) SYMusicModel *musicModel;

/** 当前播放的时长 */
@property(nonatomic ,assign) NSTimeInterval costTime;

/** 当前播放总时长 */
@property(nonatomic ,assign) NSTimeInterval totalTime;

/** 当前的播放状态 */
@property(nonatomic ,assign) BOOL isPlaying;
@end
