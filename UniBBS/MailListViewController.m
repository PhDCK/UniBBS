//
//  MailListViewController.m
//  UniBBS
//
//  Created by fanyingming on 10/12/14.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import "MailListViewController.h"
#import "WritingMailViewController.h"
#import "UIRefreshControl+AFNetworking.h"
#import "UIAlertView+AFNetworking.h"
#import "MailModel.h"
#import "MailViewController.h"
#import "BDWMUserModel.h"
#import "BDWMAlertMessage.h"

@interface MailListViewController ()

@property (strong, nonatomic) NSArray *mails;
@property (readwrite, nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation MailListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"站内信";
    }
    return self;
}

- (void)reload:(__unused id)sender {
   
    if ([BDWMUserModel isLogined] == NO) {
        [BDWMAlertMessage alertMessage:@"啊！出错了！没有登陆居然也能到这里！"];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    //already logined.
    self.userName = [BDWMUserModel getLoginUser];
    if (self.userName == nil) {
        [BDWMAlertMessage alertMessage:@"啊！出错了！用户名怎么丢了！"];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    NSString *userName = self.userName;
    NSURLSessionTask *task = [MailModel getAllMailWithBlock:userName blockFunction:^(NSArray *mails, NSError *error) {
        if (!error) {
            self.mails = mails;
            if (self.mails == nil || self.mails.count == 0) {
                //login session failed. then relogin.
                NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
                NSString *userName1 = [userDefaultes stringForKey:@"saved_username"];
                NSString *password = [userDefaultes stringForKey:@"saved_password"];
                
                [BDWMUserModel checkLogin:userName1 userPass:password blockFunction:^(NSString *name, NSError *error){
                    if ( !error && name != nil ) {
                        //login success reload mail.
                        [MailModel getAllMailWithBlock:name blockFunction:^(NSArray *mails, NSError *error){
                            if (!error){
                                self.mails = mails;
                                //login success but no mail.
                                if (self.mails == nil || self.mails.count == 0) {
                                    //
                                    [BDWMAlertMessage alertAndAutoDismissMessage:@"没有信件哦！"];
                                }else{
                                    [self.tableView reloadData];
                                }
                                
                            }else{
                                [BDWMAlertMessage alertMessage:@"获取不到数据."];
                                [self.navigationController popViewControllerAnimated:YES];
                            }
                        }];
                    }else{
                        [BDWMAlertMessage alertMessage:@"获取不到数据."];
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }];
            }else{
                //find mails.
                [self.tableView reloadData];
            }
            
        }else{
            [BDWMAlertMessage alertMessage:@"获取不到数据."];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    
//    [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
    [self.refreshControl setRefreshingWithStateOfTask:task];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"写信" style:UIBarButtonItemStyleBordered target:self action:@selector(segueToComposeMail)];
    self.navigationItem.rightBarButtonItem = button;
    [button release];
    
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 100.0f)];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    [self.tableView.tableHeaderView addSubview:self.refreshControl];
    
    [self reload:nil];
}

- (void)segueToComposeMail
{
    WritingMailViewController *composeMailViewController = [[[WritingMailViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    
    [self.navigationController pushViewController:composeMailViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    return self.mails.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MailCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell...
    NSDictionary *mail = [self.mails objectAtIndex:indexPath.row];
    cell.textLabel.text = [mail objectForKey:@"title"];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    
    NSString *detail = [NSString stringWithFormat:@"%@    -   %@",[mail valueForKey:@"date"], [mail valueForKey:@"author"]];
    cell.detailTextLabel.text = detail;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *mail = [self.mails objectAtIndex:[indexPath row]];
    MailViewController * mailViewController = [[MailViewController alloc] initWithNibName:@"MailViewController" bundle:nil];
    
    mailViewController.href = [mail objectForKey:@"href"];
    NSLog(@"mail reply href:%@",mailViewController.href);
    [self.navigationController pushViewController:mailViewController animated:YES];
    [mailViewController release];
}

@end
