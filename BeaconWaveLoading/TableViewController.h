//
//  TableViewController.h
//  YlwlBeaconDemo
//
//  Created by ParkGeum on 2019. 3. 25..
//  Copyright © 2016年 com.YLWL. All rights reserved.
//

#import <UIKit/UIKit.h>


@class DisplayViewController;
@protocol configure;

@interface TableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UITextField *SensorTextView;
@property (weak, nonatomic) IBOutlet UITextField *TempTextView;
@property (weak, nonatomic) IBOutlet UITextField *HumTextView;

@end
