//
//  SYLrcCell.h
//  AVPlayer
//
//  Created by macmini on 2017/12/15.
//  Copyright © 2017年 macmini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYLrcLabel.h"

@interface SYLrcCell : UITableViewCell
@property (strong, nonatomic)SYLrcLabel *lrcLabel;

/** 歌词内容 */
@property(nonatomic, copy) NSString *lrcText;

/** 歌词进度 */
@property(nonatomic, assign) CGFloat progress;
@end
