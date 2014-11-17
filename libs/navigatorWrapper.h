//
//  ViewController.h
//  RSC Thread Demo
//
//  Created by Jeremy Bramson on 8/20/12.
//  Copyright © 2012 Redpark  All Rights Reserved
//

#import <UIKit/UIKit.h>
#import "RscMgr.h"
#import <CoreLocation/CLLocation.h>

#define START_STR @"Start"
#define STOP_STR  @"Stop"
#define CONNECTED_STR @"Connected"
#define NOT_CONNECTED_STR @"Not Connected"

@interface GPSData : NSObject

@property(nonatomic,retain) NSDate* date;
@property(nonatomic) CLLocationDegrees lat;
@property(nonatomic) CLLocationDegrees lon;
@property(nonatomic) CLLocationDirection track; // true heading
@property(nonatomic) CLLocationDistance elipsoidAltitude; // meters
@property(nonatomic) CLLocationDistance seaAltitude;  // meters
@property(nonatomic) CLLocationSpeed groundSpeed;  // meters per second
@property(nonatomic) CLLocationAccuracy verticalAccurency;  // meters
@property(nonatomic) CLLocationAccuracy horizontalAccurency;  // meters

- (NSString *)description; // should be used to store messages to log
    
@end

@interface StatusData : NSObject

@property(nonatomic,readonly) NSDate* date;
@property(nonatomic,retain) NSArray* camerasStatus; // array with bools. length == count of installed cameras
@property(nonatomic) int gpsStatus; // 0-100
@property(nonatomic) int batteryStatus; // 0-100

- (NSString *)description; // should be used to store messages to log

@end

@protocol NavigatorWrapperDelegate <NSObject>
@required
- (void) newGPSDataAvailable:(GPSData*)msg;
- (void) newStatusDataAvailable:(StatusData*)msg;
@end


@interface NavigatorWrapper : NSObject <RscMgrDelegate>
{
    NSThread *commThread;
    RscMgr *rscMgr;
    id <NavigatorWrapperDelegate> delegate;
    NSMutableData* readBuffer;
    
    BOOL cableConnected;
    int rxCount;
    int txCount;
    int errCount;
    UInt8 seqNum;
    int testDataIndex;
    UInt8 rxBuffer[1024];
    BOOL testRunning;
    NSTimer* simulationTimer;
    NSArray* testData;
}
@property (nonatomic, retain) id delegate;

- (void) start;
- (void) simulate: (NSDictionary*) simulationData;


@end