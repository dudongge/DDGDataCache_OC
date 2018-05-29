//
//  ViewController.m
//  DDGDataCache
//
//  Created by dudongge on 2018/5/29.
//  Copyright © 2018年 dudongge. All rights reserved.
//

#import "ViewController.h"
#import "DDGDataCache.h"
#import "DDGTestNet.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *logLabel;

/**
 *  模拟数据请求URL
 */
@property (nonatomic, copy) NSString *URL;

/**
 请求参数
 */
@property(nonatomic,strong)NSDictionary *params;

/**
 *  服务器返回数据
 */
@property (nonatomic, strong) id responseObject;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource =  @[@"😜同步写入/更新缓存(只有主目录)",
                        @"📷同步写入/更新缓存(有二级目录)",
                        @"🐥异步写入/更新缓存（只有主目录)",
                        @"🍌异步写入/更新缓存（有二级目录)",
                        @"🐒获取全部缓存数据（主目录)",
                        @"🌧获取指定缓存数据（二级目录)",
                        @"🌞获取全部缓存大小",
                        @"🌛获取指定缓存大小",
                        @"🚚获取主缓存路径",
                        @"🚄获取指定缓存路径",
                        @"🍓清除全部缓存",
                        @"🍎清除指定缓存"];
    self.tableView = [[UITableView alloc]init];
    self.tableView.frame = CGRectMake(10, 90, self.view.frame.size.width - 20, self.view.frame.size.height - 250);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:self.tableView];
    
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.frame = CGRectMake(10, 30, self.view.frame.size.width - 20, 40);
    self.titleLabel.text = @"DDGDataCache 的功能用法";
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor redColor];
    [self.view addSubview:self.titleLabel];
    
    self.logLabel = [[UILabel alloc]init];
    self.logLabel.frame = CGRectMake(10, self.tableView.frame.origin.y + self.tableView.frame.size.height, self.view.frame.size.width - 20, 200);
    self.logLabel.text = @"打印控制台信息";
    self.logLabel.numberOfLines = 0;
    self.logLabel.textAlignment = NSTextAlignmentCenter;
    self.logLabel.textColor = [UIColor greenColor];
    [self.view addSubview:self.logLabel];
    
    self.URL = @"https://github.com/dudongge/DDGDataCache_OC";
    self.params =@{@"dudongge":@"10001"};
    [DDGTestNet getWithURL:self.URL params:self.params success:^(id response) {
        
        self.responseObject = response;
        
    } failure:^(NSError *error) {
        
    }];
    

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
    if (indexPath.row == 0) {
       BOOL result = [DDGDataCache saveJsonResponseToCacheFile:self.responseObject andURL:self.URL path:@"appCahe" andSubPath:@""];
        if (result) {
            NSString *logStr = @"😆同步写入主目录)保存/更新成功";
            [self updadateLog: logStr];
        } else {
            NSString *logStr = @"😤(同步写入主目录)保存/更新失败";
            [self updadateLog: logStr];
        }
    }else if (indexPath.row == 1) {
        BOOL result = [DDGDataCache saveJsonResponseToCacheFile:self.responseObject andURL:self.URL path:@"appCahe" andSubPath:@"userInfo"];
        if (result) {
            NSString *logStr = @"📷同步写入/更新缓存成功(有二级目录)";
            [self updadateLog: logStr];
        } else {
            NSString *logStr = @"😤(同步写入/更新缓存(有二级目录)保存/更新失败";
            [self updadateLog: logStr];
        }
        
    }else if (indexPath.row == 2) {
        [DDGDataCache save_asyncJsonResponseToCacheFile:self.responseObject andURL:self.URL path:@"appCahe" andSubPath:nil completed:^(BOOL result) {
            if (result) {
                NSString *logStr = @"😆异步写入主目录)保存/更新成功";
                [self updadateLog: logStr];
            } else {
                NSString *logStr = @"😤(异步写入主目录)保存/更新失败";
                [self updadateLog: logStr];
            }
        }];
    }else if (indexPath.row == 3) {
        [DDGDataCache save_asyncJsonResponseToCacheFile:self.responseObject andURL:self.URL path:@"appCahe" andSubPath:@"MaName" completed:^(BOOL result) {
            if (result) {
                NSString *logStr = @"📷同步写入/更新缓存成功(有二级目录)";
                [self updadateLog: logStr];
            } else {
                NSString *logStr = @"😤(同步写入/更新缓存(有二级目录)保存/更新失败";
                [self updadateLog: logStr];
            }
        }];
    }else if (indexPath.row == 4) {
        //获取全部缓存
        id json = [DDGDataCache cacheJsonWithURL:self.URL subPath:@""];
        NSString *jsonStr = [NSString stringWithFormat:@"%@",json];
        [self updadateLog: jsonStr];
    }else if (indexPath.row == 5) {
        //获取指定目录缓存
        id json = [DDGDataCache cacheJsonWithURL:self.URL subPath:@"MaName"];
        NSString *jsonStr = [NSString stringWithFormat:@"%@",json];
        [self updadateLog: jsonStr];
    }else if (indexPath.row == 6) {
        float size = [DDGDataCache cacheAllSize];
        [self updadateLog: [NSString stringWithFormat:@"全部缓存大小:%fM",size]];
    }else if (indexPath.row == 7) {
        float size = [DDGDataCache cacheSizeWithSubPath:@"MaName"];
        [self updadateLog: [NSString stringWithFormat:@"全部缓存大小:%fM",size]];
    }else if (indexPath.row == 8) {
        NSString *path = [DDGDataCache cachePath];
        [self updadateLog: [NSString stringWithFormat:@"path=%@",path]];
    }else if (indexPath.row == 9) {
        NSString *path = [DDGDataCache cacheSubPath:@"userInfo"];
        [self updadateLog: [NSString stringWithFormat:@"path=%@",path]];
    }else if (indexPath.row == 10) {
        BOOL result = [DDGDataCache clearAllCache];
        if (result) {
            [self updadateLog: @"缓存清除成功"];
        } else {
            [self updadateLog: @"缓存清除失败"];
        }
    }else if (indexPath.row == 11) {
        BOOL result = [DDGDataCache clearCacheWithSubPath:@"userInfo"];
        if (result) {
            [self updadateLog: @"缓存清除成功"];
        } else {
            [self updadateLog: @"缓存清除失败"];
        }
    }
}

-(void) updadateLog:(NSString * )log {
    self.logLabel.text = log;
}
@end
