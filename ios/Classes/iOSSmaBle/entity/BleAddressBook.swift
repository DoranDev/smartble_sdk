//
//  BleAddressBook.swift
//  SmartV3
//
//  Created by SMA on 2020/9/2.
//  Copyright © 2020 KingHuang. All rights reserved.
//

import Foundation

class BleAddressBook: BleWritable {

    override var mLengthToWrite: Int {
        BleContactPerson.ITEM_LENGTH*addBook.count
    }
    var addBook : [BleContactPerson] = []
    
    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }
    
    init(array: [BleContactPerson]) {
        super.init()
        addBook = array
       
    }
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func encode() {
        super.encode()
        writeArray(addBook)
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleAddressBook{
        var array : [BleContactPerson] = []
        let arrayToPerson : Array<[String:Any]> = dic["addressBook"] as! Array<[String:Any]>
        for item in arrayToPerson{
            let person = BleContactPerson().dictionaryToObjct(item)
            array.append(person)
        }
        return BleAddressBook.init(array: array)
    }
}
