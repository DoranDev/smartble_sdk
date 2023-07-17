//
//  ImageHelper.h
//  blesdk3
//
//  Created by SMA-IOS on 2022/2/7.
//  Copyright © 2022 szabh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageHelper : NSObject {

}

/**
 Converts a UIImage to RGB565 bitmap.
 @param image - a UIImage to be converted
 @return a RGB565 bitmap, or NULL if any memory allocation issues. Cleanup memory with free() when done.
 */
+ (NSMutableData *) convertUIImageToBitmapRGB565:(UIImage *) image;

@end
