//
//  ViewController.m
//  JPUSH
//
//  Created by 柳麟喆 on 2017/3/19.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import "ViewController.h"
#import "RecordViewController.h"
#import "History.h"
#import "DataBase.h"
#import "Foundation+Log.m"
#import "LLZHelper.h"

#define MARGIN 20
#define TEXTVIEW_HEIGHT 100
#define BUTTON_HEIGHT TEXTVIEW_HEIGHT/2
#define DATEPICKER_HEIGHT TEXTVIEW_HEIGHT*2
#define TIMELABLE_HEIGHT MARGIN

@interface ViewController ()<UITextViewDelegate>

@property(nonatomic,strong)UIButton* button;/**< 测试注释 */
@property(nonatomic,strong)UITextView* textView;
@property(nonatomic,strong)UIDatePicker* picker;
@property(nonatomic,strong)UILabel* timeLable;
@property(nonatomic,copy)NSDate* selectTime;

@end

@implementation ViewController
#pragma mark - *******视图生命周期*******
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"发送通知";
    [self.textView becomeFirstResponder];//输入框成为第一响应者
    [self.view addSubview:self.button];
    [self.view addSubview:self.textView];
    [self.view addSubview:self.picker];
    [self.view addSubview:self.timeLable];
}

#pragma mark - *******懒加载*******
-(UILabel *)timeLable{
    if(_timeLable==nil){
        _timeLable=[[UILabel alloc]initWithFrame:CGRectMake(MARGIN, TEXTVIEW_HEIGHT+DATEPICKER_HEIGHT+2*MARGIN, [UIScreen mainScreen].bounds.size.width-MARGIN*2, TIMELABLE_HEIGHT)];
        _timeLable.textAlignment=NSTextAlignmentCenter;
        _timeLable.textColor=[UIColor redColor];
        _timeLable.font=[UIFont systemFontOfSize:25];
    }
    return _timeLable;
}

-(UIDatePicker *)picker{
    if(_picker==nil){
        _picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(MARGIN, TEXTVIEW_HEIGHT+MARGIN*2, [UIScreen mainScreen].bounds.size.width-MARGIN*2, DATEPICKER_HEIGHT)];
        _picker.date = [NSDate date]; // 设置初始时间
        _picker.timeZone = [NSTimeZone timeZoneWithName:@"GTM+8"]; // 设置时区，中国在东八区
        _picker.datePickerMode = UIDatePickerModeDateAndTime; // 设置样式
        [_picker addTarget:self action:@selector(chooseDate:) forControlEvents:UIControlEventValueChanged]; // 添加监听器
    }
    return _picker;
}

-(UITextView *)textView{
    if(_textView==nil){
        _textView=[[UITextView alloc]initWithFrame:CGRectMake(MARGIN, MARGIN+64,[UIScreen mainScreen].bounds.size.width-MARGIN*2, TEXTVIEW_HEIGHT)];
        _textView.font=[UIFont systemFontOfSize:16];
        _textView.delegate=self;
        _textView.scrollEnabled=YES;
        _textView.autoresizingMask=UIViewAutoresizingFlexibleHeight;
        _textView.backgroundColor=[UIColor whiteColor];
    }
    return _textView;
}

-(UIButton *)button
{
    if(_button==nil)
    {
        _button =[[UIButton alloc] initWithFrame:CGRectMake(MARGIN, TEXTVIEW_HEIGHT+DATEPICKER_HEIGHT+ MARGIN*4, [UIScreen mainScreen].bounds.size.width-MARGIN*2, BUTTON_HEIGHT)];
        _button.backgroundColor =[UIColor greenColor];
        [_button setTitle:@"通知" forState:UIControlStateNormal];
        _button.titleLabel.textColor=[UIColor whiteColor];
        _button.titleLabel.textAlignment =NSTextAlignmentCenter;
        [_button addTarget:self action:(@selector(addLocalNotification)) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _button;
}

#pragma mark - 实现chooseDate的监听方法
- (void)chooseDate:(UIDatePicker *) sender {
    
    self.selectTime =[sender date]; // 获取被选中的时间
    NSString *timeOfString=[LLZHelper LLZStringFromDate:self.selectTime Formatter:@"yyyy-MM-dd HH:mm:ss"];
    self.timeLable.text=timeOfString;
    NSLog(@"%@", [sender date]);
}
#pragma mark - 实现addLocalNotification的监听方法
-(void)addLocalNotification
{
    NSDate*currentTimeOfDate=[NSDate date];//获取当前时间
    NSString*currentTimeOfStr=[LLZHelper LLZStringFromDate:currentTimeOfDate Formatter:@"yyyy-MM-dd HH:mm:ss"];
    NSDate*currentTime=[LLZHelper LLZDateFromString:currentTimeOfStr Formatter:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeInterval time=[self.selectTime timeIntervalSinceDate:currentTime];
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:time];//通知发送的时间
    notification.timeZone = [NSTimeZone defaultTimeZone];//时区
    notification.alertBody = self.textView.text;//alertBody是设备收到本地通知时横额或锁屏时的主要文字内容
    notification.alertAction = @"现在开启神秘之旅吧！";//alertActions是锁屏时显示的slide to后面的文字内容
    notification.hasAction = YES;//是否显示额外的按钮，为no时alertAction消失
    notification.category = @"category";
    notification.applicationIconBadgeNumber+=1;//个数
    notification.soundName = UILocalNotificationDefaultSoundName;//通知声音
    notification.userInfo=[[NSDictionary alloc] initWithObjectsAndKeys:@"ww",@"ee", nil];//设置通知推送携带的参数，一般用于点击通知打开指定控制器页面
    NSString *alertString=[NSString stringWithFormat:@"%@ \n %@", [LLZHelper LLZStringFromDate:self.selectTime Formatter:@"yyyy-MM-dd HH:mm:ss"],self.textView.text];
    UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:alertString preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction*cancle=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction*sure=[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 执行通知注册
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            History *history = [[History alloc] init];
            history.Time = self.timeLable.text;
            history.State =@"未完成";
            history.Detail=self.textView.text;
        
            [[DataBase sharedDataBase] addHistory:history];
            //跳转到指定tarbar
            self.tabBarController.selectedIndex=1;
    }];
    [alert addAction:cancle];
    [alert addAction:sure];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - UITextView Delegate Methods

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self.textView resignFirstResponder];
        return NO;
    }
    return YES;
}
@end
