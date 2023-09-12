//
//  CustomWatchFaceImageExtension.swift
//  blesdk3
//
//  Created by 叩鼎科技 on 2023/5/10.
//  Copyright © 2023 szabh. All rights reserved.
//

import UIKit

extension UIImage {
    
    /// 重新排列像素点
    /// - Parameter heightDivisor: 如果指针元素, 就可以使用0.6, 如果是其他元素, 就必须传递为1.0
    /// - Parameter heightDivisor: If it is a pointer element, you can use 0.6, if it is another element, you must pass it as 1.0
    func rearrangePixels(_ heightDivisor: CGFloat = 0.6) -> (pixData:Data?, width:Int, height:Int) {
        
        let h = Int(self.size.height * heightDivisor)
        let w = Int(self.size.width)
        // A R G B
        // 转换图片  17 * 3
        let rowSize = Int((w * 3 + 4 - 1) / 4 * 4)
        var newData = Data(repeating: UInt8(0), count: rowSize * h)
        
        
        guard let pixArray = self.extraPixels(in: self.size) else {
            bleLog("获取hourImg 像素点失败")
            return (nil, 0, 0)
        }
        //print("测试pixArray:\(String(describing: pixArray))")
        //print("")
        
        for y in 0..<h {
            
            var rowBytes = Data(repeating: UInt8(0), count: rowSize)
            for x in 0..<w {
                
                let index = y * w + x
                let a565 = argb8888To8565(pixArray[index])
                
                let offset = x * 3
                rowBytes[offset + 2] = UInt8(a565 & 0xFF)
                rowBytes[offset + 1] = UInt8((a565 >> 8) & 0xFF)
                rowBytes[offset + 0] = UInt8((a565 >> 16) & 0xFF)  // a
            }
            
            newData.insert(contentsOf: rowBytes, at: y * rowSize)
        }
        
        return (newData, w, h)
    }
    
    private func argb8888To8565(_ pixel: UInt32) -> UInt32 {
        
        // iOS这边是RGBA 和安卓的ARGB不一样, 获取像素点的颜色, 需要单独处理
        let r = CGFloat((pixel >> 0)  & 0xff) / 255.0
        let g = CGFloat((pixel >> 8)  & 0xff) / 255.0
        let b = CGFloat((pixel >> 16) & 0xff) / 255.0
        let a = CGFloat((pixel >> 24) & 0xff) / 255.0
        //print("r : \(r), g : \(g), b : \(b), a : \(a)")
        
        let multiplier = CGFloat(255.999999)
        let rawR = UInt32(Int(r * multiplier))
        let rawG = UInt32(Int(g * multiplier))
        let rawB = UInt32(Int(b * multiplier))
        let rawA = UInt32(Int(a * multiplier))
        
        let f = (rawR >> 3)
        return (rawA << 16) + (f << 11) + ((rawG >> 2) << 5) + (rawB >> 3)
    }
    // 旧的参考安卓的方法, 不要使用, 仅作为一个参考即可
    //private func argb8888To8565_2(argb: UInt32) -> UInt32 {
    //
    //    // iOS这边是RGBA 和安卓的ARGB不一样, 获取像素点的颜色, 需要单独处理
    //    let r = argb >> 24 & 0xFF
    //    let g = argb >> 16 & 0xFF
    //    let b = argb >> 8 & 0xFF
    //    let a = argb & 0xFF
    //
    //
    //    let f = (r >> 3)
    //    return (a << 16) + (f << 11) + ((g >> 2) << 5) + (b >> 3)
    //}
    
    /// 字节对齐, 默认4字节对齐, 有更好的方法, 后续再优化
    private func byteAlignment(_ data: Data, _ num: Int = 4) -> Data {
        
        
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
    
    /// 根据图片大小提取像素
    ///
    /// - parameter size: 图片大小
    ///
    /// - returns: 像素数组
    private func extraPixels(in size: CGSize) -> [UInt32]? {
        
        guard let cgImg = self.cgImage else {
            return nil
        }
        /*
         不能直接以image的宽高作为绘制的宽高，因为image的size可能会比控件的size大很多。
         所以在生成bitmapContext的时候需要以实际的控件宽高为准
         */
        let w = Int(size.width)
        let h = Int(size.height)
        let bitsPerComponent = 8 // 32位的图像，所以每个颜色组件包含8bit
        let bytesPerRow = w * 4  // 1 byte = 8 bit, 32位图像的话，每个像素包含4个byte
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue // RGBA
        // let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        // 因为是32位图像，RGBA各占8位 8*4=32，所以像素数据的数组的元素类型应该是UInt32。
        var bufferData = Array<UInt32>(repeating: 0, count: w * h)
        guard let cxt = CGContext(data: &bufferData, width: w, height: h, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return nil
        }
        // 将图像绘制进上下文中
        //cxt.draw(cgImg, in: rect)
        cxt.draw(cgImg, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        return bufferData
    }
    
    //MARK: - 这个是老的bmp图片传递给表盘的处理
    func getImagePathToData(watchBundle: Bundle, imgPath: String)-> Data{

        var newData :Data = Data()
        
        //bmp图片特殊处理方式
        //let newImage = UIImage(contentsOfFile: newPath!)//用于计算图片宽度
        let bmpWidth: Int = Int(self.size.width)  //图片宽度
        let bitCount: Int = 16 //位深度，可为8，16，24，32
        let isReverseRows  = false  //是否反转行数据，就是将第一行置换为最后一行
        let rowSize: Int = (bitCount * bmpWidth + 31) / 32 * 4
        var offset = 0
        if !(bmpWidth % 2 == 0){
            offset = 2;
        }
        
        let tempPath = watchBundle.path(forResource: imgPath, ofType: nil)
        var image16 :Data  = NSData(contentsOfFile:String(tempPath!))! as Data
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
    }
}

