//
//  SYLrcLabel.m
//  AVPlayer
//
//  Created by macmini on 2017/12/15.
//  Copyright © 2017年 macmini. All rights reserved.
//

#import "SYLrcLabel.h"

@implementation SYLrcLabel

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    NSLog(@"======progress=%lf",_progress);
    
    // 设置颜色
    [[UIColor greenColor] set];
    
    CGRect fillRect = CGRectMake(0, 0, rect.size.width * self.progress, rect.size.height);
    
//        UIRectFill(fillRect);
    
    UIRectFillUsingBlendMode(fillRect, kCGBlendModeSourceIn);
}

@end
