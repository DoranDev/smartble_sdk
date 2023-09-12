import Foundation

/**手机发送agps前置条件给设备*/
class BleAgpsPrerequisite: BleWritable {
    static let ITEM_LENGTH = 32

    var mLongitude: Float = 0.0  // 经度
    var mLatitude: Float = 0  // 纬度
    var mAltitude: Int = 0 // 海拔，米

    init(_ longitude: Float, _ latitude: Float, _ altitude: Int) {
        super.init()
        mLongitude = longitude
        mLatitude = latitude
        mAltitude = altitude
    }

    override var mLengthToWrite: Int {
        BleAgpsPrerequisite.ITEM_LENGTH
    }

    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }

    required init(from decoder: Decoder) throws {
        super.init()
    }

    override func encode() {
        super.encode()
        writeFloat(mLongitude,.LITTLE_ENDIAN)
        writeFloat(mLatitude,.LITTLE_ENDIAN)
        writeInt16(mAltitude,.LITTLE_ENDIAN)
    }

    override var description: String {
        "BleAgpsPrerequisite(mLongitude: \(mLongitude), mLatitude: \(mLatitude), mAltitude: \(mAltitude))"
    }
    
    func toDictionary()->[String:Any]{
        let dic : [String : Any] = ["mLongitude":mLongitude,
                                    "mLatitude":mLatitude,
                                    "mAltitude":mAltitude]
        return dic
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) ->BleAgpsPrerequisite{
        let newModel = BleAgpsPrerequisite()
        if dic.keys.count<1{
            return newModel
        }
        newModel.mLongitude = dic["mLongitude"] as? Float ?? 0.0
        newModel.mLatitude = dic["mLatitude"] as? Float ?? 0.0
        newModel.mAltitude = dic["mAltitude"] as? Int ?? 0
        return newModel
    }
}
