//
//  ViewController.m
//  test
//
//  Created by kaifeng on 16/1/25.
//  Copyright © 2016年 kaifeng. All rights reserved.
//

#import "ViewController.h"
//#import "UIViewController+keyboard.h"
#import "Header.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"
#import "myTableViewCell.h"
#import "itTableViewCell.h"

#define kScreenSize [UIScreen mainScreen].bounds.size

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *messageImage;
@property (weak, nonatomic) IBOutlet UIButton *sentMessageBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *messageArr;
@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet UITextField *textfield;
@property (nonatomic, strong) NSString *myMessage;
@property (nonatomic, strong) NSString *itMessage;
@property (nonatomic) NSInteger sumOfMessage;
@property (nonatomic) BOOL isDone;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBar.translucent = NO;
    _sentMessageBtn.layer.cornerRadius = 5;
    _sentMessageBtn.layer.masksToBounds = YES;
    _messageImage.contentMode = UIViewContentModeScaleToFill;
    _textfield.delegate = self;
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    self.isDone = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboard)];
    [self.view addGestureRecognizer:tapGesture];
    tapGesture.numberOfTapsRequired = 1;
    
    _messageArr = [[NSMutableArray alloc] initWithArray:@[@"你好，欢迎回来！你想聊些什么？"]];
    NSLog(@"%@",_messageArr[0]);
    _sumOfMessage = _messageArr.count;
    [_tableView reloadData];
    
}


- (IBAction)sendMessage:(UIButton *)sender {
    _sentMessageBtn.enabled = NO;
    if (!self.isDone) {
        return;
    }
        
    if ([_textfield.text isEqualToString:@""]) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"不能发送空信息" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sancelAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        [alert addAction:sancelAction];
        
        [self presentViewController:alert animated:YES completion:^{
        }];
        return;
    }
    
    [_messageArr addObject:_textfield.text];
    NSLog(@"%@",_textfield.text);
    _sumOfMessage += 1;
     [_tableView reloadData];
    self.isDone = NO;
    [self getAnswerWithMessage:_textfield.text];
    _textfield.text = nil;
    
    NSUInteger rowCount = _messageArr.count;
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:rowCount-1 inSection:0];
    
    [_tableView scrollToRowAtIndexPath:indexPath
     
                      atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
    NSIndexPath* firstindexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    if (_messageArr.count <= 12) {
        [_tableView scrollToRowAtIndexPath:firstindexPath
         
                          atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
 
}

- (void)getAnswerWithMessage:(NSString *)message{
    //请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"key"] = kRobotKey;
    params[@"info"] = message;
    params[@"dtype"] = @"json";
    
    NSString *urlStr = kRobotUrl;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:urlStr parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *temp = (NSDictionary *)responseObject;
        _itMessage = [NSString stringWithFormat:@"%@",temp[@"result"][@"text"]];
        _sumOfMessage += 1;
        [_messageArr addObject:_itMessage];
        [_tableView reloadData];
        NSLog(@"%@",_itMessage);
        
        NSUInteger rowCount = _messageArr.count;
        
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:rowCount-1 inSection:0];
        
        [_tableView scrollToRowAtIndexPath:indexPath
         
                          atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        
        
        NSIndexPath* firstindexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        if (_messageArr.count <= 12) {
            [_tableView scrollToRowAtIndexPath:firstindexPath
             
                              atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
        self.isDone = YES;
        _sentMessageBtn.enabled = YES;
        
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        NSLog(@"errror:%@",error);
        [_messageArr addObject:@"哎呀，断网了，我找不到你了……"];
        [_tableView reloadData];

        return ;
    }];

}

- (void)resignKeyboard
{
    [_textfield resignFirstResponder];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardHandle:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardHandle:) name:UIKeyboardWillHideNotification object:nil];

}

-(void)keyBoardHandle:(NSNotification *)notification{
    CGFloat deltayY;
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect beginFrame = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    deltayY = beginFrame.origin.y - endFrame.origin.y;
    
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    
    
    if (_messageArr.count > 12) {
        
        CGRect viewFrame = self.view.frame;
        CGFloat viewMoveY = deltayY;
        viewFrame.origin.y -= viewMoveY;
        
        [UIView animateWithDuration:duration animations:^{
            self.view.frame = viewFrame;
        }];
        
    }else{
//        CGRect viewFrame = _messageView.frame;
//        CGFloat viewMoveY = deltayY;
//        viewFrame.origin.y += viewMoveY;
//        
//        [UIView animateWithDuration:duration animations:^{
//            _messageView.frame = viewFrame;
//        }];
        
        
        CGRect viewFrame = self.view.frame;
        CGRect tableViewFrame = _tableView.frame;
        CGFloat viewMoveY = deltayY;
        viewFrame.origin.y -= viewMoveY;
        tableViewFrame.origin.y += viewMoveY * 2;
        tableViewFrame.size.height -= viewMoveY * 2;
        
        [UIView animateWithDuration:duration animations:^{
            self.view.frame = viewFrame;
            _tableView.frame = tableViewFrame;
        }];
    }
    
}



- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - table view dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _messageArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *cellIdentifier = @"MTCell";
    
    if ((indexPath.row % 2) != 0) {
        
        myTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"myTableViewCell" owner:self options:nil] lastObject];
        }
        cell.label.text = [NSString stringWithFormat:@"  %@\t", _messageArr[indexPath.row]];
        cell.label.font = [UIFont systemFontOfSize:15];
        cell.label.textColor = [UIColor brownColor];
        cell.label.layer.cornerRadius = 7;
        cell.label.layer.masksToBounds = YES;
        cell.label.layer.borderColor = [[UIColor colorWithRed:0/255.0 green:164/255.0 blue:228/255.0 alpha:.5f]CGColor];
        cell.label.layer.borderWidth = 1;
        cell.label.numberOfLines = 0;

        return cell;

    }else{
        
        static NSString *CellIdentifier = @"Cell";
        itTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"itTableViewCell" owner:self options:nil] lastObject];
        }
        cell.label.font = [UIFont systemFontOfSize:15];
        cell.label.text = [NSString stringWithFormat:@"  %@  ", _messageArr[indexPath.row]];
        cell.label.textColor = [UIColor orangeColor];
        cell.label.layer.cornerRadius = 7;
        cell.label.layer.masksToBounds = YES;
        cell.label.layer.borderColor = [[UIColor orangeColor]CGColor];
        cell.label.layer.borderWidth = 1;
        cell.label.numberOfLines = 0;
        return cell;
        
    }

    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    
    if ((indexPath.row % 2) != 0) {
        
        myTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"myTableViewCell" owner:self options:nil] lastObject];
        }
        cell.label.text = [NSString stringWithFormat:@"  %@\t", _messageArr[indexPath.row]];
        cell.label.font = [UIFont systemFontOfSize:15];
        cell.label.numberOfLines = 0;
        
        return [cell.label.text boundingRectWithSize:CGSizeMake(kScreenSize.width - 32 - 84,100) options:NSStringDrawingUsesLineFragmentOrigin  attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15],NSFontAttributeName,nil] context:nil].size.height + 16;
        
    }
    
    itTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"itTableViewCell" owner:self options:nil] lastObject];
    }
    cell.label.font = [UIFont systemFontOfSize:15];
    cell.label.text = [NSString stringWithFormat:@"  %@  ", _messageArr[indexPath.row]];
    return [cell.label.text boundingRectWithSize:CGSizeMake(kScreenSize.width - 32 - 84,100) options:NSStringDrawingUsesLineFragmentOrigin  attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15],NSFontAttributeName,nil] context:nil].size.height + 16;;
    
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
 
}


@end
