//
//  DetailViewController.m
//  JPUSH
//
//  Created by 柳麟喆 on 2017/10/15.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"详情页";
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData{
    self.time.text=self.timeText;
    self.state.text=self.stateText;
    self.detail.text=self.detailText;
}

@end
