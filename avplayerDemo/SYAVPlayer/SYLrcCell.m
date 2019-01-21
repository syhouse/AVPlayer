//
//  SYLrcCell.m
//  AVPlayer
//
//  Created by macmini on 2017/12/15.
//  Copyright © 2017年 macmini. All rights reserved.
//

#import "SYLrcCell.h"

#import <PureLayout.h>

@implementation SYLrcCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.lrcLabel = [[SYLrcLabel alloc] init];
        self.lrcLabel.textColor = [UIColor blackColor];
        self.lrcLabel.textAlignment = NSTextAlignmentCenter;
        self.lrcLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.lrcLabel];
//        [self.lrcLabel autoPinEdgesToSuperviewEdges];
        
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

/**
 *  重写歌词内容set方法, 展示歌词
 *
 *  @param lrcText 歌词内容
 */
- (void)setLrcText:(NSString *)lrcText
{
    _lrcText = lrcText;
    self.lrcLabel.text = lrcText;
}

/**
 *  设置歌词播放进度
 *
 *  @param progress 歌词进度
 */
- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    self.lrcLabel.progress = progress;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self.lrcLabel sizeToFit];
    
    //歌词居中
    CGRect frame = self.lrcLabel.frame;
    frame.origin.x = (CGRectGetWidth(self.frame) - frame.size.width)/2;
    self.lrcLabel.frame = frame;
}
@end
