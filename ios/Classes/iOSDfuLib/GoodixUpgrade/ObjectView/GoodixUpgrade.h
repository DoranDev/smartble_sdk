//
//  GoodixUpgrade.h
//  SmartV3
//
//  Created by SMA on 2020/5/16.
//  Copyright © 2020 KingHuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRDFUSDK/GRDFUSDK-umbrella.h"

typedef void(^GoodixBlock)(NSInteger type,BOOL isConnected,CGFloat pro);

@interface GoodixUpgrade : NSObject<GRDProgressDelegate>

+ (instancetype)sharedGoodixUpgrade;
@property (nonatomic, copy) GoodixBlock  dfuBlock;
//初始化升级文件
-(void)initGRDFirmware:(NSString*)pathToZip peripheral:(CBPeripheral *)peripheral CentralManager:(CBCentralManager*)Manager;
//Fast up
-(void)FastDFUSetting:(NSString*)filePath peripheral:(CBPeripheral *)peripheral CentralManager:(CBCentralManager*)Manager ExtFlash:(BOOL)toExtFlash;
//开始升级(点击开始升级调用)
-(void)clickStart;
//检查文件是否可用
-(BOOL)isFileValid;
//手动超时机制
-(void)dfuTaskClickStart;
-(void)dfuOver;
//M5C 汇顶固件升级
@property(nonatomic,strong)GRDfuTask* DfuTask;
@property(nonatomic,strong)NSString *zipFileA;//解压得到的文件路径
@property(nonatomic,strong)NSString *zipFileB;
@property (nonatomic) BOOL isFastDFU;
@end


