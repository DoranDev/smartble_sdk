//
// Created by Best Mafen on 2019/9/26.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

class BleStreamProgress: BleReadable {
    static let ITEM_LENGTH = 9

    var mStatus: Int = 0
    var mErrorCode: Int = 0 // 错误类型，未出错时忽略
    var mTotal: Int = 0
    var mCompleted: Int = 0

    override func decode() {
        super.decode()
        mStatus = Int(readUIntN(4))
        mErrorCode = Int(readUIntN(4))
        mTotal = Int(readInt32())
        mCompleted = Int(readInt32())
    }

    override var description: String {
        "BleStreamProgress(mStatus: \(mStatus), mErrorCode: \(mErrorCode), mTotal: \(mTotal), mCompleted: \(mCompleted))"
    }
    
    func toDictionary()->[String:Any]{
        let dic : [String : Any] = ["mStatus":mStatus,
                                    "mErrorCode":mErrorCode,
                                    "mTotal":mTotal,
                                    "mCompleted":mCompleted]
        return dic
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleStreamProgress{

        let newModel = BleStreamProgress()
        if dic.keys.count<1{
            return newModel
        }
        newModel.mStatus = dic["mStatus"] as? Int ?? 0
        newModel.mErrorCode = dic["mErrorCode"] as? Int ?? 0
        newModel.mTotal = dic["mTotal"] as? Int ?? 0
        newModel.mCompleted = dic["mCompleted"] as? Int ?? 0
        return newModel
    }
}
