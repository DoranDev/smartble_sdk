//
// Created by Best Mafen on 2019/9/26.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

class BleTemperatureDetecting: BleWritable {
    static let ITEM_LENGTH = 6

    override var mLengthToWrite: Int {
        BleTemperatureDetecting.ITEM_LENGTH
    }

    var mBleTimeRange = BleTimeRange()
    var mInterval: Int = 0 // 分钟数，发送时除以5

    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }

    override func encode() {
        super.encode()
        writeObject(mBleTimeRange)
        writeInt8(mInterval / 5)
    }

    override func decode() {
        super.decode()
        mBleTimeRange = readObject(BleTimeRange.ITEM_LENGTH)
        mInterval = Int(readUInt8()) * 5
    }

    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mBleTimeRange = try container.decode(BleTimeRange.self, forKey: .mBleTimeRange)
        mInterval = try container.decode(Int.self, forKey: .mInterval)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mBleTimeRange, forKey: .mBleTimeRange)
        try container.encode(mInterval, forKey: .mInterval)
    }

    private enum CodingKeys: String, CodingKey {
        case mBleTimeRange, mInterval
    }

    override var description: String {
        "BleTemperatureDetecting(mBleTimeRange: \(mBleTimeRange), mInterval: \(mInterval))"
    }
    
    func toDictionary()->[String:Any]{
        let dic : [String : Any] = ["mBleTimeRange":mBleTimeRange.toDictionary(),
                                    "mInterval":mInterval]
        return dic
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleTemperatureDetecting{
        let newModel = BleTemperatureDetecting()
        if dic.keys.count<1{
            return newModel
        }
        newModel.mInterval = dic["mInterval"] as? Int ?? 0
        let dicTimeRange : [String : Any] = dic["mBleTimeRange"] as! [String : Any]
        newModel.mBleTimeRange = BleTimeRange().dictionaryToObjct(dicTimeRange)
        return newModel
    }
}
