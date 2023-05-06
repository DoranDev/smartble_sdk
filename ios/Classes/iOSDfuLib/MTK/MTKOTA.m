//
//  MTKOTA.m
//  SmartV3
//
//  Created by SMA on 2020/7/6.
//  Copyright © 2020 KingHuang. All rights reserved.
//

#import "MTKOTA.h"

@interface MTKOTA ()<SMAFotaApiDelegate>
//检测版本
@property (nonatomic, strong) SMAFotaApi *MTKOta;
@property (nonatomic, strong) VersionInfo *versionInfo;
@end

@implementation MTKOTA

+ (instancetype)sharedInstance {
    static MTKOTA *_sharedOption;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedOption = [MTKOTA new];
       
    });
    
    return _sharedOption;
}

-(void)getMTKVersion{
    self.MTKOta = [[SMAFotaApi alloc]init];
    self.MTKOta.fotaDelegate = self;
    [self.MTKOta registDeviceWithProductId:self.deviceInfo.productId
                             productSecret:self.deviceInfo.productSecret
                                       mid:self.deviceInfo.mid
                                       oem:self.deviceInfo.oem
                                    models:self.deviceInfo.models
                                  platform:self.deviceInfo.platform
                                deviceType:self.deviceInfo.deviceType
                                   version:self.deviceInfo.version
                                       mac:@""
                                sdkVersion:@"ios3.0"];
}

#pragma mark - Device registration successful callback
-(void)registerDeviceSuccess:(NSDictionary *)deviceInfo {

    self.deviceInfo.deviceId = deviceInfo[@"deviceId"];
    self.deviceInfo.deviceSecret = deviceInfo[@"deviceSecret"];
    [self checkoutVersion];
}

- (void)checkoutVersion {
    
    [self.MTKOta checkVersionWithProductId:self.deviceInfo.productId
                                deviceId:self.deviceInfo.deviceId
                            deviceSecret:self.deviceInfo.deviceSecret
                                     mid:self.deviceInfo.mid
                                 version:self.deviceInfo.version];
}

- (void)registerDeviceFail:(NSDictionary *)error {
   
    NSLog(@"registerDeviceFail - %@",error);
    if (self->_mtkotaBlock) {
         self.mtkotaBlock(0,@"",@"");
    }
}

-(void)VersionError:(NSDictionary *)dic{
    NSLog(@"VersionError - %@",dic);
    NSInteger code = [dic[@"status"] integerValue];
    if (code == 2101) {
       //当前已经是最新版本
       if (self->_mtkotaBlock) {
           self.mtkotaBlock(2101,@"",@"");
      }
    }else if (code == 2103) {
      
    }
}

-(void)versionResponse:(VersionInfo *)versionInfo{
    
    NSString *newV = [self subStringToVersion:versionInfo.version.versionName];
//    NSString *oldV = [self subStringToVersion:self.deviceInfo.version];
//    if (![oldV isEqualToString:newV]) {
        NSLog(@"服务器有新版本");
        if (self->_mtkotaBlock) {
            NSString *url = [NSString stringWithFormat:@"%@", versionInfo.version.deltaUrl];
            self.mtkotaBlock(1,url,[self subStringToVersion:newV]);
        }
//    }
}

-(NSString*)subStringToVersion:(NSString *)version{
    NSRange ranVersion = [version rangeOfString:@"V"];
    NSString * string = @"";
    if (ranVersion.location != NSNotFound){
        string = [version substringWithRange:NSMakeRange(ranVersion.location, 6)];
    }else{
        string = version;
    }
    return string;
}


@end
