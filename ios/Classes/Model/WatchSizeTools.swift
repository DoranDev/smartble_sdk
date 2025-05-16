//
//  WatchSizeTools.swift
//  blesdk3
//
//  Created by 叩鼎科技 on 2023/5/10.
//  Copyright © 2023 szabh. All rights reserved.
//

import UIKit
import SmartWatchCodingBleKit



public extension UIColor {
    /// Constructing color from hex string
    ///
    /// - Parameter hex: A hex string, can either contain # or not
    convenience init(hex string: String) {
        var hex = string.hasPrefix("#")
        ? String(string.dropFirst())
        : string
        guard hex.count == 3 || hex.count == 6
        else {
            self.init(white: 1.0, alpha: 0.0)
            return
        }
        if hex.count == 3 {
            for (index, char) in hex.enumerated() {
                hex.insert(char, at: hex.index(hex.startIndex, offsetBy: index * 2))
            }
        }
        
        guard let intCode = Int(hex, radix: 16) else {
            self.init(white: 1.0, alpha: 0.0)
            return
        }
        
        self.init(
            red:   CGFloat((intCode >> 16) & 0xFF) / 255.0,
            green: CGFloat((intCode >> 8) & 0xFF) / 255.0,
            blue:  CGFloat((intCode) & 0xFF) / 255.0, alpha: 1.0)
    }
    
}

let dial_select_color1 = UIColor(hex:"#FFFFFF")
let dial_select_color2 = UIColor(hex:"#04A3FF")
let dial_select_color3 = UIColor(hex:"#04FF4B")
let dial_select_color4 = UIColor(hex:"#CD04FF")
let dial_select_color5 = UIColor(hex:"#FF0468")
let dial_select_color6 = UIColor(hex:"#FFC704")
let dial_select_color7 = UIColor(hex:"#000000")
let dial_select_CollCell = UIColor(hex:"#171944")

func getColorNumber(_ idColor:UIColor) -> Int {
    var colorNum = 0
    if idColor == dial_select_color1{
        colorNum = 0
    }else if idColor == dial_select_color2{
        colorNum = 1
    }else if idColor == dial_select_color3{
        colorNum = 2
    }else if idColor == dial_select_color4{
        colorNum = 3
    }else if idColor == dial_select_color5{
        colorNum = 4
    }else if idColor == dial_select_color6{
        colorNum = 5
    }else if idColor == dial_select_color7{
        colorNum = 6
    }else{
        colorNum = 0
    }
    return colorNum
}


//标记下标99设备屏幕、背景图尺寸
func getWatchDialBKWidthHeight()->[Int]{
    var width = 240
    var height = 240
    if BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_S2 ||
        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_F2K{
        width = 128
        height = 128
    }else if BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_F12 ||
                BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_AM01{
        width = 368
        height = 448
    }else if BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_V2{
        width = 360
        height = 400
    }else if BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_B9{
        width = 172
        height = 320
    }else if dialCustomIs240_286() {
        width = 240
        height = 286
    }else if dialCustomIs368_448() {
        width = 368
        height = 448
    }else if BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_A8{
        width = 240
        height = 284
    }else if BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_A7{
        width = 240
        height = 286
    }else if dialCustomIs356_400() {
        width = 356
        height = 400
    }else if dialCustomIs360_360() {
        width = 360
        height = 360
    }else if dialCustomIs412_412() {
        width = 412
        height = 412
    } else if dialCustomIs466_466() {
        width = 466
        height = 466
    }else if BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_K18 {
        //let bleName = BleCache.shared.mDeviceInfo?.mBleName ?? ""
        //if bleName == "AW12" {
        width = 320
        height = 320
        //}
    } else if dialCustomIs320_385() {
        // 需要注意, PROTOTYPE_F12Pro 屏幕是 320 X 385屏幕 由于没有资源, 只能使用 320x320
        width = 320
        height = 385
    } else if dialCustomIs410_502() {
        // 需要注意, 410_502 由于没有资源, 只能使用 360x360
        width = 410
        height = 502
    }else if dialCustomIsVenus() {
        width = 390
        height = 450
    }
    return [width,height]
}


/// 获取表略缩图大小
func getThumbnailImageWidthHeight()->[Int]{
    var width = 150
    var height = 150
    if BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_S2 ||
        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_F2K{
        width = 74
        height = 74
    }else if BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_F12 ||
                BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_AM01{
        width = 250
        height = 304
    }else if BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_V2{
        width = 200
        height = 222
    }else if BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_B9{
        width = 110
        height = 204
    }else if dialCustomIs240_286() {
        width = 150
        height = 174
    }else if dialCustomIs368_448() {
        width = 250
        height = 304
    }else if BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_A8 ||
                BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_A7 {
        width = 150
        height = 175
    }else if dialCustomIs356_400() {
        width = 240
        height = 265
    }else if dialCustomIs360_360() { // 360x360
        width = 225
        height = 225
    }else if dialCustomIs412_412() {
        width = 290
        height = 290
    }else if BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_K18 { // 320x320
        //let bleName = BleCache.shared.mDeviceInfo?.mBleName ?? ""
        //if bleName == "AW12" {  // 长按表盘后, 显示出的预览表盘, 修改表盘预览图大小
        width = 200
        height = 200
        //}
    }else if dialCustomIs466_466() { // 466x466
        // 这个表盘和 WATCH_FACE_REALTEK_ROUND_454x454 相差10 可以参考
        width  = 280
        height = 280
    }else if dialCustomIs320_385() {
        // 需要注意, PROTOTYPE_F12Pro 屏幕是 320 X 385屏幕 由于没有资源, 只能使用 320x320
        width = 200
        height = 230
    }else if dialCustomIs410_502() {
        width = 260
        height = 300
    }else if dialCustomIsVenus(){
        width = 250
        height = 288
    }
    return [width,height]
}


func dialCustomIsWristband()->Bool{
    if BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_B9{
        return true
    }
    return false
}

func dialCustomIs128()->Bool{
    var isDial128 = false
    if BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_S2 ||
        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_F2K{
        isDial128 = true
    }
    return isDial128
}

/// 屈: 是否为表盘 320x320 类型表盘设备
func dialCustomIs320_320()->Bool{
    var isDial320 = false
    if BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_K18 {

        isDial320 = true
    }
    return isDial320
}

/// 屈: 是否为表盘 320x385 类型表盘设备
/// 需要注意, PROTOTYPE_F12Pro 屏幕是 320 X 385屏幕 由于没有资源, 只能使用 320x320
/// 需要注意, PROTOTYPE_A8_Ultra_Pro 这个是320x386 由于没有资源, 只能使用 320x320
/// 需要注意, PROTOTYPE_AM11 这个是336 X 480 由于没有资源, 只能使用 320x320
func dialCustomIs320_385()->Bool{

    var isDial = false
    switch BleCache.shared.mPrototype {
    case BleDeviceInfo.PROTOTYPE_F12Pro,
        BleDeviceInfo.PROTOTYPE_A8_Ultra_Pro,
        BleDeviceInfo.PROTOTYPE_AM11:
        isDial = true
    default:
        isDial = false
    }

    return isDial
}

/// 屈: 是否为表盘 240x240 圆形 表盘设备
func dialCustomIs240_240()->Bool{
    var isDial320 = false

    switch BleCache.shared.mPrototype {
    case BleDeviceInfo.PROTOTYPE_FC1:

        isDial320 = true

    default:
        isDial320 = false
    }

    return isDial320
}

/// 屈: 是否为表盘 240 X 284 方形 表盘设备
func dialCustomIs240_284()->Bool{
    var isDia = false
    if BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_A8 {
        isDia = true
    }
    return isDia
}

/// 屈: 是否为表盘 240X286 方形 表盘设备
/// JX621D 240 X 296没资源, 就使用这个了
func dialCustomIs240_286()->Bool{

    var isDia = false
    switch BleCache.shared.mPrototype {
    case BleDeviceInfo.PROTOTYPE_F11,
        BleDeviceInfo.PROTOTYPE_F13A,
        BleDeviceInfo.PROTOTYPE_F13B,
        BleDeviceInfo.PROTOTYPE_A7,
        BleDeviceInfo.PROTOTYPE_FT5,
        BleDeviceInfo.PROTOTYPE_JX621D:

        isDia = true

    default:
        isDia = false
    }
    return isDia
}

/// 屈: 是否为表盘 368 X 448 方形 表盘设备
func dialCustomIs368_448()->Bool{

    var isDia = false
    switch BleCache.shared.mPrototype {
    case BleDeviceInfo.PROTOTYPE_AM01J,
        BleDeviceInfo.PROTOTYPE_AM02J,
        BleDeviceInfo.PROTOTYPE_F12:

        isDia = true

    default:
        isDia = false
    }
    return isDia
}

/// 屈: 是否为表盘 360x360 圆形 表盘设备
func dialCustomIs360_360()->Bool{
    var isDial320 = false

    switch BleCache.shared.mPrototype {
    case BleDeviceInfo.PROTOTYPE_HW01,
        BleDeviceInfo.PROTOTYPE_FC2,
        BleDeviceInfo.PROTOTYPE_V61:

        isDial320 = true

    default:
        isDial320 = false
    }
    return isDial320
}

/// 判断是否为方形屏幕
func isSquareDial() -> Bool {

    // 需要注意, PROTOTYPE_F12Pro 屏幕是 320 X 385屏幕 由于没有资源, 只能使用 320x320
    if dialCustomIs240_284() || dialCustomIs240_286() || dialCustomIs368_448() || dialCustomIs320_385() || dialCustomIs356_400() ||
        dialCustomIsVenus() ||
        dialCustomIs410_502() {

        return true
    } else {
        return false
    }
}

func dialCustomSenderImageFormat()->Bool{
    //true 表示传输协议用PNG false 表示BMP Realtek必须用BMP
    var isImage = true
    if BleCache.shared.mPlatform ==  BleDeviceInfo.PLATFORM_REALTEK{
        isImage = false
    }
    return isImage

}

/// 是否为表盘 412 x412 圆形 表盘设备
func dialCustomIs412_412()->Bool{
    var isDial = false

    switch BleCache.shared.mPrototype {
    case BleDeviceInfo.PROTOTYPE_R16:

        isDial = true

    default:
        isDial = false
    }
    return isDial
}

/// 是否为表盘 466x466 圆形 表盘设备
func dialCustomIs466_466() -> Bool{
    var isDial = false

    switch BleCache.shared.mPrototype {
    case BleDeviceInfo.PROTOTYPE_AM05:

        isDial = true

    default:
        isDial = false
    }
    return isDial
}


/// 是否为表盘 356 X 400 方形 表盘设备
func dialCustomIs356_400() -> Bool{
    var isDial = false

    switch BleCache.shared.mPrototype {
    case BleDeviceInfo.PROTOTYPE_F17:

        isDial = true

    default:
        isDial = false
    }
    return isDial
}

/// 是否为表盘 356 X 400 方形 表盘设备, 2023-01-09 自定义表盘还未有对应的资源文件, 暂时使用360*360
func dialCustomIs410_502() -> Bool{
    var isDial = false

    switch BleCache.shared.mPrototype {
    case BleDeviceInfo.PROTOTYPE_AM08:

        isDial = true

    default:
        isDial = false
    }
    return isDial
}

/// tambah dewe
func dialCustomIsVenus() -> Bool{
    var isDial = false

    switch BleCache.shared.mPrototype {
    case "A9mini":

        isDial = true

    default:
        isDial = false
    }
    return isDial
}



func dialCustomIsRound()->Bool{
    //判断拍照选择图片后是否切成圆形
    var isRound = true
    if BleCache.shared.mWatchFaceType == BleDeviceInfo.WATCH_FACE_320x363 ||
        BleCache.shared.mWatchFaceType == BleDeviceInfo.WATCH_FACE_REALTEK_SQUARE_240x240 ||
        BleCache.shared.mWatchFaceType == BleDeviceInfo.WATCH_FACE_REALTEK ||
        BleCache.shared.mWatchFaceType == BleDeviceInfo.WATCH_FACE_REALTEK_SQUARE_240x280 ||
        BleCache.shared.mWatchFaceType == BleDeviceInfo.WATCH_FACE_REALTEK_SQUARE_240x280_19 ||
        BleCache.shared.mWatchFaceType == BleDeviceInfo.WATCH_FACE_REALTEK_SQUARE_240x280_20 ||
        BleCache.shared.mWatchFaceType == BleDeviceInfo.WATCH_FACE_REALTEK_SQUARE_240x295_21 ||
        BleCache.shared.mWatchFaceType == BleDeviceInfo.WATCH_FACE_REALTEK_SQUARE_240x280_2 ||
        dialCustomIsVenus() ||
        dial99CustomIsRound() == false{
        isRound = false
    }
    return isRound
    
}

//标记位99设备外形判断
func dial99CustomIsRound()->Bool{
    var isRound = true
    if BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_S2 ||
        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_W9 ||
        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_F12 ||
        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_F13A ||
        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_F13B ||
        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_AM01J ||
        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_AM02J ||
        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_A7 ||
        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_A8 ||
        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_F17 ||
        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_AM01 ||
        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_V2 ||
        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_B9 ||
        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_F2K ||
        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_F2R_NEW ||
        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_F1_NEW ||
        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_NY58 ||
        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_FT5 ||
        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_F12Pro ||
        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_AM08 ||
        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_JX621D ||
        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_A8_Ultra_Pro ||
        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_V61 ||
        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_AM11 {
        isRound = false
    }
    return isRound
}
