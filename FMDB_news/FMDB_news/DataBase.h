//
//  DataBase.h
//  FMDB数据库
//
//  Created by iMac on 17/2/21.
//  Copyright © 2017年 zws. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DynamicModel.h"
#import "NewsDetailModel.h"

@interface DataBase : NSObject


@property(nonatomic,strong) DynamicModel *dynamicModel;


+ (instancetype)sharedDataBase;


#pragma mark - 新闻列表
/**
 *  添加person
 *
 */
- (void)addNews:(DynamicModel *)dynamicModel;
///**
// *  删除person
// *
// */
//- (void)deleteNews:(DynamicModel *)dynamicModel;
///**
// *  更新person
// *
// */
//- (void)updateNews:(DynamicModel *)dynamicModel;

/**
 *  获取所有数据
 *
 */
- (NSMutableArray *)getAllNews;



#pragma mark - 新闻详情
- (void)addNewsDetail:(NewsDetailModel *)newsDetailModel;

- (NSDictionary *)getNewsDetailWithNewsUrl:(NSString *)newsUrl;


@end
