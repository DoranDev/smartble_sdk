package com.szabh.smable3.entity

import java.nio.ByteOrder

data class BleStock(
    var mColorType: Int = 0, //颜色类型 [COLOR_TYPE_0] [COLOR_TYPE_1]
    var mStockCode: String = "", // 股票代码
    var mSharePrice: Float = 0f, // 股价
    var mNetChangePoint: Float = 0f, // 涨跌点数
    var mNetChangePercent: Float = 0f, // 涨跌百分比
    var mMarketCapitalization: Float = 0f, // 市值
) : BleIdObject() {
    override val mLengthToWrite: Int
        get() = ITEM_LENGTH

    override fun encode() {
        super.encode()
        writeInt8(mId)
        writeInt8(mColorType)
        writeIntN(getNumberOfDecimalPlaces(mNetChangePoint),4) // 涨跌点数小数点数
        writeIntN(getNumberOfDecimalPlaces(mSharePrice),4) //股价小数点数
        writeIntN(0,4) //保留
        writeIntN(getNumberOfDecimalPlaces(mNetChangePercent),4) //涨跌百分比小数点数
        writeStringWithFix(mStockCode, NAME_LENGTH, Charsets.UTF_16LE)
        writeInt16(0)//补0
        writeFloat(mSharePrice, ByteOrder.LITTLE_ENDIAN)
        writeFloat(mNetChangePoint, ByteOrder.LITTLE_ENDIAN)
        writeFloat(mNetChangePercent, ByteOrder.LITTLE_ENDIAN)
        writeFloat(mMarketCapitalization, ByteOrder.LITTLE_ENDIAN)
    }

    override fun decode() {
        super.decode()
        mId = readUInt8().toInt()
        mColorType = readUInt8().toInt()
        readInt16().toInt()//保留
        mStockCode = readString(NAME_LENGTH, Charsets.UTF_16LE)
        readInt16().toInt()
        mSharePrice = readFloat(ByteOrder.LITTLE_ENDIAN)
        mNetChangePoint = readFloat(ByteOrder.LITTLE_ENDIAN)
        mNetChangePercent = readFloat(ByteOrder.LITTLE_ENDIAN)
        mMarketCapitalization = readFloat(ByteOrder.LITTLE_ENDIAN)
    }

    private fun getNumberOfDecimalPlaces(value: Float): Int {
        val index = value.toString().indexOf('.')
        if (index < 0) {
            return 0
        }
        return value.toString().length - 1 - index
    }

    override fun toString(): String {
        return "BleStock(mId=$mId, [${getNumberOfDecimalPlaces(mSharePrice)}, ${getNumberOfDecimalPlaces(mNetChangePoint)}, ${getNumberOfDecimalPlaces(mNetChangePercent)}], " +
                "colorType=$mColorType, mStockCode=$mStockCode, mSharePrice=$mSharePrice, mNetChangePoint=$mNetChangePoint" +
            ", mNetChangePercent=$mNetChangePercent, mMarketCapitalization=$mMarketCapitalization)"
    }

    companion object {
        private const val NAME_LENGTH = 31 * 2

        const val ITEM_LENGTH = NAME_LENGTH + 22

        const val COLOR_TYPE_0 = 0 //红色涨绿色跌
        const val COLOR_TYPE_1 = 1 //绿色涨红色跌
    }
}