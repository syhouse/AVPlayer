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

#define url @"http://other.web.ra01.sycdn.kuwo.cn/resource/n3/128/17/55/3616442357.mp3"

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
            [[SYMusicPalyManager shareSYMusicPalyManager] prepareToPlayMusicWithUrl:url delegate:controller autoPlay:YES];
        }
            break;
            
        case 1:
        {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"曲婉婷 - Jar Of Love" ofType:@"mp3"];
            [[SYMusicPalyManager shareSYMusicPalyManager] prepareToPlayMusicWithFilePath:filePath delegate:controller autoPlay:NO];
            break;
        }
        case 2:
        {
            NSArray *urls = @[@"http://service1.gzebook.cn/upload/listen/mp3/xc/grade5-2-module1.mp3",@"http://service1.gzebook.cn/upload/listen/mp3/grade7-1-unit2.mp3",@"http://service1.gzebook.cn/upload/listen/mp3/grade9-1-unit2-dy.mp3"];
            [[SYMusicPalyManager shareSYMusicPalyManager] prepareToPlayMusicWithUrls:urls delegate:controller autoPlay:YES];
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

