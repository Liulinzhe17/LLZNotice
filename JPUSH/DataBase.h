//
//  DataBase.h
//  JPUSH
//
//  Created by 柳麟喆 on 2017/6/10.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class History;

@interface DataBase : NSObject

@property(nonatomic,strong)History *history;


+ (instancetype)sharedDataBase;


#pragma mark - History
/**
 *  添加history
 *
 */
- (void)addHistory:(History *)history;
/**
 *  删除history
 *
 */
- (void)deleteHistory:(History *)history;
/**
 *  更新history
 *
 */
- (void)updateHistory:(History *)history;

/**
 *  获取所有数据
 *
 */
- (NSMutableArray *)getAllHistory;



@end
