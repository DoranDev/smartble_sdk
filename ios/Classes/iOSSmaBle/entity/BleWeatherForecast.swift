//
// Created by Best Mafen on 2019/9/30.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

class BleWeatherForecast: BleWritable {
    static let ITEM_LENGTH = BleTime.ITEM_LENGTH + BleWeather.ITEM_LENGTH * 3

    override var mLengthToWrite: Int {
        BleWeatherForecast.ITEM_LENGTH
    }

    var mTime: Int = 0 // 时间戳，秒数
    var mWeather1: BleWeather? = nil
    var mWeather2: BleWeather? = nil
    var mWeather3: BleWeather? = nil

    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }

    init(time: Int, weather1: BleWeather? = nil, weather2: BleWeather? = nil,
         weather3: BleWeather? = nil) {
        super.init()
        mTime = time
        mWeather1 = weather1
        mWeather2 = weather2
        mWeather3 = weather3
    }

    override func encode() {
        super.encode()
        writeObject(BleTime.ofLocal(mTime))
        writeObject(mWeather1)
        writeObject(mWeather2)
        writeObject(mWeather3)
    }

    override func decode() {
        super.decode()
        let bleTime: BleTime = readObject(BleTime.ITEM_LENGTH)
        mTime = bleTime.timeIntervalSince1970ByLocal()
        mWeather1 = readObject(BleWeather.ITEM_LENGTH)
        mWeather2 = readObject(BleWeather.ITEM_LENGTH)
        mWeather3 = readObject(BleWeather.ITEM_LENGTH)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mTime = try container.decode(Int.self, forKey: .mTime)
        mWeather1 = try container.decode(BleWeather.self, forKey: .mWeather1)
        mWeather2 = try container.decode(BleWeather.self, forKey: .mWeather2)
        mWeather3 = try container.decode(BleWeather.self, forKey: .mWeather3)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mTime, forKey: .mTime)
        try container.encode(mWeather1, forKey: .mWeather1)
        try container.encode(mWeather2, forKey: .mWeather2)
        try container.encode(mWeather3, forKey: .mWeather3)
    }

    private enum CodingKeys: String, CodingKey {
        case mTime, mWeather1, mWeather2, mWeather3
    }

    override var description: String {
        "BleWeatherForecast(mTime: \(BleTime.ofLocal(mTime)), mWeather1: \(String(describing: mWeather1))" +
            ", mWeather2: \(String(describing: mWeather2)), mWeather3: \(String(describing: mWeather3)))"
    }
    
    func toDictionary()->[String:Any]{
        let dic : [String : Any] = ["mTime":BleTime.ofLocal(mTime),
                                    "mWeather1":mWeather1?.toDictionary() ?? [:],
                                    "mWeather2":mWeather2?.toDictionary() ?? [:],
                                    "mWeather3":mWeather3?.toDictionary() ?? [:]]
        return dic
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleWeatherForecast{
        let newModel = BleWeatherForecast()
        if dic.keys.count<1{
            return newModel
        }
        newModel.mTime = dic["mTime"] as? Int ?? 0
        let dic1 : [String:Any] = dic["mWeather1"] as? [String:Any] ?? [:]
        let dic2 : [String:Any] = dic["mWeather2"] as? [String:Any] ?? [:]
        let dic3 : [String:Any] = dic["mWeather3"] as? [String:Any] ?? [:]
        newModel.mWeather1 = BleWeather().dictionaryToObjct(dic1)
        newModel.mWeather2 = BleWeather().dictionaryToObjct(dic2)
        newModel.mWeather3 = BleWeather().dictionaryToObjct(dic3)
        return newModel
    }
}
