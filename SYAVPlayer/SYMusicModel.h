//
//  SYMusicModel.h
//  AVPlayer
//
//  Created by macmini on 2017/12/15.
//  Copyright © 2017年 macmini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYMusicModel : NSObject

/**
 音频播放链接
 */
@property(nonatomic,strong)NSURL *url;


/**
 音频歌词地址（本地）
 */
@property(nonatomic,strong)NSString *lrcPath;
@end
