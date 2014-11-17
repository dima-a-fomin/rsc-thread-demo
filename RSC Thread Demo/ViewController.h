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
    NavigatorWrapper* navigatorWrapper;
}
- (IBAction)clickedStart:(id)sender;

- (void) newGPSDataAvailable:(GPSData*)msg;
- (void) newStatusDataAvailable:(StatusData*)msg;

@end
