//
//  Record.h
//  JPUSH
//
//  Created by 柳麟喆 on 2017/6/5.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Record : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *Detail;
@property (strong, nonatomic) IBOutlet UILabel *Time;
@property (strong, nonatomic) IBOutlet UILabel *State;

@end
