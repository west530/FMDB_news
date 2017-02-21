//
//  DataBase.m
//  FMDB数据库
//
//  Created by iMac on 17/2/21.
//  Copyright © 2017年 zws. All rights reserved.
//

#import "DataBase.h"
#import "FMDB.h"

static DataBase *_DBCtl = nil;

@interface DataBase()<NSCopying,NSMutableCopying>{
    FMDatabase  *_db;
    
}

@end



@implementation DataBase


+(instancetype)sharedDataBase{
    
    if (_DBCtl == nil) {
        
        _DBCtl = [[DataBase alloc] init];
        
        [_DBCtl initDataBase];
        
    }
    
    return _DBCtl;
    
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    
    if (_DBCtl == nil) {
        
        _DBCtl = [super allocWithZone:zone];
        
    }
    
    return _DBCtl;
    
}

-(id)copy{
    
    return self;
    
}

-(id)mutableCopy{
    
    return self;
    
}

-(id)copyWithZone:(NSZone *)zone{
    
    return self;
    
}

-(id)mutableCopyWithZone:(NSZone *)zone{
    
    return self;
    
}


-(void)initDataBase{
    // 获得Documents目录路径
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    // 文件路径
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"newsSql.sqlite"];
    NSLog(@"%@",filePath);
    // 实例化FMDataBase对象
    
    _db = [FMDatabase databaseWithPath:filePath];
    
    [_db open];
    
    // 初始化数据表
    NSString *newsSql = @"CREATE TABLE IF NOT EXISTS 'news' ('cellTitle' VARCHAR(255),'source' VARCHAR(255),'imageUrl' VARCHAR(255),'newsUrl' VARCHAR(255),'newsID'VARCHAR(255)PRIMARY KEY) ";
    [_db executeUpdate:newsSql];
    
    
    
    NSString *newsDetailSql = @"CREATE TABLE IF NOT EXISTS 'newsDetail' ('newsUrl' VARCHAR(255)PRIMARY KEY,'dataContent' VARCHAR(255)) ";
    [_db executeUpdate:newsDetailSql];

    
    
    [_db close];
    
}

#pragma mark - 接口

- (void)addNews:(DynamicModel *)dynamicModel {
    [_db open];
    
    
    [_db executeUpdate:@"INSERT INTO news(cellTitle,source,imageUrl,newsUrl,newsID)VALUES(?,?,?,?,?)",dynamicModel.cellTitle,dynamicModel.source,dynamicModel.imageUrl,dynamicModel.newsUrl,dynamicModel.newsID];
    
    
    [_db close];
    
}

/*
- (void)deleteNews:(DynamicModel *)dynamicModel {
    [_db open];
    
    [_db executeUpdate:@"DELETE FROM news WHERE newsID = ?",dynamicModel.newsID];
    
    [_db close];
}

- (void)updateNews:(DynamicModel *)dynamicModel {
    [_db open];
    
    [_db executeUpdate:@"UPDATE 'news' SET cellTitle = ?  WHERE newsID = ? ",@"修改的名称",dynamicModel.newsID];
//    [_db executeUpdate:@"UPDATE 'news' SET person_age = ?  WHERE person_id = ? ",@(person.age),person.ID];
//    [_db executeUpdate:@"UPDATE 'news' SET person_number = ?  WHERE person_id = ? ",@(person.number + 1),person.ID];
    
    
    
    [_db close];
}
*/

- (NSMutableArray *)getAllNews {
    [_db open];
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    FMResultSet *res = [_db executeQuery:@"SELECT * FROM news"];
    while ([res next]) {
        DynamicModel *model = [[DynamicModel alloc] init];
        model.cellTitle = [res stringForColumn:@"cellTitle"];
        model.source = [res stringForColumn:@"source"];
        model.imageUrl = [res stringForColumn:@"imageUrl"];
        model.newsUrl = [res stringForColumn:@"newsUrl"];
        model.newsID = [res stringForColumn:@"newsID"];
        
        [dataArray addObject:model];
        
    }
    
    [_db close];
    
    
    
    return dataArray;
}



#pragma mark - 新闻详情
- (void)addNewsDetail:(NewsDetailModel *)newsDetailModel {
    [_db open];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:newsDetailModel.dataContent options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [_db executeUpdate:@"INSERT INTO newsDetail(newsUrl,dataContent)VALUES(?,?)",newsDetailModel.newsUrl,jsonStr];
    
    
    [_db close];
}

- (NSDictionary *)getNewsDetailWithNewsUrl:(NSString *)newsUrl {
    [_db open];

    FMResultSet *set = [_db executeQuery:@"SELECT * FROM newsDetail"];
    while ([set next]) {
        
        NSString *str  = [set stringForColumn:@"newsUrl"];
        if ([newsUrl isEqualToString:str]) {
            
            NSString *jsonStr  = [set stringForColumn:@"dataContent"];
            NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
            if(err) {
                return nil;
            }
            return dic;
            
        }

    }
    
    [_db close];

    return nil;
}



@end
