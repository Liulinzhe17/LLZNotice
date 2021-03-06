//
//  RecordViewController.m
//  JPUSH
//
//  Created by 柳麟喆 on 2017/6/5.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import "RecordViewController.h"
#import "DetailViewController.h"
#import "SearchViewController.h"
#import "Record.h"
#import "DataBase.h"
#import "History.h"
#import "MJRefresh.h"
#import "LLZHelper.h"

@interface RecordViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchControllerDelegate>

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *dataArray;
@property(nonatomic,strong)UISearchController *serachController;

@end

@implementation RecordViewController
#pragma mark - *******懒加载*******
- (UISearchController *)serachController{
    if(_serachController==nil){
        SearchViewController *display = [[SearchViewController alloc]init];
        UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:display];
        _serachController=[[UISearchController alloc]initWithSearchResultsController:nav];
        _serachController.searchResultsUpdater=display;
        _serachController.delegate=self;
        _serachController.hidesNavigationBarDuringPresentation=YES;
        _serachController.obscuresBackgroundDuringPresentation=YES;
        _serachController.searchBar.barTintColor=[UIColor yellowColor];
        _serachController.searchBar.tintColor=[UIColor blueColor];
        _serachController.searchBar.placeholder=@"搜索";
        _serachController.searchBar.translucent=YES;
        [_serachController.searchBar sizeToFit];
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
//        _tableView.mj_header=[MJRefreshNormalHeader headerWithRefreshingBlock:^{
//            [self updateRecord];
//        }];
    }
    return _tableView;
}

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

#pragma mark - *******视图生命周期*******
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpView];
    self.definesPresentationContext=YES;
    //不拓展
//    self.serachController.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.dataArray = [[DataBase sharedDataBase] getAllHistory];
//   [self.tableView.mj_header beginRefreshing];
}
#pragma mark - *******视图加载*******
- (void)setUpView{
    self.navigationItem.title=@"历史记录";
    [self.view addSubview:self.tableView];
    //添加导航栏上的右按钮
    UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 32, 32)];
    [rightBtn setImage:[UIImage imageNamed:@"updatePic.png"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(updateRecord) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

#pragma mark - *******tableview代理方法*******
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
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
    history = self.dataArray[indexPath.row];
    
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
        history=self.dataArray[indexPath.row];
        [self.dataArray removeObjectAtIndex:indexPath.row];
        [[DataBase sharedDataBase] deleteHistory:history];
        [self.tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView cellForRowAtIndexPath:indexPath].selected=NO;
    History *h;
    h=self.dataArray[indexPath.row];
    DetailViewController *detailVC=[[DetailViewController alloc]init];
    detailVC.timeText=h.Time;
    detailVC.detailText=h.Detail;
    detailVC.stateText=h.State;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)willPresentSearchController:(UISearchController *)searchController{
    self.tabBarController.tabBar.hidden=YES;
}

- (void)willDismissSearchController:(UISearchController *)searchController{
    self.tabBarController.tabBar.hidden=NO;
    [self updateRecord];
}

#pragma mark - *******刷新tableviewcell*******
- (void)updateRecord{
    self.dataArray = [[DataBase sharedDataBase] getAllHistory];
    [self.tableView reloadData];
//    [self.tableView.mj_header endRefreshing];
}

@end
