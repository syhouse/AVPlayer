//
//  SYLrcViewController.h
//  AVPlayer
//
//  Created by macmini on 2017/12/15.
//  Copyright © 2017年 macmini. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYLrcModel;

@interface SYLrcViewController : UITableViewController

/** 外界传递过来的歌词数据源, 负责展示 */
@property (nonatomic, strong) NSArray <SYLrcModel *> *lrcModels;

/** 根据外界传递过来的行号, 负责滚动 */
@property (nonatomic, assign) NSInteger scrollRow;

/** 根据外界传递过来的歌词进度, 展示歌词进度 */
@property (nonatomic, assign) CGFloat progress;

@end
