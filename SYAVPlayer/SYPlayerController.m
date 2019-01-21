//
//  SYPlayerController.m
//  AudioPlayer
//
//  Created by macmini on 2017/12/7.
//  Copyright © 2017年 macmini. All rights reserved.
//

#import "SYPlayerController.h"

#import "SYMusicPalyManager.h"
#import "SYLrcViewController.h"
#import "SYLrcDataTool.h"
#import "SYLrcLabel.h"
#import "SYTimeTool.h"

#import "SYMusicMessageModel.h"
#import "SYMusicModel.h"
#import "SYLrcModel.h"

#import <PureLayout.h>

static CGFloat const timeFontSize = 14.0;//计时器文字大小;

@interface SYPlayerController ()<SYMusicPalyManagerDelegate>

@property(nonatomic,strong)UIButton *previousButton;
@property(nonatomic,strong)UIButton *playButton;
@property(nonatomic,strong)UIButton *nextButton;
@property(nonatomic,strong)UIButton *backButton;
@property(nonatomic,strong)UISlider *progressSlider;
@property(nonatomic,strong)UILabel *leftTimeLabel;
@property(nonatomic,strong)UILabel *rightTimeLabel;
@property(nonatomic,strong)UIImageView *bgImageVIew;

@property (nonatomic, weak) SYLrcViewController *lrcViewController;

//进度条滑块是否正在拖动
@property(nonatomic,assign)BOOL isProgressDrag;

@end

@implementation SYPlayerController

- (void)loadView{
    [super loadView];
    
    [self createUI];
    
    [self setViewFrame];
}

#pragma mark UI

/**
 *  显示歌词控制器
 *
 *  @return 歌词控制器; 详情界面展示的歌词, 统一由此控制器管理(展示, 滚动, 进度等)
 */
- (SYLrcViewController *)lrcViewController
{
    if (!_lrcViewController) {
        SYLrcViewController *lrcViewController = [[SYLrcViewController alloc] init];
        [self addChildViewController:lrcViewController];
        _lrcViewController = lrcViewController;
    }
    return _lrcViewController;
}

- (UIButton *)previousButton{
    if(!_previousButton){
        _previousButton = [[UIButton alloc] init];
        [_previousButton setBackgroundImage:[UIImage imageNamed:@"player_btn_pre_normal"] forState:UIControlStateNormal];
        [_previousButton setBackgroundImage:[UIImage imageNamed:@"player_btn_pre_highlight"] forState:UIControlStateHighlighted];
        [_previousButton addTarget:self action:@selector(playerPreviouse) forControlEvents:UIControlEventTouchUpInside];
    }
    return _previousButton;
}

- (UIButton *)nextButton{
    if(!_nextButton){
        _nextButton = [[UIButton alloc] init];
        [_nextButton setBackgroundImage:[UIImage imageNamed:@"player_btn_next_normal"] forState:UIControlStateNormal];
        [_nextButton setBackgroundImage:[UIImage imageNamed:@"player_btn_next_highlight"] forState:UIControlStateHighlighted];
        [_nextButton addTarget:self action:@selector(playerNext) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}

- (UIButton *)playButton{
    if(!_playButton){
        _playButton = [[UIButton alloc] init];
        [_playButton setBackgroundImage:[UIImage imageNamed:@"player_btn_play_normal"] forState:UIControlStateNormal];
        [_playButton setBackgroundImage:[UIImage imageNamed:@"player_btn_pause_normal"] forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(playButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (UIButton *)backButton{
    if(!_backButton){
        _backButton = [[UIButton alloc] init];
        [_backButton setBackgroundImage:[UIImage imageNamed:@"miniplayer_btn_playlist_close"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(dismissController) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UISlider *)progressSlider{
    if(!_progressSlider){
        _progressSlider = [[UISlider alloc] init];
        _progressSlider.minimumValue = 0;// 设置最小值
        _progressSlider.maximumValue = 1;// 设置最大值
        _progressSlider.value = 0;// 设置初始值
        _progressSlider.continuous = YES;// 设置可连续变化
        _progressSlider.minimumTrackTintColor = [UIColor greenColor]; //滑轮左边颜色，如果设置了左边的图片就不会显示
        _progressSlider.maximumTrackTintColor = [UIColor whiteColor]; //滑轮右边颜色，如果设置了右边的图片就不会显示
        _progressSlider.thumbTintColor = [UIColor yellowColor];//设置了滑轮的颜色，如果设置了滑轮的样式图片就不会显示
        [_progressSlider addTarget:self action:@selector(progerssValueChanged:) forControlEvents:UIControlEventValueChanged];//进度条值正在改变
        [_progressSlider addTarget:self action:@selector(progerssValueChangeEnd:) forControlEvents:UIControlEventTouchUpInside];//进度条拖动结束
        [_progressSlider addTarget:self action:@selector(progerssValueChangeStart:) forControlEvents:UIControlEventTouchDown];//进度条拖动开始
    }
    return _progressSlider;
}

- (UILabel *)leftTimeLabel{
    if(!_leftTimeLabel){
        _leftTimeLabel = [[UILabel alloc] init];
        _leftTimeLabel.font = [UIFont systemFontOfSize:timeFontSize];
        _leftTimeLabel.text = @"00:00";
        _leftTimeLabel.textColor = [UIColor whiteColor];
    }
    return _leftTimeLabel;
}

- (UILabel *)rightTimeLabel{
    if(!_rightTimeLabel){
        _rightTimeLabel = [[UILabel alloc] init];
        _rightTimeLabel.font = [UIFont systemFontOfSize:timeFontSize];
        _rightTimeLabel.text = @"00:00";
        _rightTimeLabel.textColor = [UIColor whiteColor];
    }
    return _rightTimeLabel;
}

- (UIImageView *)bgImageVIew{
    if(!_bgImageVIew){
        _bgImageVIew.userInteractionEnabled = YES;
        _bgImageVIew = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"QQListBack"]];
    }
    return _bgImageVIew;
}


- (void)createUI{
    [self.view addSubview:self.bgImageVIew];
    
    [self.view addSubview:self.lrcViewController.view];
    
    [self.view addSubview:self.previousButton];
    [self.view addSubview:self.playButton];
    [self.view addSubview:self.nextButton];
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.progressSlider];
    [self.view addSubview:self.leftTimeLabel];
    [self.view addSubview:self.rightTimeLabel];
}

- (void)setViewFrame{
    [self.bgImageVIew autoPinEdgesToSuperviewEdges];
    
    self.lrcViewController.view.frame = CGRectMake(0,20, CGRectGetWidth(self.view.frame), 300);
    
    [self.lrcViewController.view autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
    [self.lrcViewController.view autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:40];
    [self.lrcViewController.view autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20];
    [self.lrcViewController.view autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:150];
    
    [self.backButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
    [self.backButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20];
    [self.backButton autoSetDimensionsToSize:CGSizeMake(30, 30)];
    
    [self.previousButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:30];
    [self.previousButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:15];
    [self.previousButton autoSetDimensionsToSize:CGSizeMake(40, 40)];
    
    [self.playButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.previousButton];
    [self.playButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.playButton autoSetDimensionsToSize:CGSizeMake(40, 40)];
    
    [self.nextButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.previousButton];
    [self.nextButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:30];
    [self.nextButton autoSetDimensionsToSize:CGSizeMake(40, 40)];
    
    [self.leftTimeLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [self.leftTimeLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:80];
    [self.leftTimeLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.progressSlider withOffset:-10];
    [self.leftTimeLabel autoSetDimension:ALDimensionWidth toSize:40 relation:NSLayoutRelationGreaterThanOrEqual];
    
    [self.progressSlider autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.leftTimeLabel];
    
    [self.rightTimeLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.leftTimeLabel];
    [self.rightTimeLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.progressSlider withOffset:10];
    [self.rightTimeLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    [self.rightTimeLabel autoSetDimension:ALDimensionWidth toSize:40 relation:NSLayoutRelationGreaterThanOrEqual];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark Action
- (void)dismissController{
    [[SYMusicPalyManager shareSYMusicPalyManager] stopPlay];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)playerPreviouse{
    [[SYMusicPalyManager shareSYMusicPalyManager] playerPreviouse];
}

- (void)playerNext{
   [[SYMusicPalyManager shareSYMusicPalyManager] playerNext];
}

- (void)playButtonClick:(UIButton *)playButton{
    playButton.selected = !playButton.selected;
    if(playButton.selected){//播放音乐
        [[SYMusicPalyManager shareSYMusicPalyManager] play];
    }
    else{
        [[SYMusicPalyManager shareSYMusicPalyManager] pause];
    }
}

- (void)progerssValueChangeStart:(UISlider *)progressSlider{
    self.isProgressDrag = YES;
}

- (void)progerssValueChangeEnd:(UISlider *)progressSlider{
    self.isProgressDrag = NO;
    [[SYMusicPalyManager shareSYMusicPalyManager] playAtProgress:progressSlider.value];
}

- (void)progerssValueChanged:(UISlider *)progressSlider{
    self.leftTimeLabel.text = [SYTimeTool getFormatTimeWithTimeInterval:[SYMusicPalyManager shareSYMusicPalyManager].messageModel.totalTime * self.progressSlider.value];
}

- (void)updateLrcUI
{
    if(!self.lrcViewController.lrcModels.count){
        return;
    }
    
    // 获取歌曲播放信息的数据模型
    SYMusicMessageModel *messageModel = [SYMusicPalyManager shareSYMusicPalyManager].messageModel;
    
    // 计算当前播放时间, 对应的歌曲行号
    NSInteger row = [SYLrcDataTool getRowWithCurrentTime:messageModel.costTime lrcModels:self.lrcViewController.lrcModels];
//
    // 把需要滚动的行号, 交给歌词控制器统一管理, 让歌词控制器负责滚动
    self.lrcViewController.scrollRow = row;

    // 显示歌词label
    // 取出当前正在播放的歌词数据模型
    SYLrcModel *lrcModel = self.lrcViewController.lrcModels[row];

    // 计算一行歌词的播放进度
   CGFloat progress = (messageModel.costTime - lrcModel.beginTime) / (lrcModel.endTime - lrcModel.beginTime);
    
//     传值给歌词控制器, 让歌词控制器的歌词负责进度展示
    self.lrcViewController.progress = progress;
}

#pragma mark SYMusicPalyManagerDelegate
- (void)startGetMusicTotleTime{
    self.rightTimeLabel.text = [SYTimeTool getFormatTimeWithTimeInterval:[SYMusicPalyManager shareSYMusicPalyManager].messageModel.totalTime];
}

- (void)updateMusicByOneSecend{
    if(!self.isProgressDrag){
        self.leftTimeLabel.text = [SYTimeTool getFormatTimeWithTimeInterval:[SYMusicPalyManager shareSYMusicPalyManager].messageModel.costTime];
        self.progressSlider.value = [SYMusicPalyManager shareSYMusicPalyManager].messageModel.costTime/[SYMusicPalyManager shareSYMusicPalyManager].messageModel.totalTime;
    }
}

- (void)statusPlayingMusic{
    self.playButton.selected = YES;
    
}

- (void)statusPausedMusic{
    self.playButton.selected = NO;
}

- (void)playMusicFinsh{
    self.playButton.selected = NO;
    
    [self dismissController];
}

- (void)bufferProgress:(CGFloat)progress{
    NSLog(@"正在缓冲中:%lf",progress);
}

- (void)readyLrc{
    self.lrcViewController.lrcModels = [SYLrcDataTool getLrcModelsWithLrcPath:[SYMusicPalyManager shareSYMusicPalyManager].messageModel. musicModel.lrcPath];
}

- (void)updateLrcByOneFrame{
    [self updateLrcUI];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
