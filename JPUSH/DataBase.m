//
//  DataBase.m
//  JPUSH
//
//  Created by 柳麟喆 on 2017/6/10.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import "DataBase.h"
#import <FMDB.h>
#import "History.h"

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
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"model.sqlite"];
    
    // 实例化FMDataBase对象
    
    _db = [FMDatabase databaseWithPath:filePath];
    
    [_db open];
    
    // 初始化数据表
    NSString *historySql = @"CREATE TABLE 'history' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL ,'history_id' VARCHAR(255),'history_time' VARCHAR(255),'history_detail' VARCHAR(255),'history_state' VARCHAR(255)) ";
    
    [_db executeUpdate:historySql];
    
    
    [_db close];
    
}
#pragma mark - 接口

- (void)addHistory:(History *)history{
    [_db open];
    
    NSNumber *maxID = @(0);
    
    FMResultSet *res = [_db executeQuery:@"SELECT * FROM history "];
    //获取数据库中最大的ID
    while ([res next]) {
        if ([maxID integerValue] < [[res stringForColumn:@"history_id"] integerValue]) {
            maxID = @([[res stringForColumn:@"history_id"] integerValue] ) ;
        }
        
    }
    maxID = @([maxID integerValue] + 1);
    
    [_db executeUpdate:@"INSERT INTO history(history_id,history_time,history_detail,history_state)VALUES(?,?,?,?)",maxID,history.Time,history.Detail,history.State];
    
    
    
    [_db close];
    
}

- (void)deleteHistory:(History *)history{
    [_db open];
    
    [_db executeUpdate:@"DELETE FROM history WHERE history_id = ?",history.ID];
    
    [_db close];
}

- (void)updateHistory:(History *)history{
    [_db open];
    
    [_db executeUpdate:@"UPDATE 'history' SET history_detail = ?  WHERE history_id = ? ",history.Detail,history.ID];
    [_db executeUpdate:@"UPDATE 'history' SET history_time = ?  WHERE history_id = ? ",history.Time,history.ID];
    [_db executeUpdate:@"UPDATE 'history' SET history_state = ?  WHERE history_id = ? ",history.State,history.ID];
    
    
    
    [_db close];
}

- (NSMutableArray *)getAllHistory{
    [_db open];
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    FMResultSet *res = [_db executeQuery:@"SELECT * FROM history order by history_time desc"];
    
    while ([res next]) {
        History *history = [[History alloc] init];
        history.ID = @([[res stringForColumn:@"history_id"] integerValue]);
        history.Detail = [res stringForColumn:@"history_detail"];
        history.Time = [res stringForColumn:@"history_time"];
        history.State = [res stringForColumn:@"history_state"];
        
        [dataArray addObject:history];
        
    }
    
    [_db close];
    
    
    
    return dataArray;
    
    
}
@end

