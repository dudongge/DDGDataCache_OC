//
//  ViewController.m
//  DDGDataCache
//
//  Created by dudongge on 2018/5/29.
//  Copyright © 2018年 dudongge. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource =  @[@"😜同步写入/更新缓存(只有主目录)",
                        @"📷同步写入/更新缓存(有二级目录)",
                        @"🐥异步写入/更新缓存（只有主目录",
                        @"🍌异步写入/更新缓存（有二级目录",
                        @"🐒获取全部缓存数据（主目录",
                        @"🌧获取指定缓存数据（二级目录",
                        @"🌞获取全部缓存大小",
                        @"🌛获取指定缓存大小",
                        @"🚚获取主缓存路径",
                        @"🚄获取指定缓存路径",
                        @"🍓清除全部缓存",
                        @"🍎清除指定缓存"];
    self.tableView = [[UITableView alloc]init];
    self.tableView.frame = CGRectMake(10, 90, self.view.frame.size.width - 20, self.view.frame.size.height - 300);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:self.tableView];
   
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(self.dataSource[indexPath.row]);
}
@end
