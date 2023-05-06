////
////  GoodixUpgrade.m
////  SmartV3
////
////  Created by SMA on 2020/5/16.
////  Copyright © 2020 KingHuang. All rights reserved.
////
//
//#import "GoodixUpgrade.h"
//#import "SSZipArchive.h"
//
//@interface GoodixUpgrade() {
//    NSTimer *newTimer;
//    int currentProgress;//记录当前进度
//    int oldProgress;//time判断进度是否改变
//    int notProCount;//进入为改变计数
//}
//@end
//
//@implementation GoodixUpgrade
//
//+ (instancetype)sharedGoodixUpgrade{
//    static GoodixUpgrade *_sharedGoodix;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _sharedGoodix = [GoodixUpgrade new];
//    });
//    return _sharedGoodix;
//}
//
//#pragma mark - FASTDFU固件升级
//-(void)FastDFUSetting:(NSString*)filePath peripheral:(CBPeripheral *)peripheral CentralManager:(CBCentralManager*)Manager ExtFlash:(BOOL)toExtFlash{
//    self.zipFileA = [NSString stringWithFormat:@"%@", filePath];
//    NSData* fileData = [NSData dataWithContentsOfFile:filePath];
//    if (toExtFlash) {
//        uint32_t toAddr = 0; //示例资源升级的目标地址。0x01040000
//        //toExtFlash YES表示升级到外部flash(类似UI包、字体包)
//        NSLog(@"UI升级 - %@", [NSString stringWithFormat:@"fastDFUResourceWithCentralManager - %lu",(unsigned long)fileData.length]);
//        [GRDFUTool fastDFUResourceWithCentralManager:Manager
//                                          identifier:peripheral.identifier.UUIDString
//                                            fileData:fileData
//                                          toExtFlash:toExtFlash
//                                              toAddr:toAddr
//                                            delegate:self
//                                           extraInfo:nil];
//    }else{
//        NSLog(@"固件升级 %@\nzipFileA = %@", [NSString stringWithFormat:@"fastDFUWithCentralManager - %lu",(unsigned long)fileData.length],self.zipFileA);
//        NSLog(@"设备UUIDString = %@",peripheral.identifier.UUIDString);
//        [GRDFUTool fastDFUWithCentralManager:Manager
//                                  identifier:peripheral.identifier.UUIDString
//                                firmwareData:fileData
//                                    delegate:self
//                                   extraInfo:nil];
//    }    
//    [GRDFUTool enableLog:YES];
//}
//
//#pragma mark - AB模式升级
//-(void)initGRDFirmware:(NSString*)pathToZip peripheral:(CBPeripheral *)peripheral CentralManager:(CBCentralManager*)Manager{
//    //配置下载文件
////    GRDFirmware* fw1 = [[GRDFirmware alloc]initWithData:[NSData dataWithContentsOfFile:pathToA]];
////    GRDFirmware* fw2 = [[GRDFirmware alloc]initWithData:[NSData dataWithContentsOfFile:pathToB]];
////    if ([fw1 isValid] && [fw2 isValid]) {
////        //文件可用
////        NSArray<GRDFirmware*>* fwList = [NSArray arrayWithObjects:fw1, fw2, nil];
////
////        self.DfuTask = [GRDfuTask new];
////        //设置要链接的对象
////        NSUUID* dfuIdentify = [[NSUUID alloc]initWithUUIDString:peripheral.identifier.UUIDString];
////        [self.DfuTask attachWithIdentifier:dfuIdentify centralManager:Manager];
////
////        // 第二步，设置升级模式，这里设置为AB模式，在Block里面可以知道选择了哪个固件
////        [self.DfuTask setDfuMode:fwList selectionHandler:^BOOL(GRDfuTask * _Nonnull task, GRDFirmware * _Nonnull selectedFw) {
////            NSLog(@"显示选择的固件 - %@",[selectedFw getInfo]->_comment);
////            // 返回YES表示继续执行，返回NO表示终止升级过程。
////            return YES;
////        }];
////
////    }
//    if ([self UnzipFiles:pathToZip]) {
//        if(self.zipFileA.length >10 && self.zipFileA.length > 10){
//            //新SDK升级方式,注释代码升级方式依旧有用
//            NSMutableArray* fwDatas = [NSMutableArray new];
//            NSData* fwData1 = [NSData dataWithContentsOfFile:self.zipFileA];
//            [fwDatas addObject:fwData1];
//
//            NSData* fwData2 = [NSData dataWithContentsOfFile:self.zipFileB];
//            [fwDatas addObject:fwData2];
//
//            [GRDFUTool abModeUpgradeWithCentralManager:Manager identifier:peripheral.identifier.UUIDString firmwareDatas:fwDatas handlerBlock:^BOOL(GRDfuTask * _Nonnull task, GRDFirmware * _Nonnull selectedFw) {
//                return YES;
//            } delegate:self extraInfo:nil];
//            [GRDFUTool enableLog:YES];
//        }else{
//            NSLog(@"文件处理失败1");
//        }
//        
//    }else{
//        NSLog(@"文件处理失败");
//    }
//    
//}
////判断文件是否可用
//-(BOOL)isFileValid{
//    if (_isFastDFU) {
//        if (self.zipFileA.length < 10){
//            return  NO;
//        }else{
//            GRDFirmware* fw1 = [[GRDFirmware alloc]initWithData:[NSData dataWithContentsOfFile:self.zipFileA]];
//            if ([fw1 isValid]) {
//                return YES;
//            }else{
//                return NO;
//            }
//        }
//    }else{
//        if (self.zipFileA.length < 10 || self.zipFileB.length < 10){
//            return NO;
//        }else{
//            GRDFirmware* fw1 = [[GRDFirmware alloc]initWithData:[NSData dataWithContentsOfFile:self.zipFileA]];
//            GRDFirmware* fw2 = [[GRDFirmware alloc]initWithData:[NSData dataWithContentsOfFile:self.zipFileB]];
//            if ([fw1 isValid] && [fw2 isValid]) {
//                return YES;
//            }else{
//                return NO;
//            }
//        }
//    }
//}
////解压服务器ZIP文件
//-(BOOL)UnzipFiles:(NSString*)filePath{
//
//    BOOL success = [SSZipArchive unzipFileAtPath:filePath toDestination:[self UnzipFilePath] progressHandler:^(NSString *entry, unz_file_info zipInfo, long entryNumber, long total) {
//        // entryNumber 代表正在解压缩第几个文件
//        // total 代表总共有多少个文件需要解压缩
//        // 该block会调用多次，在这里可以获取解压缩的进度
//        NSLog(@"entryNumber - %zd--- total - %zd",entryNumber,total);
//
//    } completionHandler:^(NSString *path, BOOL succeeded, NSError *error) {
//        if ([path isEqualToString:filePath]){
//            NSLog(@"completionHandler - %@ succeeded - %d error - %@",path,succeeded,error);
//            if (succeeded){
//
//                NSString * docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//                NSString * rarFilePath = [docsdir stringByAppendingPathComponent:@"CacheUnzip"];
//                NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:rarFilePath];
//                NSString *fileName;
//                NSMutableArray *itemArray = [NSMutableArray array];
//                while (fileName = [dirEnum nextObject]) {
//                    if ([fileName rangeOfString:@".bin"].location != NSNotFound){
//                        [itemArray addObject:[NSString stringWithFormat:@"%@/%@",rarFilePath,fileName]];
//                    }
//                }
//                if (itemArray.count == 2){
//                    /**与服务器约定,zip包内有goodix两个bin固件升级包.解压超过2个文件不处理*/
//                    self.zipFileA = [itemArray objectAtIndex:0];
//                    self.zipFileB = [itemArray objectAtIndex:1];
//                    NSLog(@"解压文件路径: \nzipFileA - %@ \nzipFileB = %@",self.zipFileA,self.zipFileB);
//
//                }else{
//                    succeeded =  NO;
//                    NSLog(@"解压失败 文件数目 - %luu",(unsigned long)itemArray.count);
//                }
//            }else{
//                NSLog(@"解压失败");
//                succeeded = NO;
//            }
//        }
//
//    }];
//
//    return success;
//}
//
//-(NSString*)UnzipFilePath{
//    
//    NSString * docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString * rarFilePath = [docsdir stringByAppendingPathComponent:@"CacheUnzip"];//将需要创建的串拼接到后面
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    BOOL isDir = NO;
//    BOOL existed = [fileManager fileExistsAtPath:rarFilePath isDirectory:&isDir];
//   
//    if ( !(isDir == YES && existed == YES) ) {//如果文件夹不存在
//        [fileManager createDirectoryAtPath:rarFilePath withIntermediateDirectories:YES attributes:nil error:nil];
//    }else{
//        //删除文件夹内所有文件
//        NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:rarFilePath];
//        NSString *fileName;
//        while (fileName = [dirEnum nextObject]) {
//            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@",rarFilePath,fileName] error:nil];
//            NSLog(@"删除原有升级文件文件 - %@",fileName);
//        }
//    }
//    return rarFilePath;
//}
//
////开启升级
//-(void)clickStart{
//    [self dfuTaskClickStart];
//    [self.DfuTask start:self];
//}
//#pragma mark - Timeout mechanism
//-(void)dfuTaskClickStart{
//    if (newTimer == nil) {
//        currentProgress = 0;
//        oldProgress = 0;
//        notProCount = 0;
//        newTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(dfuTaskClickStart) userInfo:nil repeats:YES];
//
//    }else{
//        if (currentProgress == oldProgress) {
//            notProCount++;
//        }else if (notProCount == 25){
//            NSLog(@"2分钟进度为改变,结束升级");
//            if (newTimer) {
//                [newTimer invalidate];
//                newTimer = nil;
//            }
//            if (self->_dfuBlock) {
//                self.dfuBlock(1,YES,-1);
//            }
//        }else{
//            oldProgress = currentProgress;
//        }
//    }
//}
//
//-(void)dfuOver{
//    NSLog(@"--dfuOver--");
//    if (newTimer) {
//        [newTimer invalidate];
//        newTimer = nil;
//    }
//}
//
//#pragma mark - GRDProgressDelegate
//    
//-(void)dfuTaskDidStart:(GRDfuTask*)task{
//    NSLog(@"开始升级-DidStart-Goodix");
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (self->_dfuBlock) {
//            self.dfuBlock(1,YES,0.0);
//        }
//    });
//}
//-(void)dfuTask:(GRDfuTask*)task didUpdateProgress:(float)percent{
//    NSLog(@"Goodix didUpdateProgress - %lf",percent);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (self->_dfuBlock) {
//            self->currentProgress = percent;//更新当前进度
//            self.dfuBlock(1,YES,percent);
//        }
//    });
//
//}
//-(void)dfuTask:(GRDfuTask*)task didAbortForError:(int)errCode message:(NSString*)msg{
//    NSLog(@"Goodix didAbortForError - %@",msg);
//    if (msg) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (self->_dfuBlock) {
//                self.dfuBlock(1,YES,-1);
//            }
//        });
//    }
//}
//-(void)dfuTaskDidComplete:(GRDfuTask*)task{
//    NSLog(@"dfuTaskDidComplete - 没有完成任务");
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (self->_dfuBlock) {
//            self.dfuBlock(1,YES,-1);
//        }
//    });
//}
//
//- (void)dfuTaskDidAbortForError:(int)errCode message:(nonnull NSString *)msg type:(GRDTaskType)type extraInfo:(nonnull NSDictionary *)extraInfo {
//    NSLog(@"dfuTaskDidAbortForError - %d msg - %@",errCode,msg);
//    if (msg) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (self->_dfuBlock) {
//                self.dfuBlock(1,YES,-1);
//            }
//        });
//    }
//}
//
//- (void)dfuTaskDidCompleteWithType:(GRDTaskType)type extraInfo:(nonnull NSDictionary *)extraInfo {
//    NSLog(@"dfuTaskDidCompleteWithType -- %lu",(unsigned long)type);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (self->_dfuBlock) {
//            self.dfuBlock(1,YES,1);
//        }
//    });
//}
//
//- (void)dfuTaskDidStartWithType:(GRDTaskType)type extraInfo:(nonnull NSDictionary *)extraInfo {
//    NSLog(@"开始升级- Goodix -- %lu",(unsigned long)type);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (self->_dfuBlock) {
//            self.dfuBlock(1,YES,0.0);
//        }
//    });
//}
//
//- (void)dfuTaskDidUpdateProgress:(float)percent type:(GRDTaskType)type extraInfo:(nonnull NSDictionary *)extraInfo progressType:(int)progressType {
//    //此处需要注意!!!，当为FASTDFU升级的时候，progressType == 1 是擦除flash的进度。progressType == 0是升级过程的进度。
//
//     NSLog(@">>>>>>>>>  progressType:%d \n>>>>>>>>>  onDfuUpdateProgress: %.1f",progressType, percent/100);
//    if (progressType == 0) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (self->_dfuBlock) {
//                float perCent = percent/100.0;
//                if (perCent>1) {
//                    perCent = 0.99;
//                }
//                self->currentProgress = perCent;//更新当前进度
//                self.dfuBlock(1,YES,perCent);
//            }
//        });
//    }
//}
//
//
//- (void)dfuTaskDidUpdateProgress:(float)percent type:(GRDTaskType)type extraInfo:(nonnull NSDictionary *)extraInfo {
//    NSLog(@"dfuTaskDidUpdateProgress -- %f",percent);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (self->_dfuBlock) {
//            self->currentProgress = percent/100;//更新当前进度
//            self.dfuBlock(1,YES,percent/100);
//        }
//    });
//}
//
//@end
