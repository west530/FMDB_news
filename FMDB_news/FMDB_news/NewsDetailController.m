//
//  NewsDetailController.m
//  水云天
//
//  Created by iMac on 16/6/23.
//  Copyright © 2016年 Sinfotek. All rights reserved.
//

#import "NewsDetailController.h"
#import "WebViewJavascriptBridge.h"
#import "AFNetworking.h"
#import "NewsDetailModel.h"
#import "DataBase.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kTabbarHeight 49
#define kNavHeight 64


@interface NewsDetailController ()<UIWebViewDelegate>

@property (nonatomic, strong)AFHTTPSessionManager *manager;
@property (nonatomic, strong)WebViewJavascriptBridge *bridge;
@property (nonatomic, strong)UIWebView *webView;


@end

@implementation NewsDetailController {
    
    
    NSMutableString *titleStr;
    NSString *intro;
    NSString *imgURL;
    BOOL isCollected;
    UIActivityIndicatorView *activityView;

}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    activityView = [[UIActivityIndicatorView  alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:activityView];
    
    

    [self initWebView];
    
    [self loadNews];//加载新闻
    
    
}


- (void)initWebView {
    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _webView.opaque = NO;
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.delegate = self;
    _webView.userInteractionEnabled = YES;
    _webView.scrollView.bounces = NO;
    [self.view addSubview:_webView];
}


- (void)loadNews {
    _manager = [AFHTTPSessionManager manager];

    /**
     *  从本地取出内容字典
     */
    NSDictionary *dic = [[DataBase sharedDataBase] getNewsDetailWithNewsUrl:self.newsUrl];
    if (dic.count > 0) {  //如果本地存在
        
        //新闻的html
        NSMutableString *htmlStr = [[NSMutableString alloc]initWithString:dic[@"content"] ];
        //写一段接收主标题的html字符串,直接拼接到字符串
        titleStr = [dic objectForKey:@"title"];
        NSMutableString *sourceStr = [dic objectForKey:@"author"];
        NSMutableString *ptimeStr = [dic objectForKey:@"articleModifyDate"];
        NSInteger readNum = [[dic objectForKey:@"hits"] integerValue];
        
        NSMutableString *allTitleStr = [NSMutableString stringWithFormat:@"<p><span style=\"line-height:1;font-size:19px;\"><strong>%@</strong></span></strong></p><p><span style=\"font-size:12px;font-weight:normal;line-height:0.001;color:#666666;\">%@ %@  阅读:%ld</span></p>",titleStr,sourceStr,ptimeStr,readNum];
        NSString * newHtmlStr = [allTitleStr stringByAppendingString:htmlStr];
        
        //设置导航栏为当前新闻的名字
        self.navigationItem.title = titleStr;
        
        //加载html
        [_webView loadHTMLString:[self reSizeImageWithHTML:newHtmlStr] baseURL:nil];
        
        
        
    }
    else {
        
        [_manager GET:self.newsUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            if ([responseObject[@"type"] isEqualToString:@"success"]) {
                
                
                //新闻的html
                NSMutableString *htmlStr = [[NSMutableString alloc]initWithString:responseObject[@"data"][@"content"] ];

                
                //写一段接收主标题的html字符串,直接拼接到字符串
                titleStr = [responseObject[@"data"] objectForKey:@"title"];
                NSMutableString *sourceStr = [responseObject[@"data"] objectForKey:@"author"];
                NSMutableString *ptimeStr = [responseObject[@"data"] objectForKey:@"articleModifyDate"];
                NSInteger readNum = [[responseObject[@"data"] objectForKey:@"hits"] integerValue];
                
                NSMutableString *allTitleStr = [NSMutableString stringWithFormat:@"<p><span style=\"line-height:1;font-size:19px;\"><strong>%@</strong></span></strong></p><p><span style=\"font-size:12px;font-weight:normal;line-height:0.001;color:#666666;\">%@ %@  阅读:%ld</span></p>",titleStr,sourceStr,ptimeStr,readNum];
                NSString * newHtmlStr = [allTitleStr stringByAppendingString:htmlStr];
                
                
                //设置导航栏为当前新闻的名字
                self.navigationItem.title = titleStr;
                
                //加载html
                [_webView loadHTMLString:[self reSizeImageWithHTML:newHtmlStr] baseURL:nil];
                
                /**
                 *  存储得到的数据
                 */
                NewsDetailModel *model = [[NewsDetailModel alloc]init];
                model.newsUrl = self.newsUrl;
                model.dataContent = (NSDictionary *)responseObject[@"data"];
                [[DataBase sharedDataBase] addNewsDetail:model]; //添加到数据库
                
            }
            else {
                
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 100, kScreenWidth-40, 100)];
            label.textColor = [UIColor lightGrayColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = error.userInfo[@"NSLocalizedDescription"];
            label.font = [UIFont systemFontOfSize:15];
            [self.view addSubview:label];
            
        }];
        
    }

    
}


//牛逼的缩放
- (NSString *)reSizeImageWithHTML:(NSString *)html {
    
    return [NSString stringWithFormat:@"<html><head><style>img{max-width:%f;height:auto !important;width:auto !important;};</style><style>video{max-width:%f;height:auto !important;width:auto !important;};</style></head><body style='margin:8; padding:0;'>%@</body></html>",kScreenWidth-16,kScreenWidth-16, html];
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
    [activityView startAnimating];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [activityView stopAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [activityView stopAnimating];
    
}




- (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    if (self.isViewLoaded && !self.view.window)// 是否是正在使用的视图
    {
        self.view = nil;// 目的是再次进入时能够重新加载调用viewDidLoad函数。
    }
    
    
}

- (void)dealloc
{
    for (UIView *v in self.view.subviews) {
        [v removeFromSuperview];
        self.view = nil;
        [self.view removeFromSuperview];
    }
}

@end
