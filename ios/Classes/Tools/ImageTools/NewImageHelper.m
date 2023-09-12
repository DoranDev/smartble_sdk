

#import "NewImageHelper.h"

@implementation NewImageHelper


+ (NSMutableData *) convertUIImageToBitmapRGB565:(UIImage *) image {
    CGImageRef imageRef = image.CGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    NSMutableData *newData = [[NSMutableData alloc]init];
    // Create a bitmap context to draw the uiimage into
    CGContextRef context = [self newBitmapRGB555ContextFromImage:imageRef];
    if(!context) {
        NSLog(@"convertUIImageToBitmapRGB565 is null");
        return NULL;
    }

    CGRect rect = CGRectMake(0, 0, width, height);

    // Draw image into the context to get the raw image data
    CGContextDrawImage(context, rect, imageRef);

    // Get a pointer to the data
    unsigned char *bitmapData = (unsigned char *)CGBitmapContextGetData(context);
    uint16_t *newbit = (uint16_t*)bitmapData;
    // Copy the data and release the memory (return memory allocated with new)
    size_t bytesPerRow = CGBitmapContextGetBytesPerRow(context);
    size_t bufferLength = bytesPerRow * height;
    uint16_t *newBitmap = NULL;
    if(bitmapData) {
        newBitmap = (uint16_t *)malloc(sizeof(uint16_t) * bufferLength/2);
        if(newBitmap) {
            //RGB555->RGB565
            for (int i = 0; i < bufferLength/2;i++ ) {
                newBitmap[i] = newbit[i]&0x1f;
                newBitmap[i] |= (newbit[i]>>5)<<6;
            }
        }
        NSData* data = [NSData dataWithBytes:(const void *)newBitmap length:bufferLength];
        [newData setData:data];
        free(bitmapData);
        free(newBitmap);
    } else {
        NSLog(@"Error getting bitmap pixel data\n");
    }
    CGContextRelease(context);
    return newData;
}

+ (CGContextRef) newBitmapRGB555ContextFromImage:(CGImageRef) image {
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    uint16_t *bitmapData;
    size_t bitsPerComponent = 5;

    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
//每行的字节数等于：每像素比特数乘以图片宽度加 31 的和除以 32，并向下取整，最后乘以 4
    // 向下取整 float floorf(float);
    float bytesFloat = floorf((16.0*width+31)/32);
    size_t bytesPerRow = bytesFloat*4;
    size_t bufferLength = bytesPerRow * height;

    colorSpace = CGColorSpaceCreateDeviceRGB();

    if(!colorSpace) {
        NSLog(@"Error allocating color space RGB\n");
        return NULL;
    }

    // Allocate memory for image data
    bitmapData = (uint16_t *)malloc(bufferLength);

    if(!bitmapData) {
        NSLog(@"Error allocating memory for bitmap\n");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    context = CGBitmapContextCreate(bitmapData,
                                    width,
                                    height,
                                    bitsPerComponent,
                                    bytesPerRow,
                                    colorSpace,
                                    kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder16Little);
    //kCGImagePixelFormatRGB565 kCGBitmapByteOrder16Little kCGBitmapByteOrder16Big
    if(!context) {
        free(bitmapData);
        NSLog(@"Bitmap context not created");
    }

    CGColorSpaceRelease(colorSpace);

    return context;
}

@end
