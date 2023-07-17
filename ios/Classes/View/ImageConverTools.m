//
//  WatchFaceViewModel.m
//  blesdk3
//
//  Created by 叩鼎科技 on 2023/2/13.
//  Copyright © 2023 szabh. All rights reserved.
//

#import "ImageConverTools.h"
#import <JL_BLEKit/JL_BLEKit.h>

@implementation ImageConverTools

+(NSData *)getImgWithImage:(UIImage *)image isAlpha:(BOOL)isAlpha{

    
    int width = image.size.width;
    int height = image.size.height;
    
    
    //NSFileManager *fm = [[NSFileManager alloc] init];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)lastObject];
    
    
    //NSString *pngFilePath = [[NSBundle mainBundle] pathForResource:@"compass.png" ofType:nil];
    //UIImage *img = [UIImage imageWithContentsOfFile:pngFilePath];
    //NSString *pngFilePath = [[NSBundle mainBundle] pathForResource:@"pv.png" ofType:nil];
    //UIImage *img = [UIImage imageWithContentsOfFile:pngFilePath];
    
    
    NSData *bitmap = [BitmapTool convert_B_G_R_A_BytesFromImage:image];
    
    NSString *bmpPath = [NSString stringWithFormat:@"%@/%@", documentPath, @"bmp_D.bmp"];
    Boolean isOK = [JL_Tools writeData:bitmap fillFile:bmpPath];
    
    NSLog(@"bmp是否成功res:%d", isOK);
    
    
    NSString *binPath = [NSString stringWithFormat:@"%@/%@", documentPath, @"output_D.bin"];
    /*--- BR28压缩算法 ---*/ //注意:这里根据自己需求，从上面图片转码API选择。
    int res = 0;
    if (isAlpha) {
        res = br28_btm_to_res_path_with_alpha_nopack((char*)[bmpPath UTF8String], width, height, (char*)[binPath UTF8String]);
    } else {
        res = br28_btm_to_res_path_nopack((char*)[bmpPath UTF8String], width, height, (char*)[binPath UTF8String]);
    }

    NSLog(@"是否成功res:%d", res);
    NSLog(@"--->Br28 BIN【%@】is OK!", binPath);
    //注意:这里的【binPath】就是我们转换好的图片路径。
    
    
    
    
    return [NSData dataWithContentsOfFile:binPath];
}




+(NSData *)getImgWithImage_2:(UIImage *)image isAlpha:(BOOL)isAlpha{

    
//    int width = image.size.width;
//    int height = image.size.height;
    int width = 466; // image.size.width;
    int height = 466; // image.size.height;
    
    
    //NSFileManager *fm = [[NSFileManager alloc] init];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)lastObject];
    
    
    NSString *pngFilePath = [[NSBundle mainBundle] pathForResource:@"466.png" ofType:nil];
    UIImage *img = [UIImage imageWithContentsOfFile:pngFilePath];
    //NSString *pngFilePath = [[NSBundle mainBundle] pathForResource:@"pv.png" ofType:nil];
    //UIImage *img = [UIImage imageWithContentsOfFile:pngFilePath];
    
    
    NSData *bitmap = [BitmapTool convert_B_G_R_A_BytesFromImage:img];
    
    NSString *bmpPath = [NSString stringWithFormat:@"%@/%@", documentPath, @"bmp_B.bmp"];
    Boolean isOK = [JL_Tools writeData:bitmap fillFile:bmpPath];
    
    NSLog(@"bmp是否成功res:%d", isOK);
    
    
    NSString *binPath = [NSString stringWithFormat:@"%@/%@", documentPath, @"output_B.bin"];
    /*--- BR28压缩算法 ---*/ //注意:这里根据自己需求，从上面图片转码API选择。
    int res = 0;
    if (isAlpha) {
        res = br28_btm_to_res_path_with_alpha_nopack((char*)[bmpPath UTF8String], width, height, (char*)[binPath UTF8String]);
    } else {
        res = br28_btm_to_res_path_nopack((char*)[bmpPath UTF8String], width, height, (char*)[binPath UTF8String]);
    }

    NSLog(@"是否成功res:%d", res);
    NSLog(@"--->Br28 BIN【%@】is OK!", binPath);
    //注意:这里的【binPath】就是我们转换好的图片路径。
    
    
    
    
    return [NSData dataWithContentsOfFile:binPath];
}






//-(NSData *)getImgWithImage:(UIImage *)image{
//
//    int width = 454;
//    int height = 454;
//
//
//    //NSFileManager *fm = [[NSFileManager alloc] init];
//    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)lastObject];
//
//
//    NSString *pngFilePath = [[NSBundle mainBundle] pathForResource:@"compass.png" ofType:nil];
//    UIImage *img = [UIImage imageWithContentsOfFile:pngFilePath];
//
//
//    NSData *bitmap = [BitmapTool convert_B_G_R_A_BytesFromImage:img];
//
//    NSString *bmpPath = [NSString stringWithFormat:@"%@/%@", documentPath, @"bmp_2.bmp"];
//    Boolean isOK = [JL_Tools writeData:bitmap fillFile:bmpPath];
//
//    NSLog(@"是否成功res:%d", isOK);
//
//
//    NSString *binPath = [NSString stringWithFormat:@"%@/%@", documentPath, @"output_3.bin"];
//    /*--- BR28压缩算法 ---*/ //注意:这里根据自己需求，从上面图片转码API选择。
////    int res = br28_btm_to_res_path_nopack((char*)[bmpPath UTF8String], width, height, (char*)[binPath UTF8String]);
//    int res = br28_btm_to_res_path_with_alpha_nopack((char*)[bmpPath UTF8String], width, height, (char*)[binPath UTF8String]);
//
//    NSLog(@"是否成功res:%d", res);
//    NSLog(@"--->Br28 BIN【%@】is OK!", binPath);
//    //注意:这里的【binPath】就是我们转换好的图片路径。
//
//    return [NSData dataWithContentsOfFile:binPath];
//}

@end
