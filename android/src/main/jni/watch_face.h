//
// Created by XiaoKai on 2020/7/15.
//
// 一个表盘由n个元素构成；一个元素由n张图片构成，其大小必须一致。
// 实际生成表盘二进制文件时，还需要添加一些必要辅助信息，最终格式为：
// Header // 文件头
// ElementInfo[] // 元素信息数组
// uint_32[] // 所有图片长度数组
// int8_t[] // 所有图片的buffer
//

#ifndef WATCHFACE_WATCHFACE_H
#define WATCHFACE_WATCHFACE_H

#include <stdlib.h>

typedef struct {
    uint16_t imageTotal; // 表盘中所有图片的总数，即表盘里各个元素的所含图片数的累加值。
    uint8_t elementCount; // 表盘中元素的个数。
    uint8_t imageFormat; // 图片格式。
} Header;

// 该结构是表盘文件的组成部分
typedef struct {
    uint32_t imageBufferOffset; // 元素的第一张图片在图片流中的偏移位置。
    uint16_t imageSizeIndex; // 元素的第一张图片的长度在长度数组中的索引。
    uint16_t w, h; // 图片宽高。
    // x, y, gravity确定坐标。
    uint16_t x, y;
    uint8_t imageCount; // 元素中图片的个数。
    uint8_t type;
    uint8_t gravity;
    uint8_t ignoreBlack;
    uint8_t bottomOffset; // 指针类型的元素，底部到中心点之间的偏移量。
    uint8_t leftOffset;   // 指针类型的元素，左部到中心点之间的偏移量。
} ElementInfo;

// 该结构用于生成表盘文件时传参，最终会转换成ElementInfo存于表盘文件中
typedef struct {
    uint8_t type;
    uint16_t w, h; // 图片宽高。
    // gravity, x, y确定一个绝对坐标。
    uint8_t gravity;
    uint8_t ignoreBlack;
    uint16_t x, y; // 相对gravity坐标
    uint8_t bottomOffset; // 指针类型的元素，底部到中心点之间的偏移量。
    uint8_t leftOffset; // 指针类型的元素，左部到中心点之间的偏移量。
    uint8_t imageCount;
    uint32_t *imageSizes;
    int8_t *imageBuffer; // 元素中所有图片的buffer
} Element;

typedef enum {
    BP_CELL_PREVIEW = 0x01,
    BP_CELL_BACKGROUND = 0x02,
    BP_CELL_NEEDLE_HOUR = 0x03,
    BP_CELL_NEEDLE_MIN = 0x04,
    BP_CELL_NEEDLE_SEC = 0x05,
    BP_CELL_DIGITAL_YEAR = 0x06,
    BP_CELL_DIGITAL_MONTH = 0x07,
    BP_CELL_DIGITAL_DAY = 0x08,
    BP_CELL_DIGITAL_HOUR = 0x09,
    BP_CELL_DIGITAL_MIN = 0x0A,
    BP_CELL_DIGITAL_SEC = 0x0B,
    BP_CELL_DIGITAL_AMPM = 0x0C,
    BP_CELL_DIGITAL_WEEK = 0x0D,
    BP_CELL_DIGITAL_STEP = 0x0E,
    BP_CELL_DIGITAL_HEART = 0x0F,
    BP_CELL_DIGITAL_CALORIES = 0x10,
    BP_CELL_DIGITAL_DISTANCE = 0x11,
    BP_CELL_DIGITAL_BAT = 0x12,
    BP_CELL_DIGITAL_BT = 0x13,
    BP_CELL_DIGITAL_DATE_SEPARATOR = 0x14,
    BP_CELL_DIGITAL_TIME_SEPARATOR = 0x15,
} ElementType;

typedef enum {
    PNG_565 = 0x01,
    BMP_565 = 0x02,  // bmp图片是经过处理后的正序图片，且去掉图片头信息
} ImageFormat;

// finalSize用于保存表盘的大小
int8_t *buildWatchFace(Element elements[], int elementCount, int imageFormat, size_t *finalSize);

#endif //WATCHFACE_WATCHFACE_H
