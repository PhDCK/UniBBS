//
//  MailViewController.m
//  UniBBS
//
//  Created by fanyingming on 10/12/14.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import "MailViewController.h"
#import "MailModel.h"
@interface MailViewController ()
@property (retain, nonatomic) IBOutlet UITextView *mailContentTextView;
@property (retain, nonatomic) NSDictionary *mail;
@end

@implementation MailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.mail = [MailModel loadMailByhref:self.href];
    self.mailContentTextView.text = [self.mail objectForKey:@"content"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_mailContentTextView release];
    [super dealloc];
}
@end
