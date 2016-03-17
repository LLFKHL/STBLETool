//
//  STBLETool.m
//  STBLETool
//
//  Created by TangJR on 3/16/16.
//  Copyright © 2016 tangjr. All rights reserved.
//

#import "STBLETool.h"

@interface STBLETool () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;

@property (strong, nonatomic) NSMutableArray *discoveredPeripherals; // 找到的所有的 Peripheral
@property (strong, nonatomic) CBPeripheral *connectedPeripheral; // 当前已经连接的 Peripheral
@property (strong, nonatomic) CBCharacteristic *connectedCharacteristic; // 当前已经连接的 Characteristic

@property (strong, nonatomic) NSTimer *timeoutTimer;

@end

@implementation STBLETool

static const NSTimeInterval STBLETimeOut = 5.0;
static const BOOL STBLEAutoConnect = YES;

#pragma mark - Left Cycle

+ (instancetype)shareInstence {
    static STBLETool *tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [STBLETool new];
    });
    return tool;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        if (STBLEAutoConnect) {
            [self startScan];
        }
    }
    return self;
}

#pragma mark - Public Methods

- (void)startScan {
    [self.discoveredPeripherals removeAllObjects];
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
}

- (void)stopScan {
    [self.centralManager stopScan];
}

- (void)selectPeripheral:(CBPeripheral *)peripheral {
    [self.centralManager connectPeripheral:peripheral options:nil];
}

- (void)sendData:(NSData *)data {
    [self.connectedPeripheral writeValue:data forCharacteristic:self.connectedCharacteristic type:CBCharacteristicWriteWithResponse];
}

#pragma mark - Private Methods

- (void)startTimer {
    self.timeoutTimer = [NSTimer timerWithTimeInterval:STBLETimeOut target:self selector:@selector(timeOut) userInfo:nil repeats:NO];
}

- (void)stopTimer {
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
}

- (void)timeOut {
    
}

#pragma mark - CBCentralManagerDelegate

// 最新设备的 central 状态，一般用于检测是否支持 central
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
}

// 找到设备时调用，每找到一个就调用一次
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if (![self.discoveredPeripherals containsObject:peripheral]) {
        [self.discoveredPeripherals addObject:peripheral];
    }
//    [self selectPeripheral:peripheral];
    
    if (STBLEAutoConnect) {
        [self.centralManager retrievePeripheralsWithIdentifiers:@[peripheral.identifier]];
    }
}

// 成功连接到某个设备
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    peripheral.delegate = self;
    self.connectedPeripheral = peripheral;
    [peripheral discoverServices:nil];
}

#pragma mark - CBPeripheralDelegate

// 搜索到 Service （或失败）
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        return;
    }
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

// 搜索到 Characteristic （或失败）
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        return;
    }
    for (CBCharacteristic *characteristic in service.characteristics) {
        self.connectedCharacteristic = characteristic;
        // 找到对应的 Characteristic，就自动读取数据
        if (characteristic.properties & CBCharacteristicPropertyRead) {
            [peripheral readValueForCharacteristic:characteristic];
        }
    }
}

// 读到 Characteristic 的数据的回调
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        return;
    }
    NSData *value = characteristic.value;
    NSLog(@"%@", value);
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

#pragma mark - Getter / Setter

- (NSMutableArray *)discoveredPeripherals {
    if (!_discoveredPeripherals) {
        _discoveredPeripherals = [NSMutableArray new];
    }
    return _discoveredPeripherals;
}

@end