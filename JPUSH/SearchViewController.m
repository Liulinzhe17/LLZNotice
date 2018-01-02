//
//  SearchViewController.m
//  JPUSH
//
//  Created by 柳麟喆 on 2018/1/1.
//  Copyright © 2018年 lzLiu. All rights reserved.
//

#import "SearchViewController.h"
#import "DetailViewController.h"
#import "DataBase.h"
#import "Record.h"
#import "History.h"
#import "LLZHelper.h"

@interface SearchViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *searchArray;
@property(nonatomic,strong)NSMutableArray *dataArray;

@end

@implementation SearchViewController

#pragma mark - *******懒加载*******
- (UITableView *)tableView{
    if (_tableView==nil) {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
        _tableView.rowHeight=50;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.dataSource=self;
        _tableView.delegate=self;
    }
    return _tableView;
}

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (NSMutableArray *)searchArray{
    if (!_searchArray) {
        _searchArray = [[NSMutableArray alloc] init];
    }
    return _searchArray;
}

#pragma mark - *******视图生命周期*******
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.dataArray = [[DataBase sharedDataBase] getAllHistory];
}

#pragma mark - *******tableview代理方法*******
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier =@"Record";
    Record *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell==nil)
    {
        cell=[[[NSBundle mainBundle]loadNibNamed:@"Record" owner:nil options:nil]lastObject];
    }
    History *history;
    history = self.searchArray[indexPath.row];
    
    cell.Time.text=history.Time;
    cell.Detail.text=history.Detail;
    //设置时间的颜色和倾斜度
    cell.Time.textColor=[UIColor grayColor];
    CGAffineTransform matrix = CGAffineTransformMake(1, 0, tanf(-15 * (CGFloat)M_PI / 180), 1, 0, 0);
    cell.Time.transform = matrix;
    //状态改变、更新数据库
    NSDate *date=[LLZHelper LLZDateFromString:history.Time Formatter:@"yyyy-MM-dd HH:mm:ss"];
    int result=[LLZHelper LLZCompareCurrentTime:date];
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
    return cell;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    //删除按钮
    if (editingStyle == UITableViewCellEditingStyleDelete){
        History *history;
        history=self.searchArray[indexPath.row];
        [self.searchArray removeObjectAtIndex:indexPath.row];
        [self.dataArray removeObjectAtIndex:indexPath.row];
        [[DataBase sharedDataBase] deleteHistory:history];
        [self.tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [self tableViewCellMove:120];//防止点击时tableview下移
    [tableView cellForRowAtIndexPath:indexPath].selected=NO;
    History *h;
    h=self.searchArray[indexPath.row];
    DetailViewController *detailVC=[[DetailViewController alloc]init];
    detailVC.timeText=h.Time;
    detailVC.detailText=h.Detail;
    detailVC.stateText=h.State;
    [self.presentingViewController.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - *******搜索框代理方法*******
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    CGRect rect = self.tableView.frame;
    NSLog(@"*******tableHeaderView:%@*******",NSStringFromCGRect(rect));
    if (self.tableView.frame.origin.y!=76) {
        [self tableViewCellMove:76];
    }
    NSString *searchString=[searchController.searchBar text];
    if(self.searchArray!=nil){
        [self.searchArray removeAllObjects];
    }
    for (int i=0; i<self.dataArray.count; i++) {
        History *h=self.dataArray[i];
        if([h.Detail rangeOfString:searchString].location!=NSNotFound){
            [self.searchArray addObject:self.dataArray[i]];
        }
    }
    [self.tableView reloadData];
}

#pragma mark - *******tableviewcell移动*******
- (void)tableViewCellMove: (CGFloat)value{
    CGFloat y = -value;
    CGFloat x = self.tableView.frame.origin.x;
    CGFloat height = [UIScreen mainScreen].bounds.size.height+value;
    CGFloat width = self.tableView.frame.size.width;
    CGRect rect = CGRectMake(x, y, width, height);
    [self.tableView setFrame:rect];
}
@end
