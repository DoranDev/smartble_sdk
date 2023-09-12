//
//  BleWatchFaceBinToHeader.swift
//  SmartV3
//
//  Created by SMA on 2020/8/25.
//  Copyright © 2020 KingHuang. All rights reserved.
//

import Foundation

class BleWatchFaceBinToHeader: BleWritable {

    static let ITEM_LENGTH = 4
    
    override var mLengthToWrite: Int {
        BleWatchFaceBinToHeader.ITEM_LENGTH
    }
    
    var headerImageTotal :UInt16 = 0 // 表盘中所有图片的总数，即表盘里各个元素的所含图片数的累加值。
    var headerElementCount :UInt8 = 0 // 表盘中元素的个数。
    var headerImageFormat :UInt8 = 0
    
    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
            super.init(data, byteOrder)
    }
    
    init(ImageTotal: UInt16, ElementCount: UInt8, ImageFormat: UInt8) {
        super.init()
      
        headerImageTotal = ImageTotal
        headerElementCount = ElementCount
        headerImageFormat = ImageFormat
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
        
    override func encode() {
        super.encode()
        writeInt16(Int(headerImageTotal),.LITTLE_ENDIAN)
        writeInt8(Int(headerElementCount))
        writeInt8(Int(headerImageFormat))
    }
}
