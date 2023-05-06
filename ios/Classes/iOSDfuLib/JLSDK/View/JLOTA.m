//
//  JLOTA.m
//  blesdk3
//
//  Created by SMA-IOS on 2022/4/27.
//  Copyright © 2022 szabh. All rights reserved.
//

#import "JLOTA.h"

NSString *kQCY_BLE_FOUND        = @"QCY_BLE_FOUND";            //发现设备
NSString *kQCY_BLE_PAIRED       = @"QCY_BLE_PAIRED";           //BLE已配对
NSString *kQCY_BLE_CONNECTED    = @"QCY_BLE_CONNECTED";        //BLE已连接
NSString *kQCY_BLE_DISCONNECTED = @"QCY_BLE_DISCONNECTED";     //BLE断开连接
NSString *kQCY_BLE_ON           = @"QCY_BLE_ON";               //BLE开启
NSString *kQCY_BLE_OFF          = @"QCY_BLE_OFF";              //BLE关闭
NSString *kQCY_BLE_ERROR        = @"QCY_BLE_ERROR";            //BLE错误提示

NSString *QCY_BLE_SERVICE = @"AE00"; //服务号
NSString *QCY_BLE_RCSP_W  = @"AE01"; //命令“写”通道
NSString *QCY_BLE_RCSP_R  = @"AE02"; //命令“读”通道

NSString *kUI_JL_DEVICE_PREPARING       = @"UI_JL_DEVICE_PREPARING";
NSString *kUI_JL_DEVICE_SHOW_OTA        = @"UI_JL_DEVICE_SHOW_OTA";

@interface JLOTA()<CBCentralManagerDelegate,
                         CBPeripheralDelegate>
{
    CBCentralManager    *bleManager;
    CBManagerState      bleManagerState;
    
    NSMutableArray      *blePeripheralArr;
    CBPeripheral        *bleCurrentPeripheral;
    NSString            *bleCurrentName;
    
    /*--- 连接超时管理 ---*/
    NSTimer             *linkTimer;
}

@end

@implementation JLOTA

+(instancetype)shared{
    static JLOTA *SDK;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        SDK = [JLOTA new];
    });
    return SDK;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        bleManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        
        linkTimer = [JL_Tools timingStart:@selector(startScanBLE)
                                   target:self Time:1.0];
        [JL_Tools timingPause:linkTimer];
        
        self.isSaveUUID = YES;
        self.isWatchFace = NO;
        self.isConnect = NO;
        /*--- JLSDK ADD ---*/
        self.mAssist = [[JL_Assist alloc] init];
        self.mAssist.mNeedPaired = YES;             //是否需要握手配对
        self.mAssist.mPairKey    = nil;             //配对秘钥
        self.mAssist.mService    = QCY_BLE_SERVICE; //服务号
        self.mAssist.mRcsp_W     = QCY_BLE_RCSP_W;  //特征「写」
        self.mAssist.mRcsp_R     = QCY_BLE_RCSP_R;  //特征「读」
    }
    return self;
}


-(void)startScanTimer{
    if (linkTimer) {
        [JL_Tools timingContinue:linkTimer];
    }else{
        linkTimer = [JL_Tools timingStart:@selector(startScanBLE)
                                   target:self Time:1.0];
    }
}

-(void)stopScanTimer{
    [JL_Tools timingPause:linkTimer];
    [self stopScanBLE];
}


#pragma mark - 开始扫描
-(void)startScanBLE{
    blePeripheralArr = [NSMutableArray new];
    [self newScanBLE];
}

-(void)newScanBLE{
    if (bleManager) {
        if (bleManager.state == CBManagerStatePoweredOn) {
            [self scan];
        }else{
            [JL_Tools delay:0.5 Task:^{
                if (self->bleManager.state == CBManagerStatePoweredOn) {
                    [self scan];
                }
            }];
        }
    }
}
-(void)scan{
    [bleManager scanForPeripheralsWithServices:nil options:nil];
}


#pragma mark - 停止扫描
-(void)stopScanBLE{
    if (bleManager) [bleManager stopScan];
}

#pragma mark - 连接设备
-(void)connectBLE:(CBPeripheral*)peripheral{
    
    bleCurrentPeripheral = peripheral;
    [bleCurrentPeripheral setDelegate:self];
    
    [bleManager connectPeripheral:bleCurrentPeripheral
                          options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:@(YES),
                                    CBConnectPeripheralOptionNotifyOnConnectionKey:@(YES)
                          }];
    [bleManager stopScan];

    NSLog(@"BLE Connecting... Name ---> %@ UUID:%@",peripheral.name,peripheral.identifier.UUIDString);
}

#pragma mark - 断开连接
-(void)disconnectBLE{
    if (bleCurrentPeripheral) {
        NSLog(@"BLE --->To disconnectBLE.");
        [bleManager cancelPeripheralConnection:bleCurrentPeripheral];
    }
}



#pragma mark - 使用UUID，重连设备。
-(void)connectPeripheralWithUUID:(NSString*)uuid{
    
    NSArray *uuidArr = @[[[NSUUID alloc] initWithUUIDString:uuid]];
    NSArray *phArr = [bleManager retrievePeripheralsWithIdentifiers:uuidArr];//serviceUUID就是你首次连接配对的蓝牙
    [JL_Tools add:kQCY_BLE_PAIRED Action:@selector(noteEntityConnected:) Own:self];
//    [JL_Tools add:kJL_MANAGER_WATCH_FACE Action:@selector(noteWatchFace:) Own:self];
    if (phArr.count == 0) {
        return;
    }
    
    CBPeripheral* peripheral = phArr[0];
    
    if(phArr.firstObject
       && [phArr.firstObject state] != CBPeripheralStateConnected
       && [phArr.firstObject state] != CBPeripheralStateConnecting)
    {
        
        NSString *ble_name = peripheral.name;
        NSString *ble_uuid = peripheral.identifier.UUIDString;
        NSLog(@"QCY Connecting(Last)... Name ---> %@ UUID:%@",ble_name,ble_uuid);
        
        bleCurrentPeripheral = peripheral;
        [bleCurrentPeripheral setDelegate:self];
        
        [bleManager connectPeripheral:bleCurrentPeripheral
                              options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:@(YES)}];
    }
}

#pragma mark - 蓝牙初始化 Callback
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSInteger st = central.state;
    /*--- JLSDK ADD ---*/
    [self.mAssist assistUpdateState:central.state];
    
    bleManagerState = st;

    if (bleManagerState != CBManagerStatePoweredOn) {
        self.mBlePeripheral = nil;
    }
    
    switch (central.state) {
        case CBManagerStatePoweredOn:
            NSLog(@"BLE--> CBManagerStatePoweredOn....");
            [JL_Tools post:kQCY_BLE_ON Object:@(1)];
            break;
        case CBManagerStatePoweredOff:
            NSLog(@"BLE--> CBManagerStatePoweredOff");
            [JL_Tools post:kQCY_BLE_ERROR Object:@(4001)];
            [JL_Tools post:kQCY_BLE_OFF Object:@(0)];
            break;
        case CBManagerStateUnsupported:
            NSLog(@"BLE--> CBManagerStateUnsupported");
            [JL_Tools post:kQCY_BLE_ERROR Object:@(4002)];
            [JL_Tools post:kQCY_BLE_OFF Object:@(-1)];
            break;
        case CBManagerStateUnauthorized:
            NSLog(@"BLE--> CBManagerStateUnauthorized");
            [JL_Tools post:kQCY_BLE_ERROR Object:@(4003)];
            [JL_Tools post:kQCY_BLE_OFF Object:@(-2)];
            break;
        case CBManagerStateResetting:
            NSLog(@"BLE--> CBCentralManagerStateResetting");
            [JL_Tools post:kQCY_BLE_ERROR Object:@(4004)];
            [JL_Tools post:kQCY_BLE_OFF Object:@(-3)];
            break;
        case CBManagerStateUnknown:
            NSLog(@"BLE--> CBCentralManagerStateUnknown");
            [JL_Tools post:kQCY_BLE_ERROR Object:@(4005)];
            [JL_Tools post:kQCY_BLE_OFF Object:@(-4)];
            break;
    }
}


#pragma mark - 发现设备
-(void)centralManager:(CBCentralManager *)central
didDiscoverPeripheral:(CBPeripheral *)peripheral
    advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                 RSSI:(NSNumber *)RSSI
{
    //NSString *ble_uuid = peripheral.identifier.UUIDString;
    NSString *ble_name = advertisementData[@"kCBAdvDataLocalName"]; //peripheral.name;
    NSData   *ble_AD   = advertisementData[@"kCBAdvDataManufacturerData"];
    //if (ble_name.length == 0 || [RSSI intValue] < -70) return;
    //if (ble_name.length == 0) return;
    
    NSLog(@"发现 ----> NAME:%@ RSSI:%@ AD:%@ ",ble_name,RSSI,ble_AD);
    
    [self addPeripheral:peripheral RSSI:RSSI Name:ble_name];
    [JL_Tools post:kQCY_BLE_FOUND Object:blePeripheralArr];
    
    // ota升级过程，回连使用
    if (self.lastBleMacAddress.length>10){
        if ([JL_BLEAction otaBleMacAddress:self.lastBleMacAddress isEqualToCBAdvDataManufacturerData:ble_AD]) {
            [self connectBLE:peripheral];
        }
    }    
}

-(void)addPeripheral:(CBPeripheral*)peripheral
                RSSI:(NSNumber *)rssi
                Name:(NSString*)name
{
    int flag = 0;
    for (NSMutableDictionary *infoDic in blePeripheralArr) {
        CBPeripheral *info_pl = infoDic[@"BLE"];
        NSString *info_uuid = info_pl.identifier.UUIDString;
        NSString *ble_uuid  = peripheral.identifier.UUIDString;
        if ([info_uuid isEqual:ble_uuid]) {
            flag = 1;
            [infoDic setObject:rssi forKey:@"RSSI"];
            break;
        }
    }
    if (flag == 0 && name.length>0) {
        NSMutableDictionary *mDic = [NSMutableDictionary new];
        [mDic setObject:peripheral      forKey:@"BLE"];
        [mDic setObject:rssi            forKey:@"RSSI"];
        [mDic setObject:name?:@"Unknow" forKey:@"NAME"];
        [blePeripheralArr addObject:mDic];
    }
}

-(void)centralManager:(CBCentralManager *)central connectionEventDidOccur:(CBConnectionEvent)event
        forPeripheral:(CBPeripheral *)peripheral{
    if (event == CBConnectionEventPeerConnected) {
        NSLog(@"---> 系统界面，已连接设备:%@",peripheral.name);
        if (peripheral.name.length > 0) {
            [self connectBLE:peripheral];
        }
    }
    
    if (event == CBConnectionEventPeerDisconnected) {
        NSLog(@"---> 系统界面，断开设备:%@",peripheral.name);
    }
}


#pragma mark - 设备连接回调
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"BLE Connected ---> Device %@",peripheral.name);
    [JL_Tools post:kQCY_BLE_CONNECTED Object:peripheral];
    
    // 连接成功后，查找服务
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(nullable NSError *)error
{
    NSLog(@"Err:BLE Connect FAIL ---> Device:%@ Error:%@",peripheral.name,[error description]);
    [JL_Tools post:kQCY_BLE_ERROR Object:@(4006)];
}

#pragma mark - 设备服务回调
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error
{
    if (error) {
        NSLog(@"Err: Discovered services fail.");
        if (self->_JLBlock) {
            self.JLBlock(1,@"Discovered services fail.");
        }
        return;
        
    }
    NSLog(@"设备服务回调 - didDiscoverServices");
    for (CBService *service in peripheral.services) {
        NSLog(@"BLE Service ---> %@",service.UUID.UUIDString);
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

#pragma mark - 设备特征回调
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service
             error:(nullable NSError *)error
{
    if (error) {
        NSLog(@"Err: Discovered Characteristics fail.");
        if (self->_JLBlock) {
            self.JLBlock(1,@"Discovered Characteristics fail.");
        }
        return;
        
    }
    NSLog(@"设备特征回调 - didDiscoverCharacteristicsForService");
    /*--- JLSDK ADD ---*/
    [self.mAssist assistDiscoverCharacteristicsForService:service Peripheral:peripheral];
}


#pragma mark - 更新通知特征的状态
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error{
    if (error) {
        NSLog(@"Err: Update NotificationState For Characteristic fail.");
        if (self->_JLBlock) {
            self.JLBlock(1,@"Update NotificationState For Characteristic fail.");
        }
        return;
    }
   
    /*--- JLSDK ADD ---*/
    [self.mAssist assistUpdateCharacteristic:characteristic
                                  Peripheral:peripheral
                                      Result:^(BOOL isPaired) {
        NSLog(@"更新通知特征的状态 - %d",isPaired);
        if (isPaired == YES) {
            [JL_Tools setUser:peripheral.identifier.UUIDString forKey:kUUID_BLE_LAST];
            self.lastBleMacAddress = @"";
            self.isConnect = YES;
            self->_mBlePeripheral = peripheral;
            /*--- UI配对成功 ---*/
            [JL_Tools post:kQCY_BLE_PAIRED Object:peripheral];
        }else{
            [self->bleManager cancelPeripheralConnection:peripheral];
        }
    }];
}


#pragma mark - 设备返回的数据 GET
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    if (error) { NSLog(@"Err: receive data fail."); return; }

    /*--- JLSDK ADD ---*/
    [self.mAssist assistUpdateValueForCharacteristic:characteristic];
}

#pragma mark - 设备断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(nullable NSError *)error
{
    NSLog(@"BLE Disconnect ---> Device %@ error:%d",peripheral.name,(int)error.code);
    self.mBlePeripheral = nil;
    
    /*--- JLSDK ADD ---*/
    [self.mAssist assistDisconnectPeripheral:peripheral];
    
    /*--- UI刷新，设备断开 ---*/
    [JL_Tools post:kQCY_BLE_DISCONNECTED Object:peripheral];
}

#pragma mark 设备被连接
-(void)noteEntityConnected:(NSNotification*)note{
    
    __weak typeof(self) wSelf = self;
    [self.mAssist.mCmdManager cmdTargetFeatureResult:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
        JL_CMDStatus st = status;
        if (st == JL_CMDStatusSuccess) {
            if (self.isWatchFace){
                [self openWatchFace];
            }else{
                JLModel_Device *model = [wSelf.mAssist.mCmdManager outputDeviceModel];

                JL_OtaStatus upSt = model.otaStatus;
                if (upSt == JL_OtaStatusForce) {
                    NSLog(@"JL_OtaStatusForce ---> 进入强制升级,跳至升级界面，执行OTA升级");
                    [self startOTA];
                    return;
                }else{
                    if (model.otaHeadset == JL_OtaHeadsetYES) {
                        NSLog(@"JL_OtaHeadsetYES ---> 进入强制升级,跳至升级界面，执行OTA升级");
    //                    [self startOTA];
                        return;
                    }
                    [self startOTA];
                    NSLog(@"设备正常使用");
                }
            }
        }
    }];
}

#pragma mark - OTA操作
-(void)setPathFromOTAFile:(NSString*)filePath{
    self.OTAFilePath = filePath;
}

-(void)startOTA{
    if (self.OTAFilePath.length < 10) {
        NSLog(@"路径错误 - %@",self.OTAFilePath);
        return;
    }
    NSData *otaData = [NSData dataWithContentsOfFile:self.OTAFilePath];
    /*--- 开始OTA升级 ---*/
    [self.mAssist.mCmdManager.mOTAManager cmdOTAData:otaData Result:^(JL_OTAResult result, float progress) {
        [JL_Tools mainTask:^{
            if (result == JL_OTAResultPreparing ||
                result == JL_OTAResultUpgrading){
                [self otaTimeCheck];//增加超时检测
                if (self->_JLBlock) {
                    int type = 0;
                    if (result == JL_OTAResultPreparing){
                        type = 4;//文件校验中
                    }
                    self.JLBlock(type,[NSString stringWithFormat:@"%.1f",progress*100.0]);
                }
            }else if (result == JL_OTAResultPrepared) {
                [self otaTimeCheck];//增加超时检测
                NSLog(@"等待升级");
            }else if (result == JL_OTAResultSuccess) {
                NSLog(@"升级成功 - %d",result);
                if (self->_JLBlock ) {
                    self.JLBlock(2,@"");
                }
                [self otaTimeClose];
            }else{
                NSString *message = @"";
                if (result == JL_OTAResultFail) {
                    NSLog(@"OTA升级失败");
                    message = @"JL_OTAResultFail";
                }else if (result == JL_OTAResultDataIsNull) {
                    NSLog(@"OTA升级数据为空!");
                    message = @"JL_OTAResultDataIsNull";
                }else if (result == JL_OTAResultCommandFail) {
                    NSLog(@"OTA指令失败!");
                    message = @"JL_OTAResultCommandFail";
                }else if (result == JL_OTAResultSeekFail) {
                    NSLog(@"OTA标示偏移查找失败");
                    message = @"JL_OTAResultSeekFail";
                }else if (result == JL_OTAResultInfoFail) {
                    NSLog(@"OTA升级固件信息错误!");
                    message = @"JL_OTAResultInfoFail";
                }else if (result == JL_OTAResultLowPower) {
                    NSLog(@"OTA升级设备电压低!");
                    message = @"JL_OTAResultLowPower";
                }else if (result == JL_OTAResultEnterFail) {
                    NSLog(@"未能进入OTA升级模式!");
                    message = @"JL_OTAResultEnterFail";
                }else if (result == JL_OTAResultUnknown) {
                    NSLog(@"OTA未知错误!");
                    message = @"JL_OTAResultUnknown";
                }else if (result == JL_OTAResultFailSameVersion) {
                    NSLog(@"相同版本!");
                    message = @"JL_OTAResultFailSameVersion";
                }else if (result == JL_OTAResultReconnectWithMacAddr) {
                    
                    JLModel_Device *model = [self.mAssist.mCmdManager outputDeviceModel];
                    self.lastBleMacAddress = model.bleAddr;
                    [self startScanBLE];
                    [self otaTimeClose];//关闭超时检测
                    if (self->_JLBlock ) {
                        self.JLBlock(5,self.lastBleMacAddress);
                    }
                    NSLog(@"---> OTA正在通过Mac Addr方式回连设备... %@", model.bleAddr);
                }
                if (self->_JLBlock && message.length>0) {
                    self.JLBlock(1,message);
                }
                
            }
            if (result == JL_OTAResultReconnect) {
                [self otaTimeCheck];//增加超时检测
                NSLog(@"---> OTA正在回连设备...");
            }

            

            
        }];
    }];
}
static NSTimer  *otaTimer = nil;
static int      otaTimeout= 0;
-(void)otaTimeCheck{
    otaTimeout = 0;
    if (otaTimer == nil) {
        otaTimer = [JL_Tools timingStart:@selector(otaTimeAdd)
                                  target:self Time:1.0];
    }
}

-(void)otaTimeClose{
    [JL_Tools timingStop:otaTimer];
    otaTimeout = 0;
    otaTimer = nil;
}

-(void)otaTimeAdd{
    otaTimeout++;
    if (otaTimeout == 10) {
        [self otaTimeClose];
        if (self->_JLBlock) {
            self.JLBlock(3,@"OTA ---> timeOut");
        }
        NSLog(@"OTA ---> 超时了！！！");
    }
 }

#pragma mark - 固件修复
-(void)startFirmwareRepair:(NSString*)macAddress{
    NSLog(@"startFirmwareRepair - %@",macAddress);
    [JL_Tools add:kQCY_BLE_PAIRED Action:@selector(noteEntityConnected:) Own:self];
    self.lastBleMacAddress = macAddress;
    [self startScanBLE];
    [self otaTimeClose];
}

#pragma mark - 表盘操作
-(void)setPathFromWatchFace:(NSString*)filePath fileName:(NSString*)fileName{
    self.watchFacePath = filePath;
    self.watchFaceName = fileName;
    
}

-(void)openWatchFace{
    [JL_Tools add:@"OPEN_WATCHFACE" Action:@selector(senderWatchFace) Own:self];
    [DialManager openDialFileSystemWithCmdManager:self.mAssist.mCmdManager withResult:^(DialOperateType type, float progress) {
            if (type == DialOperateTypeUnnecessary ||
                type == DialOperateTypeSuccess) {
                NSLog(@"无需重复打开表盘文件系统");
                [JL_Tools post:@"OPEN_WATCHFACE" Object:nil];
                return;
            } else if (type == DialOperateTypeFail) {
                NSLog(@"--->打开表盘文件系统失败!");
                self.watchFacePath = @"";
                return;
            }else{
                NSLog(@"--->打开表盘文件系统 - %ld",(long)type);
            }
    }];
}

-(void)senderWatchFace{
    if (self.watchFacePath.length>0){
        NSLog(@"senderWatchFace - %@",self.watchFacePath);
        NSData *pathData = [NSData dataWithContentsOfFile:self.watchFacePath];
        [DialManager addFile:self.watchFaceName Content:pathData
                          Result:^(DialOperateType type, float progress)
            {
                if (type == DialOperateTypeNoSpace) {
                    NSLog(@"空间不足!");
                }
                if (type == DialOperateTypeFail) {
                    NSLog(@"添加失败!");
                }
                if (type == DialOperateTypeDoing) {
                    NSString *txt = [NSString stringWithFormat:@"添加进度:%.1f%%",progress*100.0f];
                    NSLog(@"%@",txt);
                }
                if (type == DialOperateTypeSuccess) {
                    NSLog(@"添加完成!");
                }
        }];

    }
}

-(void)synchronizeWatchFaceDone{
    self.isConnect = NO;
    self.watchFacePath = @"";
    [self disconnectBLE];
}
@end


@implementation QCY_Entity
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    QCY_Entity *entity   = [[self class] allocWithZone:zone];
    entity.mRSSI        = self.mRSSI;
    entity.mPeripheral  = self.mPeripheral;
    entity.mName        = self.mName;
    return entity;
}
@end
