//
//  BleStock.swift
//  SmartV3
//
//  Created by SMA-IOS on 2022/7/14.
//  Copyright © 2022 KingHuang. All rights reserved.
//

import Foundation

class BleStock: BleIdObject {
    static let BLE_COMPANY_NAME_MAX  = 62 //以0结尾,缩减2位
    static let TITLE_LENGTH = 84
    
    override var mLengthToWrite: Int {
        BleStock.TITLE_LENGTH
    }

    
    /// 颜色类型： 0：红色涨绿色跌  1：绿色涨红色跌
    var mColorType : Int = 0 //颜色类型[COLOR_TYPE_0] [COLOR_TYPE_0]
    var mStockCode : String = ""//股票代码
    var mSharePrice : Float = 0.0  // 股价
    var mNetChangePoint : Float = 0.0  // 涨跌点数
    var mNetChangePercent : Float = 0.0  // 涨跌百分比
    var mMarketCapitalization : Float = 0.0  // 市值

    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }

    init( _ companyName: String = "",_ sharePrice:Float = 0.0,_ netChangePoint:Float = 0.0,_ netChangePercent:Float = 0.0,_ marketCapitalization:Float = 0.0) {
        super.init()
        mStockCode = companyName
        mSharePrice = sharePrice
        mNetChangePoint = netChangePoint
        mNetChangePercent = netChangePercent
        mMarketCapitalization = marketCapitalization
    }

    override func encode() {
        super.encode()
        writeInt8(mId)
        writeInt8(mColorType)
        writeIntN(getNumberOfDecimalPlaces(mNetChangePoint), 4)//涨跌点数小数点
        writeIntN(getNumberOfDecimalPlaces(mSharePrice), 4)//股价小数点数
        writeIntN(0, 4)//保留
        writeIntN(getNumberOfDecimalPlaces(mNetChangePercent), 4)//涨跌百分比小数点数
        writeStringWithFix(mStockCode, BleStock.BLE_COMPANY_NAME_MAX,.utf16LittleEndian)
        writeInt16(0)//string 补0结尾
        writeFloat(mSharePrice,.LITTLE_ENDIAN)
        writeFloat(mNetChangePoint,.LITTLE_ENDIAN)
        writeFloat(mNetChangePercent,.LITTLE_ENDIAN)
        writeFloat(mMarketCapitalization,.LITTLE_ENDIAN)
    }

    override func decode() {
        super.decode()
        mId = Int(readUInt8())
        mColorType = Int(readUInt8())
        _ = readInt16()
        mStockCode = readString(BleStock.BLE_COMPANY_NAME_MAX,.utf16LittleEndian)
        _ = readInt16()
        mSharePrice = readFloat(.LITTLE_ENDIAN)
        mNetChangePoint = readFloat(.LITTLE_ENDIAN)
        mNetChangePercent = readFloat(.LITTLE_ENDIAN)
        mMarketCapitalization = readFloat(.LITTLE_ENDIAN)
    }
    
    private func getNumberOfDecimalPlaces(_ value:Float)->Int{
        let vString = String.init(value)
        let range:Range = vString.range(of: ".")!
        let location = vString.distance(from: vString.startIndex, to: range.upperBound)
        let newItem = vString.suffix(vString.count-location)//截取包含小数点string
        bleLog("getNumberOfDecimalPlaces - \(newItem)")
        return newItem.count-1
    }

    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mId = try container.decode(Int.self, forKey: .mId)
        mColorType = try container.decode(Int.self, forKey: .mColorType)
        mStockCode = try container.decode(String.self, forKey: .mStockCode)
        mSharePrice = try container.decode(Float.self, forKey: .mSharePrice)
        mNetChangePoint = try container.decode(Float.self, forKey: .mNetChangePoint)
        mNetChangePercent = try container.decode(Float.self, forKey: .mNetChangePercent)
        mMarketCapitalization = try container.decode(Float.self, forKey: .mMarketCapitalization)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mId, forKey: .mId)
        try container.encode(mColorType, forKey: .mColorType)
        try container.encode(mStockCode, forKey: .mStockCode)
        try container.encode(mSharePrice, forKey: .mSharePrice)
        try container.encode(mNetChangePoint, forKey: .mNetChangePoint)
        try container.encode(mNetChangePercent, forKey: .mNetChangePercent)
        try container.encode(mMarketCapitalization, forKey: .mMarketCapitalization)
    }

    private enum CodingKeys: String, CodingKey {
        case mId, mColorType, mStockCode, mSharePrice, mNetChangePoint,mNetChangePercent,mMarketCapitalization
    }

    override var description: String {
        "BleStock(mId: \(mId), mColorType:\(mColorType), mStockCode: \(mStockCode), mSharePrice: \(mSharePrice), mNetChangePoint: \(mNetChangePoint), mNetChangePercent: \(mNetChangePercent), mMarketCapitalization: \(mMarketCapitalization)"
    }
    
    func toDictionary()->[String:Any]{
        let dic : [String : Any] = ["mId":mId,
                                    "mColorType":mColorType,
                                    "mStockCode":mStockCode,
                                    "mSharePrice":mSharePrice,
                                    "mNetChangePoint":mNetChangePoint,
                                    "mNetChangePercent":mNetChangePercent,
                                    "mMarketCapitalization":mMarketCapitalization]
        return dic
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleStock{

        let newModel = BleStock()
        if dic.keys.count<1{
            return newModel
        }
        newModel.mId = dic["mId"] as? Int ?? 0
        newModel.mColorType = dic["mColorType"] as? Int ?? 0
        newModel.mStockCode = dic["mStockCode"] as? String ?? ""
        newModel.mSharePrice = dic["mLocal"] as? Float ?? 0.0
        newModel.mNetChangePoint = dic["mNetChangePoint"] as? Float ?? 0.0
        newModel.mNetChangePercent = dic["mNetChangePercent"] as? Float ?? 0.0
        newModel.mMarketCapitalization = dic["mMarketCapitalization"] as? Float ?? 0.0
        return newModel
    }
}
