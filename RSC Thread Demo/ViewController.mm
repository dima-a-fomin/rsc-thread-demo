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
    [self startHexTest];
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
    [self startHexTest];
}


- (void) newStatusDataAvailable:(StatusData*)msg;

{

}

- (void) newGPSDataAvailable:(GPSData*)msg;

{
    coordinatesLabel.text = [NSString stringWithFormat:@"%f %f", msg.lat, msg.lon];
}

- (void) startGpsTest
{

}

- (void) startHexTest {
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
    [navigatorWrapper start];

    NSDictionary* simulationData = @{
        @"type": @"hex",
        @"data": @[[NSData dataWithBytes:msg1 length:37]]
    };
    [navigatorWrapper simulate: simulationData];
    NSLog(@"Start test");

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
