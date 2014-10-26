//
//  ViewController.m
//  RSC Thread Demo
//
//  Created by Jeremy Bramson on 8/20/12.
//  Copyright © 2012 Redpark  All Rights Reserved
//

#import "ViewController.h"
// #include "/usr/include/libkern/OSAtomic.h"
#import <libkern/OSAtomic.h>

// NOTE - you must install the XCode "Command Line Tools" from preferences to have access to the OSAtomic header.

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    navigatorWrapper = [[NavigatorWrapper alloc] init];
    
    [navigatorWrapper setDelegate:self];
    [self startTest];
}

- (void)viewDidUnload
{
    [cableStateLabel release];
    cableStateLabel = nil;
    [txLabel release];
    txLabel = nil;
    [rxLabel release];
    rxLabel = nil;
    [errLabel release];
    errLabel = nil;
    [startButton release];
    startButton = nil;
    [baudRateLabel release];
    baudRateLabel = nil;
    [coordinatesLabel release];
    coordinatesLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


- (IBAction)clickedStart:(id)sender
{
    if (testRunning == NO)
    {
        [startButton setTitle:STOP_STR forState:UIControlStateNormal];
        [self startTest];
    }
    else
    {
        [startButton setTitle:START_STR forState:UIControlStateNormal];
        [self stopTest];
    }
}

- (void) resetCounters
{
    txCount = rxCount = errCount = 0;
    seqNum = 0;
    testRunning = FALSE;
}

- (void) newStatusDataAvailable:(StatusData*)msg;

{
    [self updateStatus:nil];
}

- (void) newGPSDataAvailable:(GPSData*)msg;

{
        coordinatesLabel.text = [NSString stringWithFormat:@"%f %f", msg.lat, msg.lon];
}

- (void) updateStatus:(id)object
{
    cableStateLabel.text = (cableConnected == YES) ? CONNECTED_STR : NOT_CONNECTED_STR;
    
    rxLabel.text = [NSString stringWithFormat:@"%d", rxCount];
    txLabel.text = [NSString stringWithFormat:@"%d", txCount];
    errLabel.text = [NSString stringWithFormat:@"%d", errCount];
    
    if (cableConnected)
    {
//        NSString *str = [NSString stringWithFormat:@"%d",
//                         [rscMgr getBaud]];
        
        baudRateLabel.text = @"yes"; //str;
    }
    else
    {
        baudRateLabel.text = @"?";
    }

}

- (void) startTest
{
    testRunning = YES;
    seqNum = 0;
//    navigatorWrapper.testData = @[@{@"lat": @100, @"lon": @200}, @{@"lat": @102, @"lon": @202}];
    //NSMutableData* msg1 = [[NSMutableData alloc] init];
    UInt8 msg1[] = {
        0xb5,
        0x62,
        0x01,
        0x00,
        0x1c,
        0x00,
        // start gps data
        0x01, 0x00, 0x00, 0x00,
        0x01, 0x00, 0x00, 0x00,
        0x01, 0x00, 0x00, 0x00,
        0x01, 0x00, 0x00, 0x00,
        0x01, 0x00, 0x00, 0x00,
        0x01, 0x00, 0x00, 0x00,
        0x01, 0x00, 0x00, 0x00,
        0x24, 0xDB, // check sum
        0xFF, 0xFF, 0xFF, 0xFF, //garbage
    };
    navigatorWrapper.testData = @[[NSData dataWithBytes:msg1 length:37]];
    [navigatorWrapper start];
    [navigatorWrapper simulate];
    NSLog(@"Start test");

//    [rscMgr write:testData length:TEST_DATA_LEN];
//    
//    OSAtomicAdd32(TEST_DATA_LEN, &txCount);
//    
//    [self performSelectorOnMainThread:@selector(updateStatus:) withObject:nil waitUntilDone:NO];

}

- (void) stopTest
{
    testRunning = NO;
}


- (void)dealloc {
    [cableStateLabel release];
    [txLabel release];
    [rxLabel release];
    [errLabel release];
    [startButton release];
    [baudRateLabel release];
    [coordinatesLabel release];
    [super dealloc];
}
@end
