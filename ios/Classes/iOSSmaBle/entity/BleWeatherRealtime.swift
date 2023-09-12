//
// Created by Best Mafen on 2019/9/30.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

class BleWeatherRealtime: BleWritable {
    static let ITEM_LENGTH = BleTime.ITEM_LENGTH + BleWeather.ITEM_LENGTH

    override var mLengthToWrite: Int {
        BleWeatherRealtime.ITEM_LENGTH
    }

    var mTime: Int = 0 // 时间戳，秒数
    var mWeather: BleWeather? = nil

    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }

    init(time: Int, weather: BleWeather? = nil) {
        super.init()
        mTime = time
        mWeather = weather
    }

    override func encode() {
        super.encode()
        writeObject(BleTime.ofLocal(mTime))
        writeObject(mWeather)
    }

    override func decode() {
        super.decode()
        let bleTime: BleTime = readObject(BleTime.ITEM_LENGTH)
        mTime = bleTime.timeIntervalSince1970ByLocal()
        mWeather = readObject(BleWeather.ITEM_LENGTH)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mTime = try container.decode(Int.self, forKey: .mTime)
        mWeather = try container.decode(BleWeather.self, forKey: .mWeather)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mTime, forKey: .mTime)
        try container.encode(mWeather, forKey: .mWeather)
    }

    private enum CodingKeys: String, CodingKey {
        case mTime, mWeather
    }

    override var description: String {
        "BleWeatherRealtime(mTime: \(BleTime.ofLocal(mTime))), mWeather: \(String(describing: mWeather)))"
    }
    
    func toDictionary()->[String:Any]{
        let dic : [String : Any] = ["mTime":BleTime.ofLocal(mTime),
                                    "mWeather":mWeather?.toDictionary() ?? ["" : ""]]
        return dic
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleWeatherRealtime{
        let newModel = BleWeatherRealtime()
        if dic.keys.count<1{
            return newModel
        }
        newModel.mTime = dic["mTime"] as? Int ?? 0
        let dic1 : [String:Any] = dic["mWeather"] as? [String:Any] ?? [:]
        newModel.mWeather = BleWeather().dictionaryToObjct(dic1)
        return newModel
    }
}
