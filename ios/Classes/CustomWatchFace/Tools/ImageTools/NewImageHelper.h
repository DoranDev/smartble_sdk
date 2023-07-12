

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NewImageHelper : NSObject {

}

/** Converts a UIImage to RGB565 bitmap.
 @param image - a UIImage to be converted
 @return a RGB565 bitmap, or NULL if any memory allocation issues. Cleanup memory with free() when done.
 */

+ (NSMutableData *) convertUIImageToBitmapRGB565:(UIImage *) image;

@end
