//
//  BleWeatherRealtime2.swift
//  SmartV3
//
//  Created by 叩鼎科技 on 2022/12/6.
//  Copyright © 2022 CodingIOT. All rights reserved.
//

import UIKit

class BleWeatherRealtime2: BleWritable {

    /// 时间戳，秒数/
    var mTime: Int = 0
    /// 城市名
    var mCityName: String = ""
    var mWeather: BleWeather2?
    
    // "mTime":1675926000,"mCityName":"","mWeather":{}
    static let NAME_LENGTH = 66
    private let ITEM_LENGTH = BleTime.ITEM_LENGTH + NAME_LENGTH + BleWeather2.ITEM_LENGTH
    override var mLengthToWrite: Int {
        return ITEM_LENGTH
    }
    
    init(time: Int, cityName: String = "", weather: BleWeather2? = nil) {
        super.init()
        mTime = time
        mCityName = cityName
        mWeather = weather
    }
    
    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mTime = try container.decode(Int.self, forKey: .mTime)
        mCityName = try container.decode(String.self, forKey: .mCityName)
        mWeather = try container.decode(BleWeather2.self, forKey: .mWeather2)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mTime, forKey: .mTime)
        try container.encode(mCityName, forKey: .mCityName)
        try container.encode(mWeather, forKey: .mWeather2)
    }
    
    private enum CodingKeys: String, CodingKey {
        case mTime, mCityName, mWeather2
    }
    
    override func encode() {
        super.encode()
        writeObject(BleTime.ofLocal(mTime))
        writeStringWithFix(mCityName, BleWeatherRealtime2.NAME_LENGTH)
        writeObject(mWeather)
    }
    
    override func decode() {
        super.decode()
        let bleTime: BleTime = readObject(BleTime.ITEM_LENGTH)
        mTime = bleTime.timeIntervalSince1970ByLocal()
        mCityName = readString(BleWeatherRealtime2.NAME_LENGTH)
        mWeather = readObject(BleWeather2.ITEM_LENGTH)
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleWeatherRealtime2{
        
        let newModel = BleWeatherRealtime2()
        if dic.keys.isEmpty {
            return newModel
        }
        newModel.mTime = dic["mTime"] as? Int ?? 0
        newModel.mCityName = dic["mCityName"] as? String ?? ""
        
        let dic1 : [String:Any] = dic["mWeather"] as? [String:Any] ?? [:]
        newModel.mWeather = BleWeather2().dictionaryToObjct(dic1)
                
        return newModel
    }
    

    override var description: String {
        let tempTime = BleTime.ofLocal(mTime)
        return "BleWeatherRealtime2(mTime=\(tempTime), mCityName=\(mCityName), mWeather=\(String(describing: mWeather)))"
    }
}
