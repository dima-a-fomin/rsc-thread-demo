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
@property(nonatomic) CLLocationDistance elipsoidHeight; // meters
@property(nonatomic) CLLocationDistance seaHeight;  // meters
@property(nonatomic) CLLocationSpeed groundSpeed;  // meters per second
@property(nonatomic) CLLocationAccuracy verticalAccurency;  // meters
@property(nonatomic) CLLocationAccuracy horizontalAccurency;  // meters

- (NSString *)description; // should be used to store messages to log
    
@end

@interface StatusData : NSObject

@property(nonatomic,readonly) NSDate* date;

- (NSArray*)camerasStatus; // array with bools. length == count of installed cameras
- (int) gpsStatus; // 0-100
- (int) batteryStatus; // 0-100

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
}
@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) NSArray* testData;
@property (nonatomic, retain) RscMgr *rscMgr;

- (void) start;
- (void) simulate;

- (void) startCommThread:(id)object;
- (void) resetCounters;

@end