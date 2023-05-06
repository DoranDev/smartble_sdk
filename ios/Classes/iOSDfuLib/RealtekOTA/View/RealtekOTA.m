//
//  RealtekOTA.m
//  SmartV3
//
//  Created by SMA on 2020/2/20.
//  Copyright © 2020 KingHuang. All rights reserved.
//

#import "RealtekOTA.h"

@interface RealtekOTA ()<RTKLEProfileDelegate, RTKMultiDFUPeripheralDelegate>
@property (nonatomic, strong) NSString *fileName;
@property RTKOTAProfile *OTAProfile;
@property RTKOTAPeripheral *OTAPeripheral;
@property CBPeripheral *peripheral;
@property RTKMultiDFUPeripheral *DFUPeripheral;
@property (nonatomic) BOOL upgradeSilently;
@property (nonatomic) NSArray <RTKOTAUpgradeBin*> *toUpgradeImages;
@property (nonatomic) BOOL isMoreFile;

@end

@implementation RealtekOTA{
    NSDate *_timeUpgradeBegin;
    
    NSArray <RTKOTAUpgradeBin*> *_images;
    NSArray <RTKOTAUpgradeBin*> *_imagesForLeftBud;
    NSArray <RTKOTAUpgradeBin*> *_imagesForRightBud;
    BOOL _upgradeNextConnectedPeripheral;
    BOOL isResourcePack;
}
+ (instancetype)sharedInstance {
    static RealtekOTA *_sharedOption;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedOption = [RealtekOTA new];
    });
    return _sharedOption;
}

- (NSArray <RTKOTAUpgradeBin*> *)imagesUserSelected {
    if (self.OTAPeripheral.isRWS) {
        return self.OTAPeripheral.budType == RTKOTAEarbudPrimary ? _imagesForRightBud : _imagesForLeftBud;
    }
    if (self.fileName.length>1){
        NSError *error;
        _images = [RTKOTAUpgradeBin imagesExtractedFromMPPackFilePath:self.fileName error:&error];
    }
    return _images;
}

- (NSArray <RTKOTAUpgradeBin*> *)toUpgradeImages {
    if (!self.OTAPeripheral)
        return nil;
    
    // 根据设备目前brank情况，过滤掉不符合的image
    switch (self.OTAPeripheral.activeBank) {
        case RTKOTABankTypeBank0:
            NSLog(@"RTKOTABankTypeBank0 - %ld",(long)self.OTAPeripheral.activeBank);
            return [self.imagesUserSelected filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"upgradeBank=%d or upgradeBank=%d", RTKOTAUpgradeBank_Unknown, RTKOTAUpgradeBank_Bank1]];
        case RTKOTABankTypeBank1:
            NSLog(@"RTKOTABankTypeBank1 - %ld",(long)self.OTAPeripheral.activeBank);
            return [self.imagesUserSelected filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"upgradeBank=%d or upgradeBank=%d", RTKOTAUpgradeBank_Unknown, RTKOTAUpgradeBank_SingleOrBank0]];
        case RTKOTABankTypeSingle:
            {
                NSLog(@"RTKOTABankTypeSingle - %ld",(long)self.OTAPeripheral.activeBank);
                NSArray <RTKOTAUpgradeBin*> *imagesForBank1 = [self.imagesUserSelected filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"upgradeBank=%d", RTKOTAUpgradeBank_Bank1]];
                if (imagesForBank1.count > 0) {
                    NSLog(@"Mismatched file: dualbank pack file - single bank chip");
                    return nil;
                } else {
                    return self.imagesUserSelected;
                }
            }
        default:
            NSLog(@"default - %ld",(long)self.OTAPeripheral.activeBank);
            return self.imagesUserSelected;
    }
}
#pragma mark - BLE
- (void)haveSelectedPeripheral:(CBPeripheral *)peripheral {

    self.OTAProfile = [[RTKOTAProfile alloc] init];
    self.OTAProfile.delegate = self;
    
    if (self.OTAPeripheral) {
        [self.OTAProfile cancelConnectionWith:self.OTAPeripheral];
    }
    _peripheral = peripheral;
    NSLog(@"haveSelectedPeripheral - 设置外设");
}

#pragma mark - File
/**带文件名路径,检查文件是否可用*/
-(BOOL)onFileHasSelected:(NSString *)filePath{
    
    BOOL MSG = YES;
    _fileName = filePath;
    if (self.OTAPeripheral.isRWS) {
        NSLog(@"OTAPeripheral.isRWS");
        NSArray <RTKOTAUpgradeBin*> *primaryBins, *secondaryBins;
        NSError *err = [RTKOTAUpgradeBin extractCombinePackFileWithFilePath:filePath toPrimaryBudBins:&primaryBins secondaryBudBins:&secondaryBins];
        if (!err) {
            _imagesForLeftBud = primaryBins;
            _imagesForRightBud = secondaryBins;
            
            if (_imagesForLeftBud.count == 1 && !_imagesForLeftBud.lastObject.ICDetermined) {
                [_imagesForLeftBud.lastObject assertAvailableForPeripheral:self.OTAPeripheral];
            }
            if (_imagesForRightBud.count == 1 && !_imagesForRightBud.lastObject.ICDetermined) {
                [_imagesForLeftBud.lastObject assertAvailableForPeripheral:self.OTAPeripheral];
            }
        }
    } else if (self.OTAPeripheral.notEngaged) {
        NSLog(@"OTAPeripheral.notEngaged");
//        NSArray <RTKOTAUpgradeBin*> *primaryBins, *secondaryBins;
//        NSError *err = [RTKOTAUpgradeBin extractCombinePackFileWithFilePath:filePath toPrimaryBudBins:&primaryBins secondaryBudBins:&secondaryBins];
//        if (!err) {
//            switch (self.OTAPeripheral.budType) {
//                case RTKOTAEarbudPrimary:
//                    _images = primaryBins;
//                    break;
//                case RTKOTAEarbudSecondary:
//                    _images = secondaryBins;
//                    break;
//                default:
//                    break;
//            }
//            if (_images.count == 1 && !_images.lastObject.ICDetermined) {
//                [_images.lastObject assertAvailableForPeripheral:self.OTAPeripheral];
//            }
//        }
        NSError *error;
        _images= [RTKOTAUpgradeBin imagesExtractedFromMPPackFilePath:filePath error:&error];
        if (_images.count == 1 && !_images.lastObject.ICDetermined) {
            [_images.lastObject assertAvailableForPeripheral:self.OTAPeripheral];
        }
    } else {
        NSLog(@"imagesExtractedFromMPPackFilePath");
        NSError *error;
//        _images = [RTKOTAUpgradeBin imagesExtractFromMPPackFilePath:filePath error:&error];
        _images = [RTKOTAUpgradeBin imagesExtractedFromMPPackFilePath:filePath error:&error];
        //多文件同时升级
        /*
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray<RTKOTAUpgradeBin*> *file1;
        NSArray<RTKOTAUpgradeBin*> *file2;
        NSArray<RTKOTAUpgradeBin*> *file3;
        NSArray *nameA = [fileManager subpathsAtPath:filePath];
        for (NSString *name in nameA) {
            if ([name rangeOfString:@".bin"].location != NSNotFound || [name rangeOfString:@".zip"].location != NSNotFound){
                NSURL*fileUrl = [NSURL fileURLWithPath:[filePath stringByAppendingPathComponent:name]];
                NSData *newData = [NSData dataWithContentsOfURL:fileUrl];

                if (file1.count<1) {
                    file1 = [RTKOTAUpgradeBin imagesExtractedFromMPPackFileData:newData error:&error];
                }else if (file1.count>0&& file2.count<1){
                    file2 = [RTKOTAUpgradeBin imagesExtractedFromMPPackFileData:newData error:&error];
                }else if (file2.count>0&& file3.count<1){
                    file3 = [RTKOTAUpgradeBin imagesExtractedFromMPPackFileData:newData error:&error];
                }
            }
        }

        if (file1.count>0&&file2.count>0&&file3.count>0){
            _images = [NSArray arrayWithObjects:[file1 objectAtIndex:0],[file2 objectAtIndex:0],[file3 objectAtIndex:0], nil];
        }else if (file1.count>0&&file2.count<1){
            _images = [NSArray arrayWithObjects:[file1 objectAtIndex:0], nil];
        }else if (file2.count>0&&file3.count<1){
            _images = [NSArray arrayWithObjects:[file1 objectAtIndex:0],[file2 objectAtIndex:0], nil];
        }
         */
        self.isConnectToNumber = 0;
//        NSLog(@"升级文件个数 - %lu error - %@",(unsigned long)_images.count,error);
        if (_images.count == 1 && !_images.lastObject.ICDetermined) {
            [_images.lastObject assertAvailableForPeripheral:self.OTAPeripheral];
        }else{
            for (int i = 0; i<_images.count;i++){
                NSLog(@"----- assertAvailableForPeripheral-%d",i);
                [_images[i] assertAvailableForPeripheral:self.OTAPeripheral];
            }
        }
    }
    if (_images.count>1){
        self.isMoreFile = YES;
    }else{
        self.isMoreFile = NO;
    }
    if (self.toUpgradeImages.count == 0) {
        MSG = NO;
        NSLog(@"文件无效");
    }
    return MSG;
}

- (void)clickStart:(BOOL)upgradeModel{
    isResourcePack = upgradeModel;
    if (self.toUpgradeImages.count > 0) {
        if (self.OTAPeripheral.isRWS) {
            NSAssert(self.OTAPeripheral.canUpgradeSliently, @"RWS peripheral only support silent OTA upgrade.");
            
            _upgradeSilently = YES;
            _upgradeNextConnectedPeripheral = YES;
            
            RTKDFUPeripheral *DFUPeripheral = [self.OTAProfile DFUPeripheralOfOTAPeripheral:self.OTAPeripheral];
            DFUPeripheral.delegate = self;
            [self.OTAProfile connectTo:DFUPeripheral];
            self.DFUPeripheral = (RTKMultiDFUPeripheral*)DFUPeripheral;
            NSLog(@"请稍后");
        } else if (self.OTAPeripheral.canEnterOTAMode && self.OTAPeripheral.canUpgradeSliently) {
            if (upgradeModel) {
                    /**
                        普通升级->升级固件bin文件
                        静默升级->UI、语言包
                     */
                self->_upgradeSilently = NO;
                [self.OTAProfile translatePeripheral:self.OTAPeripheral toDFUPeripheralWithCompletion:^(BOOL success, NSError * _Nullable err, RTKDFUPeripheral * _Nullable peripheral) {
                    if (success) {
                        
                        NSLog(@"连接OTA模式下的外设 - canUpgradeSliently");
                        self.DFUPeripheral = (RTKMultiDFUPeripheral*)peripheral;
                        peripheral.delegate = self;
                        [self.OTAProfile connectTo:peripheral];
                    } else {
                        NSLog(@"切换到OTA mode失败--canUpgradeSliently");
                        return ;
                    }
                }];
            }else{
                self->_upgradeSilently = YES;
                RTKDFUPeripheral *DFUPeripheral = [self.OTAProfile DFUPeripheralOfOTAPeripheral:self.OTAPeripheral];
                if (!DFUPeripheral) {
                    NSLog(@"请重新搜索连接外设- %@",self.OTAPeripheral);
                    return ;
                }else{
                    NSLog(@"静默升级bin包");
                }
                DFUPeripheral.delegate = self;
                [self.OTAProfile connectTo:DFUPeripheral];
                self.DFUPeripheral = (RTKMultiDFUPeripheral*)DFUPeripheral;
            }
        } else if (self.OTAPeripheral.canEnterOTAMode) {
            NSLog(@"请稍后");
            _upgradeSilently = NO;
            [self.OTAProfile translatePeripheral:self.OTAPeripheral toDFUPeripheralWithCompletion:^(BOOL success, NSError * _Nullable err, RTKDFUPeripheral * _Nullable peripheral) {
                if (success) {
                    
                    NSLog(@"连接OTA模式下的外设 - canEnterOTAMode");
                    self.DFUPeripheral = (RTKMultiDFUPeripheral*)peripheral;
                    peripheral.delegate = self;
                    [self.OTAProfile connectTo:peripheral];
                } else {
                    NSLog(@"切换到OTA mode失败---canEnterOTAMode");
                    return ;
                }
            }];
        } else if (self.OTAPeripheral.canUpgradeSliently) {
            _upgradeSilently = YES;
            
            RTKDFUPeripheral *DFUPeripheral = [self.OTAProfile DFUPeripheralOfOTAPeripheral:self.OTAPeripheral];
            DFUPeripheral.delegate = self;
            [self.OTAProfile connectTo:DFUPeripheral];
            self.DFUPeripheral = (RTKMultiDFUPeripheral*)DFUPeripheral;
            
            NSLog(@"请稍后");
        }
    }else{
        NSLog(@"请先选择固件");
        
    }
}


#pragma mark - RTKLEProfileDelegate
- (void)profileManagerDidUpdateState:(RTKLEProfile *)profile {
    NSLog(@"RTKLEProfileDelegate - 蓝牙状态更改");
    if (!self.OTAPeripheral) {
        NSLog(@"profileManagerDidUpdateState - OTAPeripheral");
        self.OTAPeripheral = [self.OTAProfile OTAPeripheralFromCBPeripheral:_peripheral];
    }
    if (profile.centralManager.state == CBManagerStatePoweredOn && self.OTAPeripheral) {
        NSLog(@"Profile is ready now,state = CBManagerStatePoweredOn");
        [self.OTAProfile connectTo:self.OTAPeripheral];
    }else{
        NSLog(@"OTAPeripheral:%@",self.OTAPeripheral);
        NSLog(@"Profile --- State - %ld",(long)profile.centralManager.state);
    }
}
- (void)profileDidBecomeAvailable:(RTKLEProfile *)profile {
    NSLog(@"Profile --- profileDidBecomeAvailable ");
}

- (void)profileDidBecomeUnavailable:(RTKLEProfile *)profile {
    NSLog(@"Profile --- profileDidBecomeUnavailable ");
}

- (void)profile:(RTKLEProfile *)profile didConnectPeripheral:(nonnull RTKLEPeripheral *)peripheral {
    if (peripheral == self.OTAPeripheral) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"正在更新----OTAPeripheral");
            if (self.OTAPeripheral.isRWS && self->_upgradeNextConnectedPeripheral) {
                self->_upgradeSilently = YES;
                self->_upgradeNextConnectedPeripheral = NO;
                
                RTKDFUPeripheral *DFUPeripheral = [self.OTAProfile DFUPeripheralOfOTAPeripheral:self.OTAPeripheral];
                DFUPeripheral.delegate = self;
                [self.OTAProfile connectTo:DFUPeripheral];
                self.DFUPeripheral = (RTKMultiDFUPeripheral*)DFUPeripheral;
                return;
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"_upgradeNextConnectedPeripheral --- NO,刷新UI");
                    if (self->_refBlock) {
                        self.refBlock(0,YES,0);
                    }

                });
                
            }
        });
    } else if (peripheral == self.DFUPeripheral) {
//        [self.DFUPeripheral upgradeImages:self.toUpgradeImages inOTAMode:!self.upgradeSilently];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        array = [self.DFUPeripheral reorderFiles:self.toUpgradeImages];
        [self.DFUPeripheral upgradeImages:array inOTAMode:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"正在更新----DFUPeripheral");
        });
    }
}

- (void)profile:(RTKLEProfile *)profile didDisconnectPeripheral:(nonnull RTKLEPeripheral *)peripheral error:(nullable NSError *)error {
    NSLog(@"profile----didDisconnectPeripheral - %@",error);
    if (peripheral == self.OTAPeripheral) {

        if (!error) {
            self.OTAPeripheral = nil;
        }
    }else if (self.imageNumber!=0){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.isMoreFile == NO){
                NSLog(@"connectTo - %ld",(long)self.imageNumber);
                self.OTAPeripheral = [self.OTAProfile OTAPeripheralFromCBPeripheral:self.peripheral];
                [self.OTAProfile connectTo:self.OTAPeripheral];
            }
             
         });
        
    }
}
- (void)profile:(RTKLEProfile *)profile didFailToConnectPeripheral:(RTKLEPeripheral *)peripheral error:(nullable NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"连接外设失败---%@",error);
        if (self.imageNumber!=0 && self.isConnectToNumber < 3 && self.isMoreFile == NO){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 NSLog(@"连接外设失败-connectTo - %ld",(long)self.imageNumber);
                 self.OTAPeripheral = [self.OTAProfile OTAPeripheralFromCBPeripheral:self.peripheral];
                 [self.OTAProfile connectTo:self.OTAPeripheral];
             });
            
        }else{
            if (self->_refBlock) {
                self.refBlock(0,NO,0);
            }
        }
        self.isConnectToNumber++;
    });
}
#pragma mark - RTKMultiDFUPeripheralDelegate
- (void)DFUPeripheral:(RTKDFUPeripheral *)peripheral didSend:(NSUInteger)length totalToSend:(NSUInteger)totalLength {

    NSLog(@"UpgradProgress -- %@",[NSString stringWithFormat:@"%.2f",((float)length)/totalLength]);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_refBlock) {
            CGFloat pro = (CGFloat)length/totalLength;
            if (length + 1024 > totalLength) {
                pro = 0.99;
            }
            self.refBlock(1,YES,pro);
        }
    });
    
}

- (BOOL)DFUPeripheral:(RTKDFUPeripheral *)peripheral shouldWaitForDisconnectionOnCompleteSend:(RTKOTAUpgradeBin *)image{
    /**新增回调,返回NO SDK即判定升级成功*/
    if (isResourcePack && self.imageNumber>1) {
        NSLog(@"普通升级- shouldWait - YES");
        return YES;
    }else{
        NSLog(@"静默升级 - shouldWait - NO");
        return NO;
    }
    
}

- (void)DFUPeripheral:(RTKDFUPeripheral *)peripheral didFinishWithError:(nullable NSError *)err {
    
    CGFloat pro = 0;
    if (err) {
        if (err.code == 21){
            NSLog(@"资源包升级超时返回升级成功");
             pro = 1;
        }else{
            NSLog(@"升级失败--%@",err);
             pro = 0;
        }
        self.isUpgradeError = 1;
    } else {
         NSLog(@"升级成功-didFinishWithError");
        pro = 1;
        self.isUpgradeError = 0;
    }
    if (self.imageNumber > 0 && !err) {
        self.imageNumber--;
    }
    if (self->_refBlock) {
        self.refBlock(1,YES,pro);
    }
   
    [self.OTAProfile cancelConnectionWith:peripheral];
    if (self.OTAPeripheral){
        [self.OTAProfile cancelConnectionWith:self.OTAPeripheral];
    }
    self.DFUPeripheral = nil;
    self.OTAPeripheral = nil;
}

- (void)DFUPeripheral:(RTKMultiDFUPeripheral *)peripheral willUpgradeImage:(RTKOTAUpgradeBin *)image {
    
}

- (void)DFUPeripheral:(RTKDFUPeripheral *)peripheral didSend:(NSUInteger)len ofImage:(RTKOTAUpgradeBin *)image {
    
}

- (void)DFUPeripheral:(RTKMultiDFUPeripheral *)peripheral didUpgradeImage:(RTKOTAUpgradeBin *)image {
    
}

- (void)DFUPeripheral:(RTKMultiDFUPeripheral *)peripheral didActiveImages:(NSArray<RTKOTAUpgradeBin*>*)images {
    for (RTKOTAUpgradeBin *bin in images ) {
        NSLog(@"%@ has been actived", bin.name);
    }
}

- (void)DFUPeripheral:(RTKMultiDFUPeripheral *)peripheral willSendImage:(RTKOTAUpgradeBin *)image {
    NSLog(@"%@ will be sent", image.name);
}

- (void)DFUPeripheral:(RTKMultiDFUPeripheral *)peripheral didSendImage:(RTKOTAUpgradeBin *)image {
    NSLog(@"%@ has been sent", image.name);
}


#pragma mark - 写入日志

-(void)writeLogToText:(NSString*)message{
    
    NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [NSString stringWithFormat:@"%@/BleLog",array[0]] ;

    NSString *filePathName = [NSString stringWithFormat:@"%@/%@.text",filePath,[self getDateFileName]];
    NSString *writeTime = [NSString stringWithFormat:@"\n%@   %@",[self getCurrentTime],message];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePathName]) {

        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePathName];
        [fileHandle seekToEndOfFile]; //将节点跳到文件的末尾
        NSData *stringData = [writeTime dataUsingEncoding:NSUTF8StringEncoding];
        [fileHandle writeData:stringData]; // 追加写入数据
        [fileHandle closeFile];
    } else {
        NSLog(@"文件不存在,日志不输入");
    }
}

-(NSString*)getDateFileName{
    NSDate *date = [NSDate date];
    NSCalendar *currentCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger integer = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay ;
    NSDateComponents *dataCom = [currentCalendar components:integer fromDate:date];
    return  [NSString stringWithFormat:@"%ld%ld%ld",(long)[dataCom year],(long)[dataCom month],(long)[dataCom day]];
}

-(NSString *)getCurrentTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];//yyyy-MM-dd-hh-mm-ss
    [formatter setDateFormat:@"yyyy:MM:dd hh:mm:ss"];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    return dateTime;
}

@end
