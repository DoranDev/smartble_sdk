//
//  WatchFaceViewModel.h
//  blesdk3
//
//  Created by 叩鼎科技 on 2023/2/13.
//  Copyright © 2023 szabh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageConverTools : NSObject

+(NSData *)getImgWithImage:(UIImage *)image isAlpha:(BOOL)isAlpha;
    
+(NSData *)getImgWithImage_2:(UIImage *)image isAlpha:(BOOL)isAlpha;

@end

NS_ASSUME_NONNULL_END
