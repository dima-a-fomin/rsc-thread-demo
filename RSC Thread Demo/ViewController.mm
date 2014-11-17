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
    [self startGpsTest];
}

- (void)viewDidUnload
{
    [coordinatesLabel release];
    coordinatesLabel = nil;
    [altitudeLabel release];
    altitudeLabel = nil;
    [speedLabel release];
    speedLabel = nil;
    [trackLabel release];
    trackLabel = nil;
    [batterLabel release];
    batterLabel = nil;
    [gpsStatusLabel release];
    gpsStatusLabel = nil;
    [camerasLabel release];
    camerasLabel = nil;
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
    [self startGpsTest];
}


- (void) newStatusDataAvailable:(StatusData*)msg;

{
    batterLabel.text = [NSString stringWithFormat:@"%i %%", msg.batteryStatus];
    gpsStatusLabel.text = [NSString stringWithFormat:@"%i %%", msg.gpsStatus];
    camerasLabel.text = [NSString stringWithFormat:@"%@", [msg.camerasStatus componentsJoinedByString:@","]];
    
}

- (void) newGPSDataAvailable:(GPSData*)msg;

{
    coordinatesLabel.text = [NSString stringWithFormat:@"%f %f", msg.lat, msg.lon];
    altitudeLabel.text = [NSString stringWithFormat:@"%f / %f", msg.seaAltitude, msg.elipsoidAltitude];
    trackLabel.text = [NSString stringWithFormat:@"%f degree", msg.track];
    speedLabel.text = [NSString stringWithFormat:@"%f m/s", msg.groundSpeed];
}

- (void) startGpsTest
{
    NSDictionary* simulationData = @{
        @"type": @"gps",
        @"speed": @100,
        @"data": @[
            @{@"lat": @-122.56, @"lon": @55.11, @"alt": @100},
            @{@"lat": @-123.56, @"lon": @51.11, @"alt": @200}
        ]
    };
    [navigatorWrapper simulate: simulationData];

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
    NSDictionary* simulationData = @{
        @"type": @"hex",
        @"data": @[[NSData dataWithBytes:msg1 length:37]]
    };
    [navigatorWrapper simulate: simulationData];
    NSLog(@"Start test");

}



- (void)dealloc {
    [coordinatesLabel release];
    [altitudeLabel release];
    [speedLabel release];
    [trackLabel release];
    [batterLabel release];
    [gpsStatusLabel release];
    [camerasLabel release];
    [super dealloc];
}
@end
