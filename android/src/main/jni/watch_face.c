//
// Created by Best XiaoKai on 2020/7/15.
// 不能通过变量来指定数组的长度。
//

#include <string.h>
#include "watch_face.h"

int8_t *buildWatchFace(Element *elements, int elementCount, int imageFormat, size_t *finalSize) {
    // Header
    Header header = {0, elementCount, imageFormat};

    // 计算最终生成表盘文件的大小。
    *finalSize += sizeof(Header);
    *finalSize += sizeof(ElementInfo) * elementCount;
    for (int i = 0; i < elementCount; i++) {
        *finalSize += sizeof(uint32_t) * elements[i].imageCount;
        header.imageTotal += elements[i].imageCount;
        for (int j = 0; j < elements[i].imageCount; j++) {
            *finalSize += elements[i].imageSizes[j];
        }
    }
    int8_t *finalBuffer = (int8_t *) malloc(*finalSize);

    size_t copied = 0;
    memcpy(finalBuffer, &header, sizeof(Header));
    copied += sizeof(Header);

    // ElementInfo[]
    uint16_t imageSizeIndex = 0;
    size_t infoSize = elementCount * sizeof(ElementInfo);
    ElementInfo *infos = malloc(infoSize);
    for (int i = 0; i < elementCount; i++) {
        infos[i].imageSizeIndex = imageSizeIndex;
        imageSizeIndex += elements[i].imageCount;
        infos[i].w = elements[i].w;
        infos[i].h = elements[i].h;
        infos[i].x = elements[i].x;
        infos[i].y = elements[i].y;
        infos[i].imageCount = elements[i].imageCount;
        infos[i].type = elements[i].type;
        infos[i].gravity = elements[i].gravity;
        infos[i].ignoreBlack = elements[i].ignoreBlack;
        infos[i].bottomOffset = elements[i].bottomOffset;
        infos[i].leftOffset = elements[i].leftOffset;
    }

    // uint32_t[] 所有图片的长度
    size_t sizeSize = header.imageTotal * sizeof(uint32_t);
    uint32_t elementImageBufferOffset = sizeof(Header) + infoSize + sizeSize;
    uint32_t *imageSizes = malloc(sizeSize);
    uint32_t *ptr = imageSizes;
    for (int i = 0; i < elementCount; i++) {
        infos[i].imageBufferOffset = elementImageBufferOffset;
        for (int j = 0; j < elements[i].imageCount; j++) {
            elementImageBufferOffset += elements[i].imageSizes[j];
            *ptr++ = elements[i].imageSizes[j];
        }
    }

    memcpy(finalBuffer + copied, infos, infoSize);
    copied += infoSize;
    free(infos);

    memcpy(finalBuffer + copied, imageSizes, sizeSize);
    copied += sizeSize;
    free(imageSizes);

    // int8_t[] 所有图片buffer
    size_t imageBufferSize = 0;
    for (int i = 0; i < elementCount; i++) {
        imageBufferSize = 0;
        for (int j = 0; j < elements[i].imageCount; j++) {
            imageBufferSize += elements[i].imageSizes[j];
        }
        memcpy(finalBuffer + copied, elements[i].imageBuffer, imageBufferSize);
        copied += imageBufferSize;
    }
    return finalBuffer;
}
