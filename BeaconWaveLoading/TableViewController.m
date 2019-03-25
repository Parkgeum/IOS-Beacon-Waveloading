//
//  TableViewController.m
//  YlwlBeaconDemo
//
//  Created by ParkGeum on 2019. 3. 25..
//  Copyright © 2016年 com.YLWL. All rights reserved.
//

#import "BeaconWaveLoading-Bridging-Header.h"

#import "TableViewController.h"
#import "MinewBeaconManager.h"
#import "MinewBeacon.h"
#import "Manager.h"

#define uuid1 @"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"
#define uuid2 @"AB8190D5-D11E-4941-ACC4-42F30510B408"
#define uuid3 @"00000000-0000-0000-0000-000000000000"

@interface TableViewController () <MinewBeaconManagerDelegate>
@end


@implementation TableViewController
{
    NSArray *_scannedDevice;
    MinewBeaconManager *_dm;
    MinewBeacon *_SelectDevice;
}

- (void)viewDidLoad
{
//     Manager *m = [Manager sharedInstance];
//    
//     [m scan];
    
    
    //logo
    UIView *logo = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 50)];
    UIImageView *image = [[UIImageView alloc]initWithImage:[UIImage     imageNamed:@"SmartLogo.png"]];
    [image setFrame:CGRectMake(10, 8, 165, 34)];
    [logo addSubview:image];
    [self.navigationController.navigationBar addSubview:logo];
     
    //background image
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
    [tempImageView setFrame:self.tableView.frame];
    self.tableView.backgroundView = tempImageView;
    
    //사용하는 table cell만 보이게
    UIView *footherView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 10)];
    self.tableView.tableFooterView = footherView;
    
    self.tableView.scrollEnabled = false;
    
    [self.navigationController.navigationBar setTranslucent:YES];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
}


- (void)viewDidAppear:(BOOL)animated
{
   
    [super viewDidAppear:animated];
    
    _dm = [MinewBeaconManager sharedInstance];
    _dm.delegate = self;
    [_dm startScan:@[ uuid1, uuid2, uuid3] backgroundSupport:NO];

    
    BluetoothState bs = [_dm checkBluetoothState];
    
    if ( bs == BluetoothStatePowerOn)
    {
        NSLog(@"The bluetooth state is power on, start scan now.");
        [_dm startScan:@[ uuid1, uuid2, uuid3] backgroundSupport:NO];
    }
    else
        NSLog(@"The bluetooth state isn't power on, we can't start scan.");

}

-(void)viewWillAppear:(BOOL)animated
{
    
}

- (IBAction)startScan:(id)sender
{
    _dm.delegate = self;
    
    // open backgroundSupport will reduce the battery life.
    [_dm startScan:@[uuid3] backgroundSupport:NO];
}

- (IBAction)stopScan:(id)sender
{
    [[MinewBeaconManager sharedInstance] stopScan];
    _scannedDevice = nil;
    //[self.tableView reloadData];
}


#pragma mark *****************************TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _scannedDevice.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifer = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifer];
    }
    
    //cell config
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
    cell.textLabel.textColor = UIColor.darkGrayColor;
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:25.0];
    cell.detailTextLabel.textColor = UIColor.darkGrayColor;
    
    MinewBeacon *device = _scannedDevice[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"스마트온습도센서    Mac:%@\n",[device getBeaconValue:BeaconValueIndex_Mac].stringValue];
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"온도:%.2f°C, 습도:%.2f%%",[device getBeaconValue:BeaconValueIndex_Temperature].floatValue, [device getBeaconValue:BeaconValueIndex_Humidity].floatValue];
    
    
    if (_SelectDevice==NULL) {
        self.SensorTextView.text = [NSString stringWithFormat:@"센서ID:%@",[device getBeaconValue:BeaconValueIndex_Mac].stringValue];
        self.TempTextView.text = [NSString stringWithFormat:@"온도:%.2f°C",[device getBeaconValue:BeaconValueIndex_Temperature].floatValue];
        self.HumTextView.text = [NSString stringWithFormat:@"습도:%.2f%%",[device getBeaconValue:BeaconValueIndex_Humidity].floatValue];
    }
    else {
        self.SensorTextView.text = [NSString stringWithFormat:@"센서ID:%@",[_SelectDevice getBeaconValue:BeaconValueIndex_Mac].stringValue];
        self.TempTextView.text = [NSString stringWithFormat:@"온도:%.2f°C",[_SelectDevice getBeaconValue:BeaconValueIndex_Temperature].floatValue];
        self.HumTextView.text = [NSString stringWithFormat:@"습도:%.2f%%",[_SelectDevice getBeaconValue:BeaconValueIndex_Humidity].floatValue];
    }
    
    return cell;
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _SelectDevice = _scannedDevice[indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.f;
}

#pragma mark **********************************Device Manager Delegate
- (void)minewBeaconManager:(MinewBeaconManager *)manager didRangeBeacons:(NSArray<MinewBeacon *> *)beacons
{
    
    @synchronized (self)
    {
        _scannedDevice = [beacons copy];
        
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
        {
            [self pushNotification:[NSString stringWithFormat:@"Devices:%lu",(unsigned long)_scannedDevice.count]];
        }
        else
        {
            dispatch_async( dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }
}

- (void)minewBeaconManager:(MinewBeaconManager *)manager appearBeacons:(NSArray<MinewBeacon *> *)beacons
{
    NSLog(@"===appear beacons:%@", beacons);
}

- (void)minewBeaconManager:(MinewBeaconManager *)manager disappearBeacons:(NSArray<MinewBeacon *> *)beacons
{
    NSLog(@"---disappear beacons:%@", beacons);
}


- (void)minewBeaconManager:(MinewBeaconManager *)manager didUpdateState:(BluetoothState)state
{
    NSLog(@"++++Bluetooth state:%ld", (long)state);
    
    if ( state != BluetoothStatePowerOn)
        [self showAlert:state == BluetoothStatePowerOff? 1: 0];
}


- (void)pushNotification:(NSString *)notString
{
    
    UILocalNotification *unf = [[UILocalNotification alloc]init];
    unf.alertBody = notString;
    [[UIApplication sharedApplication] presentLocalNotificationNow:unf];
}

- (void)showAlert:(NSInteger)type
{

    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Error" message:type? @"Bluetooth is power off": @"Bluetooth status Error！" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    
    [ac addAction:aa];
    [self presentViewController:ac animated:YES completion:nil];

}


@end
