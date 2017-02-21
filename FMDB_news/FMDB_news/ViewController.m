//
//  ViewController.m
//  FMDB数据库
//
//  Created by iMac on 17/2/21.
//  Copyright © 2017年 zws. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "DataBase.h"
#import "DynamicModel.h"
#import "DynamicCell.h"

#import "NewsDetailController.h"

@interface ViewController ()


/**
 *  数据源
 */
@property(nonatomic,strong) NSMutableArray *modelArray;



@end

@implementation ViewController {
    AFHTTPSessionManager *manager;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"FMDB数据库";
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    
    manager = [AFHTTPSessionManager manager];
    
    
    BOOL isNewsFirstCome = [[NSUserDefaults standardUserDefaults] objectForKey:@"isNewsFirstCome"];
    if (isNewsFirstCome == NO) {
        NSLog(@"是第一次请求");
        
        [self requestNet];
        
        
    }else {
        
        NSLog(@"不是第一次进来了");
        self.modelArray = [[DataBase sharedDataBase] getAllNews];
        [self.tableView reloadData];
    }
    
    
}


- (void)requestNet {
    
    //文章列表
    NSString *articleURL = @"http://118.26.64.162:9832/app/rest/app/article/list/25?pageNumber=1&pageSize=15&orders[0].property=createDate&orders[0].direction=desc";
    [manager GET:articleURL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray *articleArray = responseObject[@"data"][@"content"];
        self.modelArray = [NSMutableArray array];
        
        for (NSDictionary *dic in articleArray) {
            
            DynamicModel *model = [[DynamicModel alloc]init];
            
            model.cellTitle = dic[@"title"];//单元格上的主标题
            model.source = dic[@"author"];
            model.imageUrl = dic[@"image"];
            model.newsUrl = [NSString stringWithFormat:@"http://118.26.64.162:9832/app/rest/app/article/info/%@",dic[@"id"]];
            model.newsID = [dic[@"id"] stringValue];
            
            
            /**
             *   将缓存的新闻添加到数据库
             */
            [[DataBase sharedDataBase] addNews:model];
            
            [self.modelArray addObject:model];
        }
        
        
        [self.tableView reloadData];
        
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isNewsFirstCome"];//设置下一次不走这里了
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {}];
    
    
}




#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.modelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DynamicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[DynamicCell alloc ] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    cell.model = self.modelArray[indexPath.row];
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 85;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];    //取消cell选中功能
    
    NewsDetailController *newsCtrl = [[NewsDetailController alloc]init];
    DynamicModel *mod = self.modelArray[indexPath.row];
    newsCtrl.newsUrl = mod.newsUrl;
    [self.navigationController pushViewController:newsCtrl animated:YES];
}





@end
