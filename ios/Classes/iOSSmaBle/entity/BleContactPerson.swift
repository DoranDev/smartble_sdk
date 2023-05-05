//
//  BleContactPerson.swift
//  SmartV3
//
//  Created by SMA on 2020/9/2.
//  Copyright © 2020 KingHuang. All rights reserved.
//

import Foundation

class BleContactPerson: BleWritable {

    static let ITEM_LENGTH = 40

    override var mLengthToWrite: Int {
        BleContactPerson.ITEM_LENGTH
    }
    var userName = ""
    var userPhone = ""
    
    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }
    
    init(username: String, userphone: String) {
        super.init()
        userName = username
        userPhone = userphone
    }
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userName = try container.decode(String.self, forKey: .userName)
        userPhone = try container.decode(String.self, forKey: .userPhone)
    }
    
    override func encode() {
        super.encode()
        writeStringWithFix(userName, 24)
        writeStringWithFix(userPhone, 16)
    }
        
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userName, forKey: .userName)
        try container.encode(userPhone, forKey: .userPhone)

    }

    private enum CodingKeys: String, CodingKey {
        case userName, userPhone
    }
    
    override var description: String {
        "BleContactPerson(userName: \(userName), userPhone: \(userPhone))"
    }
    
    func toDictionary()->[String:Any]{
        let dic : [String : Any] = ["userName":userName,
                                    "userPhone":userPhone]
        return dic
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleContactPerson{

        let newModel = BleContactPerson()
        if dic.keys.count<1{
            return newModel
        }
        newModel.userName = dic["userName"] as? String ?? ""
        newModel.userPhone = dic["userPhone"] as? String ?? ""
        return newModel
    }
}
