//
//  SYLrcModel.h
//  AVPlayer
//
//  Created by macmini on 2017/12/15.
//  Copyright © 2017年 macmini. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  歌词数据模型
 */
@interface SYLrcModel : NSObject

/** 开始时间 */
@property (nonatomic ,assign) NSTimeInterval beginTime;

/** 结束时间 */
@property (nonatomic ,assign) NSTimeInterval endTime;

/** 歌词内容 */
@property (nonatomic ,copy) NSString *lrcText;

@end
