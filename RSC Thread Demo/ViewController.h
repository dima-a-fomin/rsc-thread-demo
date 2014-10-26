//
//  ViewController.h
//  RSC Thread Demo
//
//  Created by Jeremy Bramson on 8/20/12.
//  Copyright © 2012 Redpark  All Rights Reserved
//

#import <UIKit/UIKit.h>
#import "RscMgr.h"
#import "navigatorWrapper.h"

#define START_STR @"Start"
#define STOP_STR  @"Stop"
#define CONNECTED_STR @"Connected"
#define NOT_CONNECTED_STR @"Not Connected"

@interface ViewController : UIViewController <NavigatorWrapperDelegate>
{
    IBOutlet UILabel *cableStateLabel;
    IBOutlet UILabel *baudRateLabel;
    IBOutlet UILabel *txLabel;
    IBOutlet UILabel *rxLabel;
    IBOutlet UILabel *errLabel;
    IBOutlet UIButton *startButton;
    IBOutlet UILabel *coordinatesLabel;
    BOOL cableConnected;
    int rxCount;
    int txCount;
    int errCount;
    UInt8 seqNum;
    BOOL testRunning;
    NavigatorWrapper* navigatorWrapper;
}
- (IBAction)clickedStart:(id)sender;

- (void) newGPSDataAvailable:(GPSData*)msg;
- (void) newStatusDataAvailable:(StatusData*)msg;
- (void) updateStatus:(id)object;
- (void) resetCounters;
- (void) startTest;
- (void) stopTest;

@end
