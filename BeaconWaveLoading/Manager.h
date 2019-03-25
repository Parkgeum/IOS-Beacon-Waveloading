//
//  Manager.h
//  MinewBeaconDemo
//
//  Created by ParkGeum on 2019. 3. 25..
//  Copyright © 2016 Yunliwuli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MinewBeaconManager.h"

@interface Manager : NSObject<MinewBeaconManagerDelegate>

+(Manager *)sharedInstance;

- (void)scan;

@end
