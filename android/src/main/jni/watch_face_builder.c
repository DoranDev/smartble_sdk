//
// Created by XiaoKai on 2020/7/16.
//

#include <jni.h>
#include <string.h>
#include "watch_face.h"

jclass jElementClass = NULL;
jfieldID fieldType = NULL;
jfieldID fieldW = NULL;
jfieldID fieldH = NULL;
jfieldID fieldGravity = NULL;
jfieldID fieldIgnoreBlack = NULL;
jfieldID fieldX = NULL;
jfieldID fieldY = NULL;
jfieldID fieldBottomOffset = NULL;
jfieldID fieldLeftOffset = NULL;
jfieldID fieldImageBuffers = NULL;

JNIEXPORT void JNICALL
Java_com_szabh_smable3_watchface_WatchFaceBuilder_initLib(JNIEnv *env, jobject thiz) {
    jElementClass = (*env)->FindClass(env, "com/szabh/smable3/watchface/Element");
    fieldType = (*env)->GetFieldID(env, jElementClass, "type", "I");
    fieldW = (*env)->GetFieldID(env, jElementClass, "w", "I");
    fieldH = (*env)->GetFieldID(env, jElementClass, "h", "I");
    fieldGravity = (*env)->GetFieldID(env, jElementClass, "gravity", "I");
    fieldIgnoreBlack = (*env)->GetFieldID(env, jElementClass, "ignoreBlack", "I");
    fieldX = (*env)->GetFieldID(env, jElementClass, "x", "I");
    fieldY = (*env)->GetFieldID(env, jElementClass, "y", "I");
    fieldBottomOffset = (*env)->GetFieldID(env, jElementClass, "bottomOffset", "I");
    fieldLeftOffset = (*env)->GetFieldID(env, jElementClass, "leftOffset", "I");
    fieldImageBuffers = (*env)->GetFieldID(env, jElementClass, "imageBuffers", "[[B");
}

JNIEXPORT jbyteArray JNICALL
Java_com_szabh_smable3_watchface_WatchFaceBuilder_build(
        JNIEnv *env, jobject thiz, jobject jElementArray, jint imageFormat
) {
    jint elementCount = (*env)->GetArrayLength(env, jElementArray);
    Element *elements = calloc(elementCount, sizeof(Element));
    for (int i = 0; i < elementCount; i++) {
        jobject element = (*env)->GetObjectArrayElement(env, jElementArray, i);
        elements[i].type = (*env)->GetIntField(env, element, fieldType);
        elements[i].w = (*env)->GetIntField(env, element, fieldW);
        elements[i].h = (*env)->GetIntField(env, element, fieldH);
        elements[i].gravity = (*env)->GetIntField(env, element, fieldGravity);
        elements[i].ignoreBlack = (*env)->GetIntField(env, element, fieldIgnoreBlack);
        elements[i].x = (*env)->GetIntField(env, element, fieldX);
        elements[i].y = (*env)->GetIntField(env, element, fieldY);
        elements[i].bottomOffset = (*env)->GetIntField(env, element, fieldBottomOffset);
        elements[i].leftOffset = (*env)->GetIntField(env, element, fieldLeftOffset);
        jobjectArray bufferArray = (*env)->GetObjectField(env, element, fieldImageBuffers);
        elements[i].imageCount = (*env)->GetArrayLength(env, bufferArray);
        elements[i].imageSizes = calloc(elements[i].imageCount, sizeof(uint32_t));
        uint32_t imageBufferSize = 0;
        jbyteArray buffer;
        for (int j = 0; j < elements[i].imageCount; j++) {
            buffer = (*env)->GetObjectArrayElement(env, bufferArray, j);
            elements[i].imageSizes[j] = (*env)->GetArrayLength(env, buffer);
            imageBufferSize += elements[i].imageSizes[j];
        }
        elements[i].imageBuffer = malloc(imageBufferSize);
        size_t bufferCopied = 0;
        for (int j = 0; j < elements[i].imageCount; j++) {
            buffer = (*env)->GetObjectArrayElement(env, bufferArray, j);
            (*env)->GetByteArrayRegion(env, buffer, 0, elements[i].imageSizes[j],
                                       elements[i].imageBuffer + bufferCopied);
            bufferCopied += elements[i].imageSizes[j];
        }
    }
    size_t watchFaceSize = 0;
    int8_t *watchFace = buildWatchFace(elements, elementCount, imageFormat, &watchFaceSize);
    for (int i = 0; i < elementCount; i++) {
        free(elements[i].imageSizes);
        free(elements[i].imageBuffer);
    }
    free(elements);

    jbyteArray result = (*env)->NewByteArray(env, watchFaceSize);
    (*env)->SetByteArrayRegion(env, result, 0, watchFaceSize, watchFace);
    free(watchFace);
    return result;
}
