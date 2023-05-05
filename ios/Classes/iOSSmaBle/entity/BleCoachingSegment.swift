//
//  BleCoachingSegment.swift
//  SmartV3
//
//  Created by SMA on 2020/3/4.
//  Copyright © 2020 KingHuang. All rights reserved.
//

import Foundation

// 阶段
enum Stage: Int {
    case WARM_UP = 0, GO_FOR = 1, RECOVERY = 2, REST_FOR = 3, COOL_DOWN = 4, OTHER = 0xFF
}

// 完成条件
enum CompletionCondition: Int {
    case DURATION = 0, MANUAL = 1, DURATION_IN_HR_ZONE = 2, HR_ABOVE = 3, HR_BELOW = 4
}

// 心率区间
enum HrZone: Int {
    case LOW = 1, NORMAL = 2, MODERATE = 3, HARD = 4, MAXIMUM = 5
}

enum SegmentActivity: Int {
    case TIMER = 0, RUN = 1, JUMP_JACKS = 2, PUSH_UP = 3, DISTANCE = 4, RUN_FAS = 5,
         WALK = 6, SWIM = 7, BICYCLE = 8, WORKOUT = 9, REST = 10, STRETCH = 11,
         SPINNING = 12, SIT_UP = 15, WARM_UP = 16, COOL_DOWN = 17
}

class BleCoachingSegment: BleWritable {
    static let LENGTH_NAME = 15

    var mCompletionCondition = 0
    var mName = "" // 名称
    var mActivity = 0 // 运动
    var mStage = 0

    // CompletionCondition为DURATION -> 秒数
    // CompletionCondition为MANUAL -> 重复次数
    // CompletionCondition为DURATION_IN_HR_ZONE -> 秒数
    // CompletionCondition为HR_ABOVE或HR_BELOW -> 心率值
    var mCompletionValue = 0

    // 只有在CompletionCondition为DURATION_IN_HR_ZONE时有意义
    var mHrZone = 0

    override var mLengthToWrite: Int {
        BleCoachingSegment.LENGTH_NAME + 6
    }

    required init(_ data: Data? = nil, _ byteOrder: ByteOrder = .BIG_ENDIAN) {
        super.init(data, byteOrder)
    }

    init(_ completionCondition: Int, _ name: String, _ activity: Int, _ state: Int,
         _ completionValue: Int, _ hrZone: Int) {
        super.init()
        mCompletionCondition = completionCondition
        mName = name
        mActivity = activity
        mStage = state
        mCompletionValue = completionValue
        mHrZone = hrZone
    }

    override func encode() {
        super.encode()
        writeInt8(mStage)
        writeStringWithFix(mName, BleCoachingSegment.LENGTH_NAME)
        writeInt8(mActivity)
        writeInt8(mCompletionCondition)
        writeInt16(mCompletionValue)
        writeInt8(mHrZone)
    }

    override func decode() {
        super.decode()
        mStage = Int(readInt8())
        mName = readString(BleCoachingSegment.LENGTH_NAME)
        mActivity = Int(readInt8())
        mCompletionCondition = Int(readInt8())
        mCompletionValue = Int(readInt16())
        mHrZone = Int(readInt8())
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mCompletionCondition = try container.decode(Int.self, forKey: .mCompletionCondition)
        mName = try container.decode(String.self, forKey: .mName)
        mActivity = try container.decode(Int.self, forKey: .mActivity)
        mStage = try container.decode(Int.self, forKey: .mStage)
        mCompletionValue = try container.decode(Int.self, forKey: .mCompletionValue)
        mHrZone = try container.decode(Int.self, forKey: .mHrZone)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mCompletionCondition, forKey: .mCompletionCondition)
        try container.encode(mName, forKey: .mName)
        try container.encode(mActivity, forKey: .mActivity)
        try container.encode(mStage, forKey: .mStage)
        try container.encode(mCompletionValue, forKey: .mCompletionValue)
        try container.encode(mHrZone, forKey: .mHrZone)
    }

    private enum CodingKeys: String, CodingKey {
        case mCompletionCondition, mName, mActivity, mStage, mCompletionValue, mHrZone
    }

    override var description: String {
        "BleCoachingSegment(mCompletionCondition: \(mCompletionCondition), mName: \(mName)"
            + ", mActivity: \(mActivity), mStage: \(mStage), mCompletionValue: \(mCompletionValue)"
            + ", mHrZone: \(mHrZone))"
    }
}
