//
// Created by Best Mafen on 2019/9/30.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

class BleHrMonitoringSettings: BleWritable {
    override var mLengthToWrite: Int {
        1 + BleTimeRange.ITEM_LENGTH
    }

    var mBleTimeRange = BleTimeRange()
    var mInterval: Int = 0 // 分钟数

    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }

    override func encode() {
        super.encode()
        writeObject(mBleTimeRange)
        writeInt8(mInterval > 0 ? mInterval : 1)  // mInterval 设置的最小值为1
    }

    override func decode() {
        super.decode()
        mBleTimeRange = readObject(BleTimeRange.ITEM_LENGTH)
        mInterval = Int(readUInt8())
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
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
        "BleHrMonitoringSettings(mBleTimeRange: \(mBleTimeRange), mInterval: \(mInterval))"
    }
    
    func toDictionary()->[String:Any]{
        let dic : [String : Any] = ["mBleTimeRange":mBleTimeRange.toDictionary(),
                                    "mInterval":mInterval]
        return dic
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleHrMonitoringSettings{
        let newModel = BleHrMonitoringSettings()
        if dic.keys.count<1{
            return newModel
        }
        newModel.mInterval = dic["mInterval"] as? Int ?? 0
        let dic1 : [String:Any] = dic["mBleTimeRange"] as? [String:Any] ?? [:]
        newModel.mBleTimeRange = BleTimeRange().dictionaryToObjct(dic1)
        return newModel
    }
}
