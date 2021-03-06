#import "navigatorWrapper.h"
// #include "/usr/include/libkern/OSAtomic.h"
#import <libkern/OSAtomic.h>

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)

@implementation GPSData
@synthesize date, lat, lon, track, elipsoidAltitude, seaAltitude, groundSpeed, verticalAccurency, horizontalAccurency;

- (NSString *) description {
    return [NSString stringWithFormat:@"%f %f", [self lat], [self lon]];
}

- (void) dealloc {
    date = nil;
    [super dealloc];
}

@end

@implementation StatusData

@synthesize gpsStatus, batteryStatus, camerasStatus, date;

- (NSString *) description {
    return [NSString stringWithFormat:@"%i %i", gpsStatus, batteryStatus];
}

- (void) dealloc {
    date = nil;
    camerasStatus = nil;
    [super dealloc];
}

@end


@interface NavigatorWrapper ()

@end

enum {
 	msgGPS = 1,
	msgStatus = 2,
};

@implementation NavigatorWrapper

@synthesize delegate;

- (void)start
{

    // Create and start the comm thread.  We'll use this thread to manage the rscMgr so
    // we don't tie up the UI thread.
    if (commThread == nil)
    {
        commThread = [[NSThread alloc] initWithTarget:self
                                             selector:@selector(startCommThread:)
                                               object:nil];
        [commThread start];  // Actually create the thread
    }
 
}

- (void) startCommThread:(id)object
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    readBuffer = [[NSMutableData alloc] init];
    
    // initialize RscMgr on this thread
    // so it schedules delegate callbacks for this thread
    rscMgr = [[RscMgr alloc] init];
    
    [rscMgr setDelegate:self];
    
    // run the run loop
    [[NSRunLoop currentRunLoop] run];
    
    [pool release];
}

- (void) simulate: (NSDictionary*) simulationData
{
    [self start];
    [self performSelector:@selector(startSimulationTimer:) onThread:commThread withObject:simulationData waitUntilDone:NO];
}

- (void) initTestData: (NSDictionary*) simulationData
{
    NSMutableArray* trackData = [[NSMutableArray alloc] init];
    CLLocationSpeed speed = [simulationData[@"speed"] doubleValue];
    if (!speed) speed = 100;
    NSArray* data = (NSArray*) simulationData[@"data"];
    for (int i=1;i<[data count];i++) {
        NSDictionary* data1 = (NSDictionary*)data[i-1];
        NSDictionary* data2 = (NSDictionary*)data[i];
        CLLocationDistance alt1 = [data1[@"alt"] doubleValue];
        CLLocationDistance alt2 = [data2[@"alt"] doubleValue];
        CLLocationDegrees lat1 = [data1[@"lat"] doubleValue];
        CLLocationDegrees lat2 = [data2[@"lat"] doubleValue];
        CLLocationDegrees lon1 = [data1[@"lon"] doubleValue];
        CLLocationDegrees lon2 = [data2[@"lon"] doubleValue];
        CLLocation* point1 = [[CLLocation alloc] initWithLatitude:lat1 longitude:lon1];
        CLLocation* point2 = [[CLLocation alloc] initWithLatitude:lat2 longitude:lon2];
        CLLocationDistance distance = [point1 distanceFromLocation: point2];
        int steps = distance / speed * 2;
        for (int k=0; k<steps+1; k++) {
            GPSData* data = [[GPSData alloc] init];
            data.lat = lat1 + (lat2-lat1) * k / steps;
            data.lon = lon1 + (lon2-lon1) * k / steps;
            data.elipsoidAltitude = alt1 + (alt2-alt1) * k / steps;
            data.seaAltitude = data.elipsoidAltitude * 1.01;
            data.groundSpeed = speed;
            data.track = [self getHeadingForDirectionFromCoordinate: point1.coordinate toCoordinate:point2.coordinate];
            data.verticalAccurency = 1;
            data.horizontalAccurency = 1;
            [trackData addObject:data];
        }
        
    }
    
    testData = [[NSArray alloc] initWithArray:trackData];
    NSLog(@"init test data by gps with %i points", [testData count]);
}

- (float)getHeadingForDirectionFromCoordinate:(CLLocationCoordinate2D)fromLoc toCoordinate:(CLLocationCoordinate2D)toLoc
{
    float fLat = degreesToRadians(fromLoc.latitude);
    float fLng = degreesToRadians(fromLoc.longitude);
    float tLat = degreesToRadians(toLoc.latitude);
    float tLng = degreesToRadians(toLoc.longitude);
    
    float degree = radiandsToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
    
    if (degree >= 0) {
        return degree;
    } else {
        return 360+degree;
    }
}

- (void) startSimulationTimer: (NSDictionary*) simulationData
{
    if ([simulationData[@"type"] isEqualToString: @"hex"]) {
        testData = [(NSArray*)simulationData[@"data"] copy];
//        NSLog(@"init test data with hex data %@", testData);
    } else if ([simulationData[@"type"] isEqualToString: @"gps"]) {
        [self initTestData:simulationData];
    } else {
        [NSException raise:@"Invalid simulation type" format:@"type of %@ is invalid", simulationData[@"type"]];
    }
    testDataIndex = 0;
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                              target:self selector:@selector(handleTimer:)
                              userInfo:nil repeats:YES];
    simulationTimer = timer;
}

- (void)handleTimer:(NSTimer*)timer
{
    if (testDataIndex >= [testData count]) {
        [simulationTimer invalidate];
        NSLog(@"We complete test data");
        return;
    }
    id testObj = testData[testDataIndex++];
    //NSLog(@"test item %d %@", testDataIndex, testObj);
    if ([testObj isKindOfClass:[GPSData class]]) {
        GPSData *data = (GPSData*) testObj;
        [self performSelectorOnMainThread:@selector(fireGPSData:) withObject:data waitUntilDone:NO];
    }
    if ([testObj isKindOfClass:[NSData class]]) {
        [readBuffer appendData:((NSData *)testObj)];
        [self parseReadBuffer];
    }
    StatusData* statusData = [[StatusData alloc] init];
    statusData.gpsStatus = 80;
    statusData.batteryStatus = 83;
    statusData.camerasStatus = @[@YES, @YES, @NO, @NO, @NO, @NO];
    [self performSelectorOnMainThread:@selector(fireStatusData:) withObject:statusData waitUntilDone:NO];
}

- (void) fireGPSData:(GPSData*) data
{
    //NSLog(@"Fire GPS data available message %@", data);
    [[self delegate] newGPSDataAvailable:data];
}

- (void) fireStatusData:(StatusData*) data
{
    //NSLog(@"Fire GPS data available message %@", data);
    [[self delegate] newStatusDataAvailable:data];
}

- (void) resetCounters
{
    txCount = rxCount = errCount = 0;
    seqNum = 0;
    testRunning = FALSE;
}

- (void) parseReadBuffer
{
    // parse readBuffer and try to fin messages in it
    NSLog(@"start parsing %@", readBuffer);
    int index;
    UInt16 payloadLen;
    UInt16 messageLen;
    UInt16 lastByteInMessage;
    UInt16 checkSum;
    UInt8* bytes = (UInt8*)[readBuffer bytes];
    int msgType;
    int totalBytes = [readBuffer length];
    for (index=0; index < totalBytes-4; index++) {
        msgType = [self checkMessageType:bytes[index] byte2:bytes[index+1]];
        if (msgType != 0) {
            [readBuffer getBytes:&payloadLen range:NSMakeRange(index+4, 2)];
            payloadLen = CFSwapInt16LittleToHost(payloadLen);
            messageLen = payloadLen + 4;
            lastByteInMessage = index + messageLen + 2;
            NSLog(@"payload %d", payloadLen);
            if (totalBytes < lastByteInMessage) {
                continue;
            }
            [readBuffer getBytes:&checkSum range:NSMakeRange(lastByteInMessage, 2)];
            checkSum = CFSwapInt16LittleToHost(checkSum);
            NSData* message = [readBuffer subdataWithRange: NSMakeRange(index+2, messageLen)];
            NSLog(@"Process message %@", message);
            if ([self checkCheckSum:message checkSum:checkSum] == NO) {
                NSLog(@"Wrong check sum");
                continue;
            }
            [readBuffer replaceBytesInRange:NSMakeRange(0, lastByteInMessage+2) withBytes:nil length:0];
            if (msgType == msgGPS) {
                [self parseGPSMessage:message];
            }
        }
    }
}

- (void) parseGPSMessage: (NSData*) message
{
    GPSData *data = [[GPSData alloc] init];
    data.lat = 99;
    data.lon = 999;
    [self performSelectorOnMainThread:@selector(fireGPSData:) withObject:data waitUntilDone:NO];
    
}

- (int) checkMessageType: (UInt8) byte1 byte2: (UInt8) byte2
{
    if ((byte1 == 0xb5) && (byte2 == 0x62)) {
        return msgGPS;
    }
    if ((byte1 == 0xec) && (byte2 == 0x41)) {
        return msgGPS;
    }
    return 0;
}

- (BOOL) checkCheckSum:(NSData*) message checkSum:(UInt16) checkSum
{
    UInt16 sum1 = 0;
    UInt16 sum2 = 0;
    int index;
    UInt8* bytes = (UInt8*)[message bytes];
    
    for( index = 0; index < [message length]; ++index )
    {
        sum1 = (sum1 + bytes[index]) % 255;
        sum2 = (sum2 + sum1) % 255;
    }
    
    UInt16 correctSum = (sum2 << 8) | sum1;
    NSLog(@"correct check sum %d given %d", correctSum, checkSum);
    return correctSum == checkSum;
}


// Redpark Serial Cable has been connected and/or application moved to foreground.
// protocol is the string which matched from the protocol list passed to initWithProtocol:
- (void) cableConnected:(NSString *)protocol
{
    cableConnected = YES;
    if ([rscMgr supportsExtendedBaudRates] == YES)
    {
        [rscMgr setBaud:115200];
    }
    else
    {
        [rscMgr setBaud:38400];
    }
    
    serialPortConfig portCfg;
	[rscMgr getPortConfig:&portCfg];
    portCfg.txAckSetting = 1;
    [rscMgr setPortConfig:&portCfg requestStatus: NO];
    
    //[self performSelectorOnMainThread:@selector(updateStatus:) withObject:nil waitUntilDone:NO];
    
}

// Redpark Serial Cable was disconnected and/or application moved to background
- (void) cableDisconnected
{
    cableConnected = NO;
    //[self stopTest];
    [self resetCounters];
    //[self performSelectorOnMainThread:@selector(updateStatus:) withObject:nil waitUntilDone:NO];
}

// serial port status has changed
// user can call getModemStatus or getPortStatus to get current state
- (void) portStatusChanged;
{
    static serialPortStatus portStat;
    
    [rscMgr getPortStatus:&portStat];
    
    if(testRunning == YES && portStat.txAck)
    {
        // tx fifo has been drained in cable so
        // write some more
//        [rscMgr write:testData length:TEST_DATA_LEN];
        
//        [self performSelectorOnMainThread:@selector(updateStatus:) withObject:nil waitUntilDone:NO];
    }
    
}

// bytes are available to be read (user calls read:)
- (void) readBytesAvailable:(UInt32)numBytes
{
    int bytesRead;
    bytesRead = [rscMgr read:rxBuffer length:numBytes];
    rxCount += bytesRead;
    [readBuffer appendBytes:rxBuffer length:bytesRead];
    [self parseReadBuffer];
    
    //[self performSelectorOnMainThread:@selector(updateStatus:) withObject:nil waitUntilDone:NO];
    
}


- (void)dealloc {
//    [baudRateLabel release];
    [super dealloc];
}
@end
