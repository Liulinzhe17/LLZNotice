//
//  RecordViewController.m
//  JPUSH
//
//  Created by 柳麟喆 on 2017/6/5.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import "RecordViewController.h"
#import "Record.h"
#import "DataBase.h"
#import "History.h"
#import "MJRefresh.h"

@interface RecordViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *dataArray;

@end

@implementation RecordViewController

-(UITableView *)tableView{
    if (_tableView==nil) {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
        _tableView.rowHeight=50;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.dataSource=self;
        _tableView.delegate=self;
        _tableView.mj_header=[MJRefreshNormalHeader headerWithRefreshingBlock:^{
            self.dataArray = [[DataBase sharedDataBase] getAllHistory];
            [self.tableView reloadData];
            // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 结束刷新
                [_tableView.mj_header endRefreshing];
            });
        }];
    }
    return _tableView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"历史记录";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addData)];
    
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.dataArray = [[DataBase sharedDataBase] getAllHistory];
    [self.tableView.mj_header beginRefreshing];
}


#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier =@"Record";
    Record *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell==nil)
    {
        cell=[[[NSBundle mainBundle]loadNibNamed:@"Record" owner:nil options:nil]lastObject];
    }
    
    History *history = self.dataArray[indexPath.row];
    
    cell.Time.text=history.Time;
    cell.Detail.text=history.Detail;
    //设置时间的颜色和倾斜度
    cell.Time.textColor=[UIColor grayColor];
    CGAffineTransform matrix = CGAffineTransformMake(1, 0, tanf(-15 * (CGFloat)M_PI / 180), 1, 0, 0);
    cell.Time.transform = matrix;
    //状态改变、更新数据库
    NSDate *date=[self datefromstring:history.Time];
    int result=[self compareCurrentTime:date];
    if (result==1) {
        if ([history.State isEqualToString:@"未完成"]){
            history.State=@"完成";
            [[DataBase sharedDataBase] updateHistory:history];
            self.dataArray = [[DataBase sharedDataBase] getAllHistory];
        }
        cell.State.text=history.State;
        cell.State.textColor=[UIColor greenColor];
    }else{
        cell.State.text=history.State;
        cell.State.textColor=[UIColor redColor];
    }
    if (cell.Detail.frame.size.width>self.view.frame.size.width-100) {
        NSLog(@"11111");
    }
    return cell;
    
}



/**
 *  设置删除按钮
 *
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete){
        
        History *history = self.dataArray[indexPath.row];
        
        [[DataBase sharedDataBase] deleteHistory:history];
        
        self.dataArray = [[DataBase sharedDataBase] getAllHistory];
        
        [self.tableView reloadData];
        
        
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
//    PersonCarsViewController *pcvc = [[PersonCarsViewController alloc] init];
//    pcvc.person = self.dataArray[indexPath.row];
//    
//    [self.navigationController pushViewController:pcvc animated:YES];
    
    
    
    
    //    Person *person = self.dataArray[indexPath.row];
    //
    //    person.name = [NSString stringWithFormat:@"%@",person.name];
    //
    //    person.age = arc4random_uniform(100) + 1;
    //    [[DataBase sharedDataBase] updatePerson:person];
    //
    //    self.dataArray = [[DataBase sharedDataBase] getAllPerson];
    //
    //    [self.tableView reloadData];
    
}



#pragma mark - Action
/**
 *  添加数据到数据库
 */
- (void)addData{
    
    NSLog(@"addData");
    
    int nameRandom = arc4random_uniform(1000);
    int ageRandom  = arc4random_uniform(100) + 1;
    
    NSString *detail = [NSString stringWithFormat:@"person_%d号",nameRandom];
    NSString *time=[NSString stringWithFormat:@"%d",ageRandom];
    
    History *history = [[History alloc] init];
    history.Time = time;
    history.State =@"未完成";
    history.Detail=detail;
    
    
    [[DataBase sharedDataBase] addHistory:history];
    
    self.dataArray = [[DataBase sharedDataBase] getAllHistory];
    
    [self.tableView reloadData];
    
    
}


#pragma mark - Getter
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
        
    }
    return _dataArray;
    
}
//字符串转日期
-(NSDate *)datefromstring:(NSString *)dateStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *changeDate = [dateFormatter dateFromString:dateStr];
    return changeDate;
}
//日期转字符串
-(NSString *) stringfromdate :(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    return dateStr;
}
//比较当前时间是否大于任务时间 大返回1 小返回-1
-(int)compareCurrentTime:(NSDate*) compareDate
{
    NSTimeInterval  timeInterval = [compareDate timeIntervalSinceNow];
    timeInterval =-timeInterval;
    long temp=0;
    if((temp = timeInterval) >0)
    {
        return 1;
    }
    return -1;
}
@end