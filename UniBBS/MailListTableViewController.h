//
//  MailListTableViewController.h
//  UniBBS
//
//  Created by fanyingming on 10/12/14.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MailListTableViewController : UITableViewController<UIActionSheetDelegate>
@property (nonatomic, retain) NSString *userName;
@end