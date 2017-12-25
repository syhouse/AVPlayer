//
//  ViewController.m
//  AudioPlayer
//
//  Created by macmini on 2017/12/7.
//  Copyright © 2017年 macmini. All rights reserved.
//

#import "ViewController.h"
#import "SYPlayerController.h"

#import "SYMusicPalyManager.h"
#import "SYMusicModel.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView *tabelView;
@property(nonatomic,strong)NSArray *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = @[@"网络音频",@"本地音频",@"列表音频"];
    
    self.tabelView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tabelView.delegate = self;
    self.tabelView.dataSource = self;
    [self.view addSubview:self.tabelView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    NSInteger index = indexPath.row;
    SYPlayerController *controller = [[SYPlayerController alloc] init];
    [self presentViewController:controller animated:YES completion:nil];
    switch (index) {
        case 0:
        {
            SYMusicModel *song = [[SYMusicModel alloc] init];
            song.url = [NSURL URLWithString:@"http://cdn.y.baidu.com/43c48318c093c9277ea5b66ca163c5d6.mp3"];
            [[SYMusicPalyManager shareSYMusicPalyManager] prepareToPlayMusicWithSong:song delegate:controller autoPlay:YES];
        }
            break;
            
        case 1:
        {
            SYMusicModel *song = [[SYMusicModel alloc] init];
            song.url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"120125029" ofType:@"mp3"]];
            song.lrcPath = [[NSBundle mainBundle] pathForResource:@"120125029" ofType:@"lrc"];
            [[SYMusicPalyManager shareSYMusicPalyManager] prepareToPlayMusicWithSong:song delegate:controller autoPlay:YES];
            break;
        }
        case 2:
        {
            SYMusicModel *song1 = [[SYMusicModel alloc] init];
            song1.url = [NSURL URLWithString:@"http://service1.gzebook.cn/upload/listen/mp3/xc/grade5-2-module1.mp3"];
            SYMusicModel *song2 = [[SYMusicModel alloc] init];
            song2.url = [NSURL URLWithString:@"http://service1.gzebook.cn/upload/listen/mp3/grade7-1-unit2.mp3"];
            SYMusicModel *song3 = [[SYMusicModel alloc] init];
            song3.url = [NSURL URLWithString:@"http://service1.gzebook.cn/upload/listen/mp3/grade9-1-unit2-dy.mp3"];
            [[SYMusicPalyManager shareSYMusicPalyManager] prepareToPlayMusicWithSongs:@[song1,song2,song3] delegate:controller autoPlay:YES];
        }
            
        default:
            break;
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

