//
//  STBLETool.h
//  STBLETool
//
//  Created by TangJR on 3/16/16.
//  Copyright © 2016 tangjr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@class STCentralTool;

static NSString * const STCentralErrorConnectTimeOut = @"time out";
static NSString * const STCentralErrorConnectOthers = @"other error";
static NSString * const STCentralErrorConnectPowerOff = @"power off";
static NSString * const STCentralErrorConnectAutoConnectFail = @"auto connect fail";

@protocol STCentralToolDelegate <NSObject>

@optional
- (void)centralTool:(STCentralTool *)centralTool findPeripherals:(NSArray *)peripherals;

- (void)centralTool:(STCentralTool *)centralTool connectFailure:(NSError *)error;
- (void)centralTool:(STCentralTool *)centralTool connectSuccess:(CBPeripheral *)peripheral;
- (void)centralTool:(STCentralTool *)centralTool disconnectPeripheral:(CBPeripheral *)peripheral;

- (void)centralTool:(STCentralTool *)centralTool recievedData:(NSData *)data;
- (void)centralTool:(STCentralTool *)centralTool writeFinishWithError:(NSError *)error;

@end

@protocol STCentralToolOTADelegate <NSObject>

@optional
- (void)centralTool:(STCentralTool *)centralTool otaWriteLength:(NSInteger)length;
- (void)centralTool:(STCentralTool *)centralTool otaWriteFinishWithError:(NSError *)error;

@end

@interface STCentralTool : NSObject

@property (weak, nonatomic) id<STCentralToolDelegate, STCentralToolOTADelegate> delegate;
@property (assign, nonatomic) BOOL isConnected; ///< 当前是否是连接状态
@property (strong, nonatomic, readonly) CBCharacteristic *writeCharacteristic; ///< 需要写入的 chaeacteristic，因为有可能不止一个需要写入，所以在写入数据时，需要外部处理要写入哪一个

+ (instancetype)shareInstence;

- (void)startScan;
- (void)stopScan;
- (void)selectPeripheral:(CBPeripheral *)peripheral;
- (void)disconnectWithPeripheral:(CBPeripheral *)peripheral;

- (void)sendData:(NSData *)data toCharacteristic:(CBCharacteristic *)toCharacteristic;
- (void)otaUpdateData:(NSData *)data toCharacteristic:(CBCharacteristic *)toCharacteristic;

@end