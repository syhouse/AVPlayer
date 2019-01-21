//
//  LRCTool.h
//  AVPlayer
//
//  Created by macmini on 2017/12/15.
//  Copyright © 2017年 macmini. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SYLrcModel;

@interface SYLrcDataTool : NSObject
/**
 *  根据歌词文件名称获取歌词
 *
 *  @param path 歌词路径
 *
 *  @return 歌词数组
 */
+ (NSArray <SYLrcModel *> *)getLrcModelsWithLrcPath:(NSString *)path;

/**
 *  根据歌曲播放当前时间和歌词获取当前歌词行号
 *
 *  @param currentTime 歌曲播放当前的时间
 *  @param lrcModels   歌词数组
 *
 *  @return 行号
 */
+ (NSInteger)getRowWithCurrentTime:(NSTimeInterval)currentTime lrcModels:(NSArray <SYLrcModel *> *)lrcModels;
@end
