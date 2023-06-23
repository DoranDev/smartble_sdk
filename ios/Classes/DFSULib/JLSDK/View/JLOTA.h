//
//  JLOTA.h
//  blesdk3
//
//  Created by SMA-IOS on 2022/4/27.
//  Copyright © 2022 szabh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>

#import <JL_BLEKit/JL_BLEKit.h>
#import <JLDialUnit/JLDialUnit.h>


#define kUUID_BLE_LAST @"UUID_BLE_LAST"

NS_ASSUME_NONNULL_BEGIN
/**
 *  BLE状态通知
 */
extern NSString *kQCY_BLE_FOUND;         //发现设备
extern NSString *kQCY_BLE_PAIRED;        //已配对
extern NSString *kQCY_BLE_CONNECTED;     //已连接
extern NSString *kQCY_BLE_DISCONNECTED;  //断开连接
extern NSString *kQCY_BLE_ON;            //BLE开启
extern NSString *kQCY_BLE_OFF;           //BLE关闭
/**
 *  错误代码：
 *  4001  BLE未开启
 *  4002  BLE不支持
 *  4003  BLE未授权
 *  4004  BLE重置中
 *  4005  未知错误
 *  4006  连接失败
 *  4007  连接超时
 *  4008  特征值超时
 *  4009  配对失败
 *  4010  设备UUID无效
 */
extern NSString *kQCY_BLE_ERROR;         //BLE报错

/**
 *  BLE特征值
 */
extern NSString *QCY_BLE_SERVICE;        //服务号
extern NSString *QCY_BLE_PAIR_W;         //配对【写】通道
extern NSString *QCY_BLE_PAIR_R;         //配对【读】通道

//messageType 0-> OTA normal 1-> error occurred
typedef void(^JLRefreshBlock)(NSInteger messageType,NSString *message);

@class QCY_Entity;
@interface JLOTA : NSObject
@property(assign,nonatomic)BOOL         isSaveUUID;
@property(strong,nonatomic)NSString     *lastUUID;
@property(strong,nonatomic)NSString     *mBleName;
@property(strong,nonatomic)CBPeripheral *__nullable mBlePeripheral;
@property(strong,nonatomic)JL_Assist    *mAssist;
@property(strong,nonatomic)NSString     *OTAFilePath;
@property(strong,nonatomic)NSString     *watchFacePath;
@property(strong,nonatomic)NSString     *watchFaceName;
@property(strong,nonatomic)NSString     *lastBleMacAddress;
@property(assign,nonatomic)BOOL         isConnect;
@property(assign,nonatomic)BOOL         isWatchFace;
@property (nonatomic, copy) JLRefreshBlock  JLBlock;
+ (instancetype)shared;
/**
 开始搜索
 */
-(void)startScanBLE;
-(void)startScanTimer;
/**
 停止搜索
 */
-(void)stopScanBLE;

/**
 连接设备
 @param peripheral 蓝牙设备类
 */
-(void)connectBLE:(CBPeripheral*)peripheral;

/**
 断开连接
 */
-(void)disconnectBLE;

/**
 使用UUID，重连设备。
*/
-(void)connectPeripheralWithUUID:(NSString*)uuid;

/**
 设置OTA文件路径
*/
-(void)setPathFromOTAFile:(NSString*)filePath;
/**
 手动开启表盘传输
*/
-(void)openWatchFace;
/**
 退出表盘断开连接
*/
-(void)synchronizeWatchFaceDone;

/**
  OTA失败固件仍处于广播状态时修复固件
*/
-(void)startFirmwareRepair:(NSString*)macAddress;

@end

@interface QCY_Entity  : NSObject                                //蓝牙设备模型
@property(strong,nonatomic)NSNumber       *mRSSI;
@property(strong,nonatomic)CBPeripheral   *mPeripheral;
@property(strong,nonatomic)NSString       *mName;
@end
NS_ASSUME_NONNULL_END


