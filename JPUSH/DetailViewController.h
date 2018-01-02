//
//  DetailViewController.h
//  JPUSH
//
//  Created by 柳麟喆 on 2017/10/15.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (nonatomic, copy) NSString *timeText;
@property (nonatomic, copy) NSString *stateText;
@property (nonatomic, copy) NSString *detailText;
@property (strong, nonatomic) IBOutlet UILabel *time;
@property (strong, nonatomic) IBOutlet UILabel *state;
@property (strong, nonatomic) IBOutlet UITextView *detail;

@end
