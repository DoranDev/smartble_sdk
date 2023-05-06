//
//  MTKOTA.h
//  SmartV3
//
//  Created by SMA on 2020/7/6.
//  Copyright © 2020 KingHuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>
#import "SMAFotaApi.h"
#import "MTKDeviceInfo.h"
#import "FotaObject.h"
/**SDK已集成发送升级包代码,此处只做检测是否有版本升级处理,请求成功后抛出下载地址*/
typedef void(^MTKRefreshBlock)(NSInteger type,NSString *url,NSString *newVersion);
@interface MTKOTA : NSObject
+ (instancetype)sharedInstance;
-(void)getMTKVersion;
-(NSString*)subStringToVersion:(NSString *)version;
@property (nonatomic, copy) MTKRefreshBlock  mtkotaBlock;
@property (nonatomic, strong) MTKDeviceInfo *deviceInfo;
@end

