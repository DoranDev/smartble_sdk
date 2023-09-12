//
// Created by Best Mafen on 2019/9/26.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

class BleLanguagePackVersion: BleReadable {
    var mVersion = "0.0.0"
    var mLanguageCode = Languages.DEFAULT_CODE

    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }

    override func decode() {
        super.decode()
        if let data = mData {
            if data.count == 4 {
                mVersion = data[0...2].map({
                    if $0 > 9 {
                        return "0"
                    } else {
                        return "\($0)"
                    }
                }).joined(separator: ".")
                mLanguageCode = Int(data[3])
            }
        }
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mVersion = try container.decode(String.self, forKey: .mVersion)
        mLanguageCode = try container.decode(Int.self, forKey: .mLanguageCode)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mVersion, forKey: .mVersion)
        try container.encode(mLanguageCode, forKey: .mLanguageCode)
    }

    private enum CodingKeys: String, CodingKey {
        case mVersion, mLanguageCode
    }

    override var description: String {
        "BleLanguagePackVersion(mVersion: \(mVersion), mLanguageCode: \(mLanguageCode))"
    }
    
    func toDictionary()->[String:Any]{
        let dic : [String : Any] = ["mVersion":mVersion,
                                    "mLanguageCode":mLanguageCode]
        return dic
    }
    func dictionaryToObjct(_ dic:[String:Any]) ->BleLanguagePackVersion{
        let newModel = BleLanguagePackVersion()
        if dic.keys.count<1{
            return newModel
        }
        newModel.mVersion = dic["mVersion"] as? String ?? ""
        newModel.mLanguageCode = dic["mLanguageCode"] as? Int ?? 0
        return newModel
    }
}
