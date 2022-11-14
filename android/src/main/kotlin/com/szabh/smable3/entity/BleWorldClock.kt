package com.szabh.smable3.entity

data class BleWorldClock(
    var isLocal: Int = 0,
    var mTimeZoneOffset: Int = 0, //15分钟
    var reversed: Int = 0,//保留
    var mCityName: String = ""
) : BleIdObject() {
    override val mLengthToWrite: Int
        get() = ITEM_LENGTH

    override fun encode() {
        super.encode()
        writeIntN(isLocal, 1)
        writeIntN(mId, 7)
        writeInt8(mTimeZoneOffset)
        writeInt16(reversed)
        writeStringWithFix(mCityName, NAME_MAX_LENGTH, Charsets.UTF_16LE)
        writeInt16(0)//补0
    }

    override fun decode() {
        super.decode()
        isLocal = readIntN(1).toInt()
        mId = readIntN(7).toInt()
        mTimeZoneOffset = readInt8().toInt()
        reversed = readInt16().toInt()
        mCityName = readString(NAME_MAX_LENGTH, Charsets.UTF_16LE)
    }

    override fun toString(): String {
        return "BleWorldClock(mId=$mId, isLocal=$isLocal, mTimeZoneOffset=$mTimeZoneOffset, mCityName='$mCityName')"
    }

    companion object {
        private const val NAME_MAX_LENGTH = 31 * 2

        const val ITEM_LENGTH = NAME_MAX_LENGTH + 6
    }
}
