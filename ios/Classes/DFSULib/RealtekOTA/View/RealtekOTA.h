//
//  RealtekOTA.h
//  SmartV3
//
//  Created by SMA on 2020/2/20.
//  Copyright © 2020 KingHuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <RTKLEFoundation/RTKLEFoundation.h>
//#import <RTKAudioConnectSDK/RTKAudioConnectSDK.h>
#import <RTKOTASDK/RTKOTASDK.h>
#import <UIKit/UIKit.h>


typedef void(^RefreshBlock)(NSInteger type,BOOL isConnected,CGFloat pro);
@interface RealtekOTA : NSObject
+ (instancetype)sharedInstance;
@property (nonatomic, copy) RefreshBlock  refBlock;//抛信息到UI层
- (void)haveSelectedPeripheral:(CBPeripheral *)peripheral;//1.初始化好外设
- (BOOL)onFileHasSelected:(NSString *)filePath;//2.识别文件是否可用
- (void)clickStart:(BOOL)upgradeModel;//开始升级
@property (nonatomic) NSInteger imageNumber;
@property (nonatomic) NSInteger isUpgradeError;
@property (nonatomic) NSInteger isConnectToNumber;
@end
