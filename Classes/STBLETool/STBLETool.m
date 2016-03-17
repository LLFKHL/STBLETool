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

@end

@implementation STBLETool

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
    }
    return self;
}

#pragma mark - Public Methods

- (void)startScan {
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
}

- (void)stopScan {
    [self.centralManager stopScan];
}

- (void)selectPeripheral:(CBPeripheral *)peripheral {
    [self.centralManager connectPeripheral:peripheral options:nil];
}

#pragma mark - CBCentralManagerDelegate

// 最新设备的 central 状态，一般用于检测是否支持 central
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
}

// 找到设备时调用，每找到一个就调用一次
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    [self.discoveredPeripherals addObject:peripheral];
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
        // 找到对应的 Characteristic，就自动读取数据
        if (characteristic.properties == CBCharacteristicPropertyRead) {
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

#pragma mark - Getter / Setter

- (NSMutableArray *)discoveredPeripherals {
    if (!_discoveredPeripherals) {
        _discoveredPeripherals = [NSMutableArray new];
    }
    return _discoveredPeripherals;
}

@end