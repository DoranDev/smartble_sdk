//
//  BleWatchFaceBinElementInfo.swift
//  SmartV3
//
//  Created by SMA on 2020/8/25.
//  Copyright © 2020 KingHuang. All rights reserved.
//

import Foundation

class BleWatchFaceBinElementInfo: BleWritable {

    static let ITEM_LENGTH = 20

    override var mLengthToWrite: Int {
        BleWatchFaceBinElementInfo.ITEM_LENGTH
    }
    
    var infoImageBufferOffset :UInt32 = 0 // 元素的第一张图片在图片流中的偏移位置。
    var infoImageSizeIndex :UInt16 = 0 // 元素的第一张图片的长度在长度数组中的索引。
    var infoW :UInt16 = 0
    var infoH :UInt16 = 0// 图片宽高。
    // x, y, gravity确定坐标。
    var infoX :UInt16 = 0
    var infoY :UInt16 = 0
    // 元素中图片的个数。
    var infoImageCount : UInt8 = 0
    var infoType: UInt8 = 0
    var infoGravity :UInt8 = 0
    var infoIgnoreBlack :UInt8 = 0
    var infoBottomOffset : UInt8 = 0 // 指针类型的元素，底部到中心点之间的偏移量。
    var infoLeftOffset :UInt8 = 0; // 指针类型的元素，左部到中心点之间的偏移量。
    var infoReserved : UInt8 = 0
    
    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
            super.init(data, byteOrder)
    }
    
    init(imageBufferOffset: UInt32, imageSizeIndex: UInt16, w: UInt16, h: UInt16, x: UInt16, y: UInt16, imageCount: UInt8, type: UInt8, gravity: UInt8, ignoreBlack: UInt8, bottomOffset: UInt8,leftOffset:UInt8 ,reserved: UInt8) {
        super.init()
        infoImageBufferOffset = imageBufferOffset
        infoImageSizeIndex = imageSizeIndex
        infoW = w
        infoH = h
        infoX = x
        infoY = y
        infoImageCount = imageCount
        infoType = type
        infoGravity = gravity
        infoIgnoreBlack = ignoreBlack
        infoBottomOffset = bottomOffset
        infoLeftOffset = leftOffset
        infoReserved = reserved
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
        
    override func encode() {
        super.encode()
        writeInt32(Int(infoImageBufferOffset),.LITTLE_ENDIAN)
        writeInt16(Int(infoImageSizeIndex),.LITTLE_ENDIAN)
        writeInt16(Int(infoW),.LITTLE_ENDIAN)
        writeInt16(Int(infoH),.LITTLE_ENDIAN)
        writeInt16(Int(infoX),.LITTLE_ENDIAN)
        writeInt16(Int(infoY),.LITTLE_ENDIAN)
        writeInt8(Int(infoImageCount))
        writeInt8(Int(infoType))
        writeInt8(Int(infoGravity))
        writeInt8(Int(infoIgnoreBlack))
//        writeInt16(Int(infoGravity),.LITTLE_ENDIAN)
        writeInt8(Int(infoBottomOffset))
        writeInt8(Int(infoLeftOffset))
//        writeInt8(Int(infoReserved))
    }
}
