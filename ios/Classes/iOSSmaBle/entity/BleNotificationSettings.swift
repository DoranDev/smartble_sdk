//
// Created by Best Mafen on 2019/9/26.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

class BleNotificationSettings: BleWritable {
    static let ITEM_LENGTH = 4

//    static let MIRROR_PHONE = "mirror.phone"
//    static let CALL = "com.apple.mobilephone"
//    static let SMS = "com.apple.MobileSMS"
//    static let EMAIL = "com.apple.mobilemail"
//    static let SKYPE = "com.skype.skype"
//    static let FACEBOOK_MESSENGER = "com.facebook.Messenger"
//    static let WHATS_APP = "net.whatsapp.WhatsApp"
//    static let LINE = "jp.naver.line"
//    static let INSTAGRAM = "com.burbn.instagram"
//    static let KAKAO_TALK = "com.iwilab.KakaoTalk"
//    static let GMAIL = "com.google.Gmail"
//    static let TWITTER = "com.atebits.Tweetie2"
//    static let LINKED_IN = "com.linkedin.LinkedIn"
//    static let SINA_WEIBO = "com.sina.weibo"
//    static let QQ = "com.tencent.mqq"
//    static let WE_CHAT = "com.tencent.xin"

    static let MIRROR_PHONE = "mirror_phone"
    static let CALL = "tel"
    static let SMS = "sms"
    static let EMAIL = "mailto"
    static let SKYPE = "skype"
    static let FACEBOOK_MESSENGER = "fbauth2"
    static let WHATS_APP = "whatsapp"
    static let LINE = "line"
    static let INSTAGRAM = "instagram"
    static let KAKAO_TALK = "kakaolink"
    static let GMAIL = "googlegmail"
    static let TWITTER = "twitter"
    static let LINKED_IN = "linkedin"
    static let SINA_WEIBO = "sinaweibo"
    static let QQ = "mqq"
    static let WE_CHAT = "wechat"
    static let BAND = "bandapp"
    static let TELEGRAM = "telegram"
    static let BETWEEN = "between"
    static let NAVERCAFE = "navercafe"
    static let YOUTUBE = "youtube"
    static let NETFLIX = "nflx"

    // 最初始支持的APP，之后如果有新增app，再BleCache中增加，即修改BleCache.mNotificationBundleIds
    // 计算属性的返回值，这个原始的数组千万不要修改，谢谢
    static let ORIGIN_BUNDLE_IDS = [
        MIRROR_PHONE, CALL, SMS, EMAIL,
        SKYPE, FACEBOOK_MESSENGER, WHATS_APP, LINE,
        INSTAGRAM, KAKAO_TALK, GMAIL, TWITTER,
        LINKED_IN, SINA_WEIBO, QQ, WE_CHAT,
    ]

    static let BIT_MASKS: [String: Int] = [
        MIRROR_PHONE: 1, CALL: 1 << 1, SMS: 1 << 2, EMAIL: 1 << 3,
        SKYPE: 1 << 4, FACEBOOK_MESSENGER: 1 << 5, WHATS_APP: 1 << 6, LINE: 1 << 7,
        INSTAGRAM: 1 << 8, KAKAO_TALK: 1 << 9, GMAIL: 1 << 10, TWITTER: 1 << 11,
        LINKED_IN: 1 << 12, SINA_WEIBO: 1 << 13, QQ: 1 << 14, WE_CHAT: 1 << 15, BAND: 1 << 16,TELEGRAM: 1 << 17,BETWEEN: 1 << 18,NAVERCAFE: 1 << 19,YOUTUBE: 1 << 20,NETFLIX: 1 << 21,
    ]

    override var mLengthToWrite: Int {
        BleNotificationSettings.ITEM_LENGTH
    }

    var mNotificationBits = 0

    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }

    override func encode() {
        super.encode()
        writeInt32(mNotificationBits)
    }

    override func decode() {
        super.decode()
        mNotificationBits = Int(readInt32())
    }

    func isEnabled(_ bundleId: String) -> Bool {
        if let bitMask = BleNotificationSettings.BIT_MASKS[bundleId] {
            return mNotificationBits & bitMask > 0
        }

        return false
    }

    func enable(_ bundleId: String) {
        if let bitMask = BleNotificationSettings.BIT_MASKS[bundleId] {
            mNotificationBits |= bitMask
        }
    }

    func disable(_ bundleId: String) {
        if let bitMask = BleNotificationSettings.BIT_MASKS[bundleId] {
            mNotificationBits &= ~bitMask
        }
    }

    func toggle(_ bundleId: String) {
        if let bitMask = BleNotificationSettings.BIT_MASKS[bundleId] {
            mNotificationBits ^= bitMask
        }
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mNotificationBits = try container.decode(Int.self, forKey: .mNotificationBits)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mNotificationBits, forKey: .mNotificationBits)
    }

    private enum CodingKeys: String, CodingKey {
        case mNotificationBits
    }

    override var description: String {
        var desc = "BleNotificationSettings("
        for (bundleId, _) in BleNotificationSettings.BIT_MASKS {
            desc += "\(bundleId): \(isEnabled(bundleId)), "
        }
        desc.removeLast(2)
        desc += ")"
        return desc
    }
    
    func toDictionary()->[String:Any]{

        return ["mNotificationBits":mNotificationBits]
    }
    
    func dictionaryToObjct(_ dic:[String:Any]) -> BleNotificationSettings{
        let settings : BleNotificationSettings = BleCache.shared.getObjectNotNil(.NOTIFICATION_REMINDER)
        settings.mNotificationBits = dic["mNotificationBits"] as? Int ?? 0
        return settings
    }
}
