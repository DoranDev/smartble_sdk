//
//  CustomWatchFaceViewModel.swift
//  blesdk3
//
//  Created by 叩鼎科技 on 2023/2/14.
//  Copyright © 2023 szabh. All rights reserved.
//

import UIKit


/// 表盘元素类型
enum WatchElementType {
    case AMPM
    /// 小时
    case HOUR
    /// 分钟
    case MINUTES
    ///  月份
    case MONTH
    ///  天
    case DAY
    ///  天
    case WEAK
    
    /// 日期之间的分割线
    case dateSymbol
    /// 星期之间的分割线
    case weakSymbol
    
    /// 其他元素, 脚步
    case STEP
    /// 其他元素, 心率
    case HEART_RATE
    /// 其他元素, 距离
    case DISTANCE
    /// 其他元素, 卡路里
    case CALORIES
}

class CustomWatchFaceViewModel {
    
    
    private let watchBundlePath = Bundle.main.path(forResource: "CustomWatchFaceAssets", ofType: "bundle")
    private let watchBundle: Bundle!
    
    init() {
        watchBundle = Bundle.init(path: watchBundlePath!)
    }
    
    /// 获取表盘的资源文件, 这个是获取创建的bundle里面的, 需要传递路径, 包含后缀名
    func getWatchBundleResultPNG(filePath: String) -> UIImage? {
        
        var img: UIImage?
        if let path = watchBundle?.path(forResource: filePath, ofType: nil) {
            img = UIImage(contentsOfFile: path)
        }
        
        return img
    }
    
    /// 获取表盘的指针
    func getWatchPointPNG(pHour: String, pMinutes: String, pSeconds: String) -> (isOK: Bool, hourImg: UIImage, minutesImg: UIImage, secondsImg: UIImage) {
        
        // 获取数据是否正常
        //var isOK = false
        var hourImg: UIImage?
        var minutesImg: UIImage?
        var secondsImg: UIImage?
        
        if let path = watchBundle?.path(forResource: pHour, ofType: nil) {
            hourImg = UIImage(contentsOfFile: path)
        }
        if let path = watchBundle?.path(forResource: pMinutes, ofType: nil) {
            minutesImg = UIImage(contentsOfFile: path)
        }
        if let path = watchBundle?.path(forResource: pSeconds, ofType: nil) {
            secondsImg = UIImage(contentsOfFile: path)
        }
        
        if let tempHourImage = hourImg, let tempMinutesImg = minutesImg, let tempSecondsImg = secondsImg {
            return (true, tempHourImage, tempMinutesImg, tempSecondsImg)
        } else {
            return (false, UIImage(), UIImage(), UIImage())
        }
    }
    

    /// 字节对齐, 默认4字节对齐, 有更好的方法, 后续再优化
    func byteAlignment(_ data: Data, _ num: Int = 4) -> Data {
        
        
        // 字节对齐, 还是有其他的解决方法, 我这里暂时这样 首先开辟一块内存空间 byteCount: 当前总的字节大小
        var newByte = data
        var isOk = !(newByte.count  % 4 == 0)
        //print("测试数据, 是否4字节对齐:\(!isOk) 余数:\(newByte.count % 4)")
        
        while isOk {
            
            newByte.append(Data(int8: 0))
            isOk = !(newByte.count % 4 == 0)
            //print("测试数据, 是否4字节对齐:\(!isOk) 余数:\(newByte.count % 4)")
        }
        
        return newByte
    }
    
    
    /// 获取指针的资源, Get a pointer to the resource
    /// - Parameters:
    ///   - number: 颜色索引, 这个需要开发者注意必要取到没有的路径, Color index, this requires developers to pay attention to the path that does not have to be taken
    ///   - isPNG: 是否使用PNG图片资源, Whether to use PNG image resources
    func getPointerImage(_ number: Int, isPNG: Bool, pointerModel: Int) -> (hourRes: WatchElementResult, minRes: WatchElementResult, secRes: WatchElementResult)? {

        // 指针资源的后缀名, 包含. 点
        var assSuffix = ".bmp"
        if isPNG {
            assSuffix = ".png"
        }

        // 获取3个指针的路径
        let kPointRootPath = getImageDeviceType_2() + "time/pointer/pointer\(pointerModel)"
        let pHour = kPointRootPath + "/hour/" + "\(number)" + assSuffix
        let pMinutes = kPointRootPath + "/minute/" + "\(number)" + assSuffix
        let pSeconds = kPointRootPath + "/second/" + "\(number)" + assSuffix

        bleLog(pHour)

        // 获取三个指针的图片
        let pointResGroup = self.getWatchPointPNG(pHour: pHour, pMinutes: pMinutes, pSeconds: pSeconds)
        guard pointResGroup.isOK else {
            bleLog("Failed to obtain dial pointer file x")
            return nil
        }
        
        let hourImg = pointResGroup.hourImg
        let minutesImg = pointResGroup.minutesImg
        let secondsImg = pointResGroup.secondsImg
        
        
        if isPNG {
            
            // 重新排列像素点
            let hourGroup = hourImg.rearrangePixels()
            guard let hourImgData = hourGroup.pixData else {
                bleLog("获取hourImg 像素点失败")
                return nil
            }
            let minutesGroup = minutesImg.rearrangePixels()
            guard let minutesImgData = minutesGroup.pixData else {
                bleLog("获取minutes 像素点失败")
                return nil
            }
            let secondsGroup = secondsImg.rearrangePixels()
            guard let secondsImgData = secondsGroup.pixData else {
                bleLog("获取secondsImg 像素点失败")
                return nil
            }
            
            
            // 赋值
            let hourRawSize = CGSize(width: hourImg.size.width, height: hourImg.size.height)
            let hourSize = CGSize(width: hourGroup.width, height: hourGroup.height)
            //pointerHourBuffer.append(hourImgData)
            //pointerHourImageSize = [UInt32(hourImgData.count)]
            let hourRes = WatchElementResult(rawImageSize: hourRawSize, imageSize: hourSize, imageData: hourImgData, imageCount: 1, imageDataSize: [UInt32(hourImgData.count)])
            
            
            let minRawSize = CGSize(width: minutesImg.size.width, height: minutesImg.size.height)
            let minSize = CGSize(width: minutesGroup.width, height: minutesGroup.height)
            //pointerMinBuffer.append(minutesImgData)
            //pointerMinImageSize = [UInt32(minutesImgData.count)]
            let minRes = WatchElementResult(rawImageSize: minRawSize, imageSize: minSize, imageData: minutesImgData, imageCount: 1, imageDataSize: [UInt32(minutesImgData.count)])
            
            
            let secRawSize = CGSize(width: secondsImg.size.width, height: secondsImg.size.height)
            let secSize = CGSize(width: secondsGroup.width, height: secondsGroup.height)
            //pointerBuffer.append(secondsImgData)
            //pointerImageSize = [UInt32(secondsImgData.count)]
            let secRes = WatchElementResult(rawImageSize: secRawSize, imageSize: secSize, imageData: secondsImgData, imageCount: 1, imageDataSize: [UInt32(secondsImgData.count)])
            
            return (hourRes: hourRes, minRes: minRes, secRes: secRes)
        } else {
            
            let hourImgData = hourImg.getImagePathToData(watchBundle: self.watchBundle, imgPath: pHour)
            let minutesImgData = minutesImg.getImagePathToData(watchBundle: self.watchBundle, imgPath: pMinutes)
            let secondsImgData = secondsImg.getImagePathToData(watchBundle: self.watchBundle, imgPath: pSeconds)
            
            // 赋值
            let hourRawSize = CGSize(width: hourImg.size.width, height: hourImg.size.height)
            //let hourSize = CGSize(width: hourImg.width, height: hourImg.height)
            let hourRes = WatchElementResult(rawImageSize: hourRawSize, imageSize: hourRawSize, imageData: hourImgData, imageCount: 1, imageDataSize: [UInt32(hourImgData.count)])
            
            
            let minRawSize = CGSize(width: minutesImg.size.width, height: minutesImg.size.height)
            //let minSize = CGSize(width: minutesGroup.width, height: minutesGroup.height)
            let minRes = WatchElementResult(rawImageSize: minRawSize, imageSize: minRawSize, imageData: minutesImgData, imageCount: 1, imageDataSize: [UInt32(minutesImgData.count)])
            
            
            let secRawSize = CGSize(width: secondsImg.size.width, height: secondsImg.size.height)
            //let secSize = CGSize(width: secondsGroup.width, height: secondsGroup.height)
            let secRes = WatchElementResult(rawImageSize: secRawSize, imageSize: secRawSize, imageData: secondsImgData, imageCount: 1, imageDataSize: [UInt32(secondsImgData.count)])
            
            return (hourRes: hourRes, minRes: minRes, secRes: secRes)
        }
    }
    
    
    
    /// 根据表盘类型, 返回处理后的图片信息
    /// According to the dial type, return the processed image information
    /// - Parameters:
    ///   - type: 表盘元素类型
    ///   - isSupp2D: 是否支持2D, Whether to support 2D
    ///   - colorNum: 颜色索引
    /// - Returns: WatchElementResult
    func getImageBufferArray(_ type: WatchElementType, _ isSupp2D: Bool, _ colorNum: Int) -> WatchElementResult {
        
        let imageType = "png"
        // 获取图片路径
        let imageArray = self.identifyItemsColor(type, colorNum)
        
        if type == .AMPM {
            
            var ampmImgSize = CGSize(width: 0, height: 0)
            var ampmBuffer = Data()
            var ampmImageDataSize = [UInt32]()
            for pngPath in imageArray {
                
                let path = watchBundle?.path(forResource: pngPath, ofType: imageType)
                let newImage = UIImage(contentsOfFile: path!)
                
                #warning("To convert the image format, it is necessary to distinguish whether it supports 2D")
                // 根据是否支持2D, 转换不同的图片格式
                // Depending on whether 2D is supported, convert different image formats
                var imageData = Data()
                if isSupp2D {
                    let pixData = ImageConverTools.getImgWith(newImage!, isAlpha: true)
                    imageData = self.byteAlignment(pixData)
                } else {
                    // 安全校验 security check
                    if let pixData = newImage?.rearrangePixels(1.0).pixData {
                        imageData = pixData
                    }
                }
                
                ampmImgSize = CGSize(width: newImage!.size.width, height: newImage!.size.height)
                ampmBuffer.append(imageData)
                ampmImageDataSize.append(UInt32(imageData.count))
            }
            return WatchElementResult(rawImageSize: CGSize(width: 0, height: 0), imageSize: ampmImgSize, imageData: ampmBuffer, imageCount: UInt8(imageArray.count), imageDataSize: ampmImageDataSize)
        } else {
         
            var hourImgSize = CGSize(width: 0, height: 0)
            var hourBuffer = Data()
            var hourImageDataSize = [UInt32]()
            for pngPath in imageArray {
                
                let path = watchBundle?.path(forResource: pngPath, ofType: imageType)
                let newImage = UIImage(contentsOfFile: path!)
                
                #warning("To convert the image format, it is necessary to distinguish whether it supports 2D")
                // 根据是否支持2D, 转换不同的图片格式
                // Depending on whether 2D is supported, convert different image formats
                var imageData = Data()
                if isSupp2D {
                    let pixData = ImageConverTools.getImgWith(newImage!, isAlpha: true)
                    imageData = self.byteAlignment(pixData)
                } else {
                    // 安全校验 security check
                    if let pixData = newImage?.rearrangePixels(1.0).pixData {
                        imageData = pixData
                    }
                }
                
                hourImgSize = CGSize(width: newImage!.size.width, height: newImage!.size.height)
                hourBuffer.append(imageData)
                hourImageDataSize.append(UInt32(imageData.count))
            }
            return WatchElementResult(rawImageSize: CGSize(width: 0, height: 0), imageSize: hourImgSize, imageData: hourBuffer, imageCount: UInt8(imageArray.count), imageDataSize: hourImageDataSize)
        }
    }
    
    private func identifyItemsColor(_ type: WatchElementType, _ colorNum: Int) -> [String] {

        var imagArray = [String]()
        
        if type == .AMPM {
            imagArray.append(getImageDeviceType_2() + "time/digital/" + "\(colorNum)/" + "am_pm/am")
            imagArray.append(getImageDeviceType_2() + "time/digital/" + "\(colorNum)/" + "am_pm/pm")
        } else if type == .HOUR || type == .MINUTES {
            
            // 小时和分钟, 应该有10个图片, 0到9
            for index in 0..<10 {
                imagArray.append(getImageDeviceType_2() + "time/digital/" + "\(colorNum)/" + "hour_minute/" + "\(index)")
            }
        } else if type == .MONTH || type == .DAY {
            // 日期, 应该有10个图片, 0到9
            for index in 0..<10 {
                imagArray.append(getImageDeviceType_2() + "time/digital/" + "\(colorNum)/" + "date/" + "\(index)")
            }
        } else if type == .WEAK {
            // 星期, 应该有7个图片, 周一到周末
            for index in 0..<7 {
                imagArray.append(getImageDeviceType_2() + "time/digital/" + "\(colorNum)/" + "week/" + "\(index)")
            }
        } else if type == .dateSymbol {
            // 日期之间的分割线 1张图片即可
            imagArray.append(getImageDeviceType_2() + "time/digital/" + "\(colorNum)/" + "hour_minute/symbol")
        } else if type == .weakSymbol {
            // 星期之间的分割线 1张图片即可
            imagArray.append(getImageDeviceType_2() + "time/digital/" + "\(colorNum)/" + "date/symbol")
        } else if type == .STEP || type == .HEART_RATE || type == .CALORIES {
            // 其他元素, 脚步, 心率, 卡路里这三个元素使用的图片一样, 数量应该有10个图片, 0到9的数字
            for index in 0..<10 {
                imagArray.append(getImageDeviceType_2() + "value/" + "\(colorNum)/" + "\(index)")
            }
        } else if type == .DISTANCE {
            // 其他元素, 距离这个元素特殊, 需要使用的图片数量应该有11个图片, 0到9的数字, 和一个点
            for index in 0..<11 {
                imagArray.append(getImageDeviceType_2() + "value/" + "\(colorNum)/" + "\(index)")
            }
        }

        return imagArray
    }
    
    
    /// 不支持2D加速设备需要使用BMP图片资源
    func getImageBmpBufferArray(_ type: WatchElementType, _ colorNum: Int) -> WatchElementResult {
        
        let imageType = "bmp"
        // 获取图片路径
        let imageArray = self.identifyItemsColor(type, colorNum)
        
        if type == .AMPM {
            
            var ampmImgSize = CGSize(width: 0, height: 0)
            var ampmBuffer = Data()
            var ampmImageDataSize = [UInt32]()
            for bmpPath in imageArray {
                
                let path = watchBundle?.path(forResource: bmpPath, ofType: imageType)
                let newImage = UIImage(contentsOfFile: path!)
                
                // 转换图片
                let imageData = self.getImagePathToData(imagePath: path!, ofType: imageType)
                
                ampmImgSize = CGSize(width: newImage!.size.width, height: newImage!.size.height)
                ampmBuffer.append(imageData)
                ampmImageDataSize.append(UInt32(imageData.count))
            }
            
            return WatchElementResult(rawImageSize: CGSize(width: 0, height: 0), imageSize: ampmImgSize, imageData: ampmBuffer, imageCount: UInt8(imageArray.count), imageDataSize: ampmImageDataSize)
        } else {
         
            var hourImgSize = CGSize(width: 0, height: 0)
            var hourBuffer = Data()
            var hourImageDataSize = [UInt32]()
            for pngPath in imageArray {
                
                let path = watchBundle?.path(forResource: pngPath, ofType: imageType)
                let newImage = UIImage(contentsOfFile: path!)
                
                // 转换图片
                let imageData = self.getImagePathToData(imagePath: path!, ofType: imageType)
                
                hourImgSize = CGSize(width: newImage!.size.width, height: newImage!.size.height)
                hourBuffer.append(imageData)
                hourImageDataSize.append(UInt32(imageData.count))
            }
            return WatchElementResult(rawImageSize: CGSize(width: 0, height: 0), imageSize: hourImgSize, imageData: hourBuffer, imageCount: UInt8(imageArray.count), imageDataSize: hourImageDataSize)
        }
    }
    
    private func getImagePathToData(imagePath: String, ofType:String)-> Data{

        var newData :Data = Data()
        if ofType.elementsEqual("bmp"){
            //bmp图片特殊处理方式
            let newImage = UIImage(contentsOfFile: imagePath)//用于计算图片宽度
            let bmpWidth: Int = Int(newImage!.size.width)  //图片宽度
            let bitCount: Int = 16 //位深度，可为8，16，24，32
            let isReverseRows  = false  //是否反转行数据，就是将第一行置换为最后一行
            let rowSize: Int = (bitCount * bmpWidth + 31) / 32 * 4
            var offset = 0
            if !(bmpWidth % 2 == 0){
                offset = 2;
            }
            var image16 = NSData.init(contentsOfFile: imagePath)! as Data
            //删除BMP头部信息
            let headerInfoSize: Int = Int(image16[10]) //头部信息长度
            for _ in 0..<headerInfoSize{
                image16.remove(at: 0)
            }
            //判断单、双数，单数要减去无用字节
            let dataCount :Int = image16.count/rowSize
            let tmpNewData :NSMutableArray = NSMutableArray()
            let imageByte : [UInt8] = [UInt8] (image16)
            for index in 0..<dataCount{
                //截取每一行数据
                var tmpData :Data = Data()
                for rowIndex in 0..<(rowSize - offset) {
                    tmpData.append(imageByte[index * rowSize + rowIndex])
                }
                tmpNewData.add(tmpData)
            }
            //将获得的行数据反转
            image16.removeAll()
            for index in 0..<tmpNewData.count {
                var dataIndex = index
                if !isReverseRows {//需要反转则重置下标
                    dataIndex = tmpNewData.count-1-index
                }
                let data : Data = tmpNewData.object(at:dataIndex) as! Data
                image16.append(data)
            }
            //小端序修改为大端序
            var index = 0
            newData.removeAll()
            while index<image16.count{
                let item1 = image16[index]
                let item2 = image16[index+1]
                newData.append(item2)
                newData.append(item1)
                index += 2
            }
            return newData
        }else{
            let newImage = UIImage(contentsOfFile: imagePath)
            newData = newImage!.pngData()!
        }
        return newData
    }
    
    func getImageDeviceType()-> String{
        var imageSize = "device_"
        switch BleCache.shared.mWatchFaceType {
        case BleDeviceInfo.WATCH_FACE_REALTEK_ROUND_360x360:
            imageSize = "device360_"
            break
        case BleDeviceInfo.WATCH_FACE_320x363:
            imageSize = "device6_"
            break
        case BleDeviceInfo.WATCH_FACE_REALTEK_ROUND_454x454:
            imageSize = "device454_"
            break
        case BleDeviceInfo.WATCH_FACE_SERVER: // 99, 这里代表自定义表盘的哪些判断
            if dialCustomIs128(){
                imageSize = "device128_"
            }else if BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_F12 ||
                        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_F17 ||
                        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_HW01 ||
                        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_AM01J ||
                        BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_V2 ||
                        dialCustomIs360_360() || dialCustomIs412_412() ||
                        dialCustomIs368_448() ||
                        dialCustomIs356_400() ||
                        dialCustomIs410_502() {
                imageSize = "device360_"
            }else if dialCustomIs320_320() || dialCustomIs320_385() {
                // 需要注意, PROTOTYPE_F12Pro 屏幕是 320 X 385屏幕 由于没有资源, 只能使用 320x320
                imageSize = "device320_"
            } else if dialCustomIs466_466() {
                // 这个和 WATCH_FACE_REALTEK_ROUND_454x454 相差10 可以参考
                imageSize = "device454_"
            }else if dialCustomIsWristband(){
                imageSize = "deviceB9_172_"
            }else if BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_F13{
                imageSize = "device_"
            }
            break
        default:
            imageSize = "device_"
        }
        return imageSize
    }
    
    /// 根据设备类型, 获取指定的图片资源
    private func getImageDeviceType_2()-> String{
        
        var imageSize = "dial_customize_240/"
        switch BleCache.shared.mWatchFaceType {
            
        case BleDeviceInfo.WATCH_FACE_REALTEK_ROUND_360x360:
            imageSize = "dial_customize_360/"
            break
        case BleDeviceInfo.WATCH_FACE_320x363:
            imageSize = "dial_customize_320/"
            break
        case BleDeviceInfo.WATCH_FACE_REALTEK_ROUND_454x454:
            imageSize = "dial_customize_454/"
            break
        case BleDeviceInfo.WATCH_FACE_SERVER: // 99, 这里代表自定义表盘的哪些判断
            
            if BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_F12 ||
                BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_V2 ||
                dialCustomIs360_360() || dialCustomIs412_412() || dialCustomIs368_448() ||
                dialCustomIs356_400() || dialCustomIs410_502() {
                
                imageSize = "dial_customize_360/"  // 已经更改, 支持2D表盘的路径
            } else if dialCustomIs240_286() {
                imageSize = "dial_customize_240/"
            }else if dialCustomIs320_320() || dialCustomIs320_385() {
                // 需要注意, PROTOTYPE_F12Pro 屏幕是 320 X 385屏幕 由于没有资源, 只能使用 320x320
                imageSize = "dial_customize_320/"  // 已经更改, 支持2D表盘的路径
            } else if dialCustomIs466_466() {
                // 这个和 WATCH_FACE_REALTEK_ROUND_454x454 相差10 可以参考
                imageSize = "dial_customize_454/" // 已经更改, 支持2D表盘的路径
            }
        default:
            break
        }
        
        
//        if dialCustomIs128(){
//            imageSize = "device128_"
//        }else if dialCustomIsWristband(){
//            imageSize = "deviceB9_172_"
//        }
    
        return imageSize
    }
}
