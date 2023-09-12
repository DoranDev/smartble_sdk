//
//  BlePhoneGPSSport.swift
//  SmartV3
//
//  Created by SMA on 2020/5/19.
//  Copyright © 2020 KingHuang. All rights reserved.
//

import Foundation
/**手机定位成功返回数据给设备*/
class BlePhoneGPSSport: BleWritable {
    static let ITEM_LENGTH = 16
    
    var locationSpeed:Float = 0.0  //当前速度,单位 米/小时 存储格式uint
    var locationHeight:Int = 0  //当前高度,单位米
    var locationDistance:Float = 0.0 //总距离,单位米
//    var locationAsideOne:Int   = 0 //预留位 1
//    var locationAsideTwo:Float = 0.0 //预留位 2

    init(_ speed:Float,_ height:Int,_ distance:Float,_ asideOne:Int,_ asideTwo:Float) {
        super.init()
        locationSpeed = speed
        locationHeight = height
        locationDistance = distance
//        locationAsideOne = asideOne
//        locationAsideTwo = asideTwo
        
    }
    
    override var mLengthToWrite: Int {
        BlePhoneGPSSport.ITEM_LENGTH
    }
    
    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func encode() {
        super.encode()
        writeFloat(locationSpeed)
        writeFloat(locationDistance)
        writeInt16(locationHeight)

    }

    override func decode() {
        super.decode()
        locationSpeed    = readFloat()
        locationHeight   = Int(readInt16())
        locationDistance = readFloat()
    }
    override var description: String {
        "BlePhoneGPSSport(locationSpeed: \(locationSpeed), locationHeight: \(locationHeight), locationDistance: \(locationDistance))"//, locationAsideOne: \(locationAsideOne), locationAsideTwo: \(locationAsideTwo)
    }
    
    func toDictionary()->[String:Any]{
        let dic : [String : Any] = ["locationSpeed":locationSpeed,
                                    "locationHeight":locationHeight,
                                    "locationDistance":locationDistance]
        return dic
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BlePhoneGPSSport{
        let newModel = BlePhoneGPSSport()
        if dic.keys.count<1{
            return newModel
        }
        newModel.locationSpeed = dic["mInterval"] as? Float ?? 0.0
        newModel.locationHeight = dic["mInterval"] as? Int ?? 0
        newModel.locationDistance = dic["mInterval"] as? Float ?? 0.0
        return newModel
    }
}
