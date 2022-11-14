package com.szabh.smable3.watchface

/**
 * 表盘元素
 */
data class Element(
    val type: Int = 0,
    val w: Int = 0,
    val h: Int = 0,
    val gravity: Int = 0,
    val ignoreBlack: Int = 0,
    val x: Int = 0,
    val y: Int = 0,
    val bottomOffset: Int = 0,
    val leftOffset: Int = 0,
    val imageBuffers: Array<ByteArray> = arrayOf()
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as Element

        if (type != other.type) return false
        if (w != other.w) return false
        if (h != other.h) return false
        if (gravity != other.gravity) return false
        if (ignoreBlack != other.ignoreBlack) return false
        if (x != other.x) return false
        if (y != other.y) return false
        if (bottomOffset != other.bottomOffset) return false
        if (leftOffset != other.leftOffset) return false
        if (!imageBuffers.contentDeepEquals(other.imageBuffers)) return false

        return true
    }

    override fun hashCode(): Int {
        var result = type
        result = 31 * result + w
        result = 31 * result + h
        result = 31 * result + gravity
        result = 31 * result + ignoreBlack
        result = 31 * result + x
        result = 31 * result + y
        result = 31 * result + bottomOffset
        result = 31 * result + leftOffset
        result = 31 * result + imageBuffers.contentDeepHashCode()
        return result
    }
}