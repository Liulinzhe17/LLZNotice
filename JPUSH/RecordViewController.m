//
//  RecordViewController.m
//  JPUSH
//
//  Created by 柳麟喆 on 2017/6/5.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import "RecordViewController.h"
#import "DetailViewController.h"
#import "Record.h"
#import "DataBase.h"
#import "History.h"
#import "MJRefresh.h"
#import "LLZHelper.h"

@interface RecordViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchControllerDelegate,UISearchResultsUpdating>

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *dataArray;
@property(nonatomic,strong)UISearchController *serachController;
@property(nonatomic,strong)NSMutableArray *searchArray;

@end

@implementation RecordViewController
#pragma mark - *******懒加载*******
- (UISearchController *)serachController{
    if(_serachController==nil){
        _serachController=[[UISearchController alloc]initWithSearchResultsController:nil];
        _serachController.delegate=self;
        _serachController.searchResultsUpdater=self;
        _serachController.dimsBackgroundDuringPresentation=NO;
        _serachController.hidesNavigationBarDuringPresentation=YES;
        _serachController.hidesBottomBarWhenPushed=NO;
        _serachController.searchBar.backgroundImage=[UIImage new];
        //光标颜色
        [[[_serachController.searchBar.subviews objectAtIndex:0].subviews objectAtIndex:1] setTintColor:[UIColor redColor]];
        //字体颜色
        UITextField *searchField = [_serachController.searchBar valueForKey:@"_searchField"];
        searchField.textColor = [UIColor blueColor];
        //placeHolder颜色
        [searchField setValue:[UIColor greenColor] forKeyPath:@"_placeholderLabel.textColor"];
    }
    return _serachController;
}
- (UITableView *)tableView{
    if (_tableView==nil) {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
        _tableView.tableHeaderView=self.serachController.searchBar;
        _tableView.rowHeight=50;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.dataSource=self;
        _tableView.delegate=self;
        _tableView.mj_header=[MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self updateRecord];
        }];
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
    self.navigationItem.title=@"历史记录";
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.dataArray = [[DataBase sharedDataBase] getAllHistory];
//   [self.tableView.mj_header beginRefreshing];
    
}


#pragma mark - *******tableview代理方法*******
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.serachController.active?self.searchArray.count:self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier =@"Record";
    Record *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell==nil)
    {
        cell=[[[NSBundle mainBundle]loadNibNamed:@"Record" owner:nil options:nil]lastObject];
    }
    History *history;
    if (self.serachController.active) {
         history= self.searchArray[indexPath.row];
    }else{
         history = self.dataArray[indexPath.row];
    }
    
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
        if (self.serachController.active) {
            history=self.searchArray[indexPath.row];
            [self.searchArray removeObjectAtIndex:indexPath.row];
        }else{
            history=self.dataArray[indexPath.row];
        }
        [[DataBase sharedDataBase] deleteHistory:history];
        self.dataArray = [[DataBase sharedDataBase] getAllHistory];
        [self.tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    History *h;
    if (self.serachController.active) {
        h=self.searchArray[indexPath.row];
    }else{
        h=self.dataArray[indexPath.row];
    }
    DetailViewController *detailVC=[[DetailViewController alloc]init];
    detailVC.timeText=h.Time;
    detailVC.detailText=h.Detail;
    detailVC.stateText=h.State;
    [self.navigationController pushViewController:detailVC animated:YES];
    //收回搜索框
    self.serachController.active=NO;
}
#pragma mark - *******搜索框代理方法*******
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
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

- (void)willPresentSearchController:(UISearchController *)searchController{
    self.tabBarController.tabBar.hidden=YES;
}

- (void)willDismissSearchController:(UISearchController *)searchController{
    self.tabBarController.tabBar.hidden=NO;
}

#pragma mark - *******MJ刷新*******
-(void)updateRecord{
    self.dataArray = [[DataBase sharedDataBase] getAllHistory];
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
}
@end
