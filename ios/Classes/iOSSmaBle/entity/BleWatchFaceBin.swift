//
//  BleWatchFaceBin.swift
//  SmartV3
//
//  Created by SMA on 2020/8/25.
//  Copyright © 2020 KingHuang. All rights reserved.
//

import Foundation
// 一个表盘由n个元素构成；一个元素由n张图片构成，其大小必须一致。
// 实际生成表盘二进制文件时，还需要添加一些必要辅助信息，最终格式为：
// Header // 文件头
// ElementInfo[] // 元素信息数组
// uint_32[] // 所有图片长度数组
// int8_t[] // 所有图片的buffer

// 该结构用于生成表盘文件时传参，最终会转换成ElementInfo存于表盘文件中
struct Element{
    var type :UInt8 = 0
    /// 这个属性用于标识当前使用的资源图片是否透明
    var isAlpha :UInt8 = 0
    var w :UInt16 = 0
    var h :UInt16 = 0 // 图片宽高。
    // gravity, x, y确定一个绝对坐标。
    var gravity :UInt8 = 0
    
    /// 默认为0 ， bmp相关的图片用1,
    /// 指针比较特殊, 支持2D使用png的图片, 这个值应该是使用固定值1
    var ignoreBlack :UInt8 = 0
    
    var x :UInt16 = 0
    var y :UInt16 = 0 // 相对gravity坐标
    var bottomOffset :UInt8 = 0 // 指针类型的元素，底部到中心点之间的偏移量。
    // leftOffset 指针类型的元素，左部到中心点之间的偏移量。 png图片时使用0， bmp图片，使用宽度的一半 应用于指针 指针以外的场景中默认为0
    var leftOffset :UInt8 = 0;
    var imageCount :UInt8 = 0// 元素中图片的个数。
    var imageSizes :[UInt32] = [];
    var imageBuffer :Data = Data() // 元素中所有图片的buffer
    
    
    /// 需要注意, 尽量不要使用这个方法构建对象, 因为涉及其他属性问题, 可能导致表盘元素设置错误
    /// 最好就是使用 init(type: Int, isAlpha: UInt8) 方法, 这个方法在创建的时候就指定了元素对象, 是否使用带透明度的图片
    // init() {}
    
    
    /// 构造一个自定义表盘元素对象
    /// Construct a custom dial element object
    /// - Parameters:
    ///   - type: 当前元素类型
    ///   - type: current element type
    ///   - isAlpha: 是否使用了带透明度的资源, 0代表没有使用透明度的资源, 1代表使用了带透明度的资源, 例如png图片是带透明度的, 所以isAlpha应该传递1
    ///   - isAlpha: Whether to use resources with transparency, 0 means no resources with transparency, 1 means resources with transparency are used, for example, png images have transparency, so isAlpha should pass 1
    init(type: Int, isAlpha: UInt8) {
        self.isAlpha = isAlpha
        if isAlpha > 0 {
            self.type = UInt8(type) | 0x80
        } else {
            self.type = UInt8(type)
        }
    }
    
    
    /// 设置元素的数据, 方便赋值, 注意: 用在非指针元素上面
    /// Set the data of the element, convenient for assignment, note: used on non-pointer elements
    mutating func setElementData(point: CGPoint, size: CGSize, ignoreBlack: Int, watchRes: WatchElementResult) {
        self.x = UInt16(point.x)
        self.y = UInt16(point.y)
        self.w = UInt16(size.width)
        self.h = UInt16(size.height)
        
        // 是否忽略黑色, 如果是支持2D的设备使用4, 不支持2D的设备使用0
        // 指针元素有点特殊, 需要单独处理
        self.ignoreBlack = UInt8(ignoreBlack)
        
        self.imageCount = watchRes.imageCount
        self.imageSizes = watchRes.imageDataSize
        self.imageBuffer = watchRes.imageData
        
        
    }
    
    /// 设置指针元素的数据, 方便赋值, 注意: 这个方法仅用在指针元素上面
    /// Set the data of the pointer element, convenient for assignment, note: this method is only used on the pointer element
    mutating func setElementForPointerData(isPoint: Bool, rawSize: CGSize, size: CGSize, watchRes: WatchElementResult) {
        w = UInt16(size.width)
        h = UInt16(size.height)
        
        imageCount = watchRes.imageCount
        imageSizes = watchRes.imageDataSize
        imageBuffer = watchRes.imageData
        
        if isPoint {
            // 判断当前设备是否为JL
            if BleCache.shared.mPlatform == BleDeviceInfo.PLATFORM_JL {
                bottomOffset = UInt8(size.height - (rawSize.height/2))
                leftOffset = UInt8(size.width/2)
            } else {
                //bottomOffset = UInt8(size.height/3)
                bottomOffset = UInt8(size.height/2)
                leftOffset = UInt8(size.width/2 - 1)
            }
        }
    }
    
}

class BleWatchFaceBin: BleWritable {
    
    override var mLengthToWrite: Int {
        BleWatchFaceBinToHeader.ITEM_LENGTH+(BleWatchFaceBinElementInfo.ITEM_LENGTH*ElementInfo.count)+(4*imageCount.count)+imageBuffer.count
    }
    
    var header : BleWatchFaceBinToHeader?
    var ElementInfo : [BleWatchFaceBinElementInfo] = []
    var imageCount  : [UInt32] = []
    var imageBuffer : Data = Data()
    
    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }
    
    init(mheader: BleWatchFaceBinToHeader, mElementInfo: [BleWatchFaceBinElementInfo], mImageCount: [UInt32],mImageBuffer: Data) {
        super.init()
      
        header = mheader
        ElementInfo = mElementInfo
        imageCount = mImageCount
        imageBuffer = mImageBuffer
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func encode() {
        super.encode()
        writeObject(header)
        writeArray(ElementInfo)
        for item in imageCount{
            writeInt32(Int(item),.LITTLE_ENDIAN)
        }
        writeData(imageBuffer)
        
    }
}


class WatchFaceBuilder : NSObject{
    let PNG_ARGB_8888 = 0x01
    let BMP_565 = 0x02
    //适用于MTK，不合规的做法，因出货设备较多，暂时无法纠正
    let GRAVITY_X_LEFT = 1
    let GRAVITY_X_RIGHT = 1<<1 //左移一位
    let GRAVITY_X_CENTER = 1<<2
    let GRAVITY_Y_TOP = 1<<3
    let GRAVITY_Y_BOTTOM = 1<<4
    let GRAVITY_Y_CENTER = 1<<5
    //以下适用于瑞昱
    let GRAVITY_X_CENTER_R = 1 << 1
    let GRAVITY_X_RIGHT_R  = 1 << 2
    let GRAVITY_Y_CENTER_R = 1 << 4
    let GRAVITY_Y_BOTTOM_R = 1 << 5
    
    // 如果是支持2d就选择这个
    let ELEMENT_PREVIEW_2D = 0x01 | 0x80
    // 不支持就使用这个
    let ELEMENT_PREVIEW = 0x01
    let ELEMENT_BACKGROUND = 0x02     //背景无法移动,且默认全屏,设置坐标无意义
    let ELEMENT_NEEDLE_HOUR = 0x03
    let ELEMENT_NEEDLE_MIN = 0x04
    let ELEMENT_NEEDLE_SEC = 0x05
    let ELEMENT_DIGITAL_YEAR = 0x06
    let ELEMENT_DIGITAL_MONTH = 0x07
    let ELEMENT_DIGITAL_DAY = 0x08
    let ELEMENT_DIGITAL_HOUR = 0x09
    let ELEMENT_DIGITAL_MIN = 0x0A
    let ELEMENT_DIGITAL_SEC = 0x0B
    let ELEMENT_DIGITAL_AMPM = 0x0C
    let ELEMENT_DIGITAL_WEEKDAY = 0x0D
    let ELEMENT_DIGITAL_STEP = 0x0E
    let ELEMENT_DIGITAL_HEART = 0x0F
    let ELEMENT_DIGITAL_CALORIE = 0x10
    let ELEMENT_DIGITAL_DISTANCE = 0x11
    let ELEMENT_DIGITAL_BAT = 0x12
    let ELEMENT_DIGITAL_BT = 0x13
    let ELEMENT_DIGITAL_DIV_HOUR = 0x14
    let ELEMENT_DIGITAL_DIV_MONTH = 0x15
    
    static let sharedInstance = WatchFaceBuilder()
    override init() {
        super.init()

    }
}

/// 为了方便处理表盘元素转换后的结果值返回
struct WatchElementResult {
    
    /// 原始图片大小, 这个参数, 仅仅在指针表盘上面有效, 如果是数字指针, 用不到这个参数
    let rawImageSize: CGSize
    /// 裁切后的指针大小
    let imageSize: CGSize
    let imageData: Data
    /// 这个元素中的图片总数量
    let imageCount: UInt8
    /// 存储每一个图片的字节大小
    let imageDataSize: [UInt32]
}
