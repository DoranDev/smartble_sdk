//
//  BleWatchFaceId.swift
//  blesdk3
//
//  Created by SMA-IOS on 2022/5/18.
//  Copyright © 2022 szabh. All rights reserved.
//

import Foundation

class BleWatchFaceId : BleReadable{
    var mIdList : [Int] = []
    static let ITEM_LENGTH = 4
    static let WATCHFACE_ID_INVALID = 0xFFFFFFFF //无效ID
    
    override func decode() {
        super.decode()
        let sizeNum = mData!.count/4
        for _ in 0..<sizeNum{
            mIdList.append(Int(readInt32()))
        }
    }
    
    init( idList: [Int]? = nil) {
        super.init()
        mIdList = idList ?? []
    }
    
    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mIdList = try container.decode([Int].self, forKey: .mIdList)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mIdList, forKey: .mIdList)
    }

    private enum CodingKeys: String, CodingKey {
        case mIdList
    }
    
    override var description: String {
        "BleWatchFaceId(mIdList: \(mIdList))"
    }
    
    func toDictionary()->[String:Any]{
        let dic : [String : Any] = ["mIdList":mIdList]
        return dic
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleWatchFaceId{
        let newModel = BleWatchFaceId()
        if dic.keys.count<1{
            return newModel
        }
        newModel.mIdList = dic["mIdList"] as? [Int] ?? []
        return newModel
    }
}
