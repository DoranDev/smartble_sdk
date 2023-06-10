//
//  BleCustomizeWatchFace.swift
//  blesdk3
//
//  Created by SMA-IOS on 2022/2/7.
//  Copyright © 2022 szabh. All rights reserved.
//

import Foundation
import UIKit

let MaxHeight = UIScreen.main.bounds.size.height
let MaxWidth = UIScreen.main.bounds.size.width

class BleCustomizeWatchFace: UITableViewController {

    let mBleConnector = BleConnector.shared
    let mBleCache = BleCache.shared
    
    let btn240 = UIButton()
    let btn454 = UIButton()
    let progressLab = UILabel()
    let bgView = UIView()
    var bgWidth :Int = 240
    var bgHeight :Int = 240
    let digitalTime = UIImageView()
    let clock_pointer = UIImageView()
    let clock_scale = UIImageView()
    let bg_step = UIImageView()
    let bg_hr  = UIImageView()
    let bg_dis = UIImageView()
    let bg_cal = UIImageView()
    
    let timeSymView :UIImageView = UIImageView() //Realtek平台特殊字符绘制 :
    let dateSymView :UIImageView = UIImageView() //Realtek平台特殊字符绘制
    var isBmpResoure = false
    let faceBuilder = WatchFaceBuilder.sharedInstance
    let bleBin = BleWatchFaceBin()
    var imageCountStart :Int = 0
    var pointerHourImageSize :[UInt32] = [UInt32]()
    var pointerMinImageSize :[UInt32] = [UInt32]()
    var pointerImageSize :[UInt32] = [UInt32]()
    
    var timeAMImageSize :[UInt32] = [UInt32]()
    
    var timeDateHourImageSize :[UInt32] = [UInt32]()
    var timeDateSymbolImageSize :[UInt32] = [UInt32]()
    var timeDateMinImageSize :[UInt32] = [UInt32]()
    
    var timeWeekMonthImageSize :[UInt32] = [UInt32]()
    var timeWeekSymbolImageSize :[UInt32] = [UInt32]()
    var timeWeekDayImageSize :[UInt32] = [UInt32]()
    var timeWeekImageSize :[UInt32] = [UInt32]()
    
    var stepImageSize :[UInt32] = [UInt32]()
    var hrImageSize :[UInt32] = [UInt32]()
    var disImageSize :[UInt32] = [UInt32]()
    var calImageSize :[UInt32] = [UInt32]()
    
    var pointerHourBuffer :Data = Data()
    var pointerMinBuffer :Data = Data()
    var pointerBuffer :Data = Data()
    
    var timeAMBuffer :Data = Data()
    
    var timeDateHourBuffer :Data = Data()
    var timeDateSymbolBuffer :Data = Data()
    var timeDateMinBuffer :Data = Data()
    
    var timeWeekMonthBuffer :Data = Data()
    var timeWeekSymbolBuffer :Data = Data()
    var timeWeekDayBuffer :Data = Data()
    var timeWeekBuffer :Data = Data()
    
    var stepBuffer :Data = Data()
    var hrBuffer :Data = Data()
    var disBuffer :Data = Data()
    var calBuffer :Data = Data()
    
    var timeAMSize  = CGSize()
    var timeDateHourSize  = CGSize()
    var timeDateMinSize  = CGSize()
    var timeWeekMonthSize  = CGSize()
    var timeWeekDaySize  = CGSize()
    var timeWeekSize  = CGSize()
    
    var stepSize = CGSize()
    var hrSize = CGSize()
    var disSize = CGSize()
    var calSize = CGSize()
    
    var hourSize = CGSize()
    var minSize = CGSize()
    var secSize = CGSize()
    
    
    var watchFaceIdNum = 0
    var bleWatchFaceID : BleWatchFaceId?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Customize Watch Face"

        let otaButton = UIButton(type: .custom)
        otaButton.titleLabel?.font = .systemFont(ofSize: 13)
        otaButton.backgroundColor = .clear
        otaButton.setTitle("Synchronize", for: .normal)
        otaButton.setTitleColor(.black, for: .normal)
        otaButton.frame = CGRect(x: self.view.frame.size.width - 85, y: 20, width: 80, height: 30)
        otaButton.addTarget(self, action: #selector(senderCustomizeWathcFace(_:)), for: .touchUpInside)
        let rightBarItem = UIBarButtonItem(customView: otaButton)
        self.navigationItem.rightBarButtonItem = rightBarItem
    }

    func createUI(){

        btn240.setTitleColor(.black, for: .normal)
        btn240.frame = CGRect(x: 20, y: 10, width: 80, height: 40)
        btn240.setTitle("240*240", for: .normal)
        btn240.addTarget(self, action: #selector(selectWatchSize(_:)), for: .touchUpInside)
        btn240.tag = 100
        self.view.addSubview(btn240)

        btn454.setTitleColor(.black, for: .normal)
        btn454.frame = CGRect(x: 110, y: 10, width: 80, height: 40)
        btn454.setTitle("454*454", for: .normal)
        btn454.addTarget(self, action: #selector(selectWatchSize(_:)), for: .touchUpInside)
        btn454.tag = 101
        self.view.addSubview(btn454)
        if BleCache.shared.mWatchFaceType == BleDeviceInfo.WATCH_FACE_REALTEK_ROUND_454x454 {
            btn454.backgroundColor = .lightGray
            bgWidth = 454
            bgHeight = 454
        }else{
            btn240.backgroundColor = .lightGray
        }

        progressLab.textColor = .red
        progressLab.text = "progress:0"
        progressLab.frame = CGRect(x: 200, y: 10, width: 150, height: 40)
        self.view.addSubview(progressLab)
        let digitalBtn = UIButton()
        digitalBtn.setTitleColor(.black, for: .normal)
        digitalBtn.isSelected = false
        digitalBtn.setTitle("digital time", for: .normal)
        digitalBtn.addTarget(self, action: #selector(showDigitalTime(_:)), for: .touchUpInside)
        digitalBtn.frame = CGRect(x: 20, y: 55, width: 100, height: 30)
        self.view.addSubview(digitalBtn)

        let bgX = (Int(MaxWidth)/2)-(bgWidth/2)
        let bgY = (Int(MaxHeight)/2)-(bgHeight/2)
        bgView.frame = CGRect(x: bgX , y: bgY, width: bgWidth, height: bgHeight)
        self.view.addSubview(bgView)
        let bgimage = UIImageView()
        bgimage.image = UIImage.init(named: "bg_1")
        bgimage.frame = CGRect(x: 0, y: 0, width: bgWidth, height: bgWidth)
        bgView.addSubview(bgimage)

        clock_pointer.image = UIImage.init(named: "pointer_1")
        clock_pointer.frame = CGRect(x: 0, y: 0, width: bgWidth, height: bgWidth)
        bgView.addSubview(clock_pointer)

        clock_scale.image = UIImage.init(named: "scale_1")
        clock_scale.frame = CGRect(x: 0, y: 0, width: bgWidth, height: bgWidth)
        bgView.addSubview(clock_scale)

        digitalTime.image = UIImage.init(named: "digital_time")
        digitalTime.isHidden = true
        bgView.addSubview(digitalTime)
        digitalTime.frame = CGRect(x: bgWidth/2-83, y: bgHeight/2-70, width: 165, height: 100)

        bg_step.image = UIImage.init(named: "watchface_step")
        bg_step.frame = CGRect(x: bgWidth/2-18, y: 30, width: 37, height: 37)
        bgView.addSubview(bg_step)

        bg_cal.image = UIImage.init(named: "watchface_cal")
        bg_cal.frame = CGRect(x: 25, y: bgHeight/2-18, width: 37, height: 37)
        bgView.addSubview(bg_cal)

        bg_hr.image = UIImage.init(named: "watchface_hr")
        bg_hr.frame = CGRect(x: bgWidth - 70, y: bgHeight/2-18, width: 37, height: 37)
        bgView.addSubview(bg_hr)

        bg_dis.image = UIImage.init(named: "watchface_dis")
        bg_dis.frame = CGRect(x: bgWidth/2-18, y: bgHeight-100, width: 37, height: 37)
        bgView.addSubview(bg_dis)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BleConnector.shared.addBleHandleDelegate(String(obj: self), self)
        createUI()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        BleConnector.shared.removeBleHandleDelegate(String(obj: self))

    }

    @objc func selectWatchSize(_ sender:UIButton){
        if sender.tag == 100{
            btn240.backgroundColor = .lightGray
            btn454.backgroundColor = .white
        }else{
            btn240.backgroundColor = .white
            btn454.backgroundColor = .lightGray
        }

    }

    @objc func showDigitalTime(_ sender:UIButton){
        if sender.isSelected == true{
            sender.isSelected = false
            digitalTime.isHidden = true
            clock_scale.isHidden = false
            clock_pointer.isHidden = false
        }else{
            sender.isSelected = true
            digitalTime.isHidden = false
            clock_scale.isHidden = true
            clock_pointer.isHidden = true
        }
    }
    // MARK: - sender data
    @objc func senderCustomizeWathcFace(_ sender:UIButton){
        sender.isUserInteractionEnabled = false
        self.startCreateBinFile()
    }
}

// MARK: - mSupportWatchFaceId == 1
extension BleCustomizeWatchFace {

    @objc func selectRemoveFromSuperview(_ sender:UIButton) {
        self.navigationItem.leftBarButtonItem?.isEnabled = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        sender.removeFromSuperview()
    }
    
    func saveSelectImage(_ selectNum:Int){
        let fileName = "WatchFaceID"+"\(selectNum)"
        UIGraphicsBeginImageContextWithOptions(bgView.bounds.size,true, UIScreen.main.scale)
        bgView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        saveNSDataImage(currentData: image!.pngData()! as NSData, imageName: fileName)
    }
    
    func senderWatchFaceID(_ number:Int){
        let watchFaceId : Int32 = Int32(number+10000) //ID >= 100
        _ = BleConnector.shared.sendInt32(.WATCHFACE_ID, .UPDATE, Int(watchFaceId))
    }
    
    func saveNSDataImage(currentData: NSData, imageName: String){
        let fullPath = NSHomeDirectory().appending("/Documents/").appending(imageName)
        currentData.write(toFile: fullPath, atomically: true)
    }
}

extension BleCustomizeWatchFace {
    // MARK: - create watchFile
    func startCreateBinFile(){
        let dataSourceArray = getItemsPiont() as! Dictionary<String, Any>
        let image150 = getThumbnailImage()
        let image240 = getMainBgImage()
        isBmpResoure = false
        var bgWidth16 :UInt16 = 0
        var bgHeight16 :UInt16 = 0
        var bgX :UInt16 = 0
        var bgY :UInt16 = 0
        var pvWidth :UInt16 = 0
        var pvHeight :UInt16 = 0
        var pvX :UInt16 = 0
        var pvY :UInt16 = 0
        //固件坐标
        var bkGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_CENTER)//背景图
        var ylGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_CENTER)//预览图
        var apmGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//am pm
        var hourGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//hour
        var dayGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//Day
        var minGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//min
        var monthGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//month
        var weekSymGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//weekSym
        var weekDayGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//weekDay
        var weekGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_TOP)//week
        var stepGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_CENTER)//step
        var hrGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_CENTER)
        var disGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_CENTER)
        var calGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_CENTER)
        var pointGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)
        //MTK 平台默认为0
        var IgnoreBlack = UInt8(0)//默认为0 , bmp相关的图片用1
        var isFixCoordinate = false
        if BleCache.shared.mPlatform ==  BleDeviceInfo.PLATFORM_REALTEK ||
            BleCache.shared.mPlatform ==  BleDeviceInfo.PLATFORM_NORDIC{
            isBmpResoure = true
            isFixCoordinate = true
        }
        switch BleCache.shared.mWatchFaceType {
        case BleDeviceInfo.WATCH_FACE_REALTEK_ROUND_454x454:
            bgWidth16  = 454
            bgHeight16 = 454
            pvWidth  = 280
            pvHeight = 280
            break
        default:
            bgWidth16  = 240
            bgHeight16 = 240
            pvWidth  = 150
            pvHeight = 150
            break
        }
        bgX = bgWidth16/2
        bgY = bgHeight16/2
        pvX = pvWidth/2
        pvY = pvHeight/2
        //Realtek需要修正坐标参数
        if isFixCoordinate {
            bkGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_CENTER_R)
            ylGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_CENTER_R)
            apmGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)
            hourGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)
            dayGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)
            minGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)
            monthGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)
            weekSymGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)
            weekDayGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)
            weekGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_TOP)
            stepGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_CENTER_R)
            hrGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_CENTER_R)
            disGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_CENTER_R)
            calGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_CENTER_R)
            pointGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)
            IgnoreBlack = UInt8(1)
        }
        var newArray :[Element] = []
        //背景、预览处理
        var newElement :Element = Element()
        newElement.type = UInt8(faceBuilder.ELEMENT_BACKGROUND)
        newElement.w = bgWidth16
        newElement.h = bgHeight16
        newElement.gravity = bkGravity
        newElement.ignoreBlack = 0 //背景缩略图固定为0
        newElement.x = bgX
        newElement.y = bgY
        newElement.bottomOffset = 0
        newElement.leftOffset = 0
        newElement.imageCount = UInt8(1)
         //buffer每个元素大小
        var newByte :Data = getBackBuffer(image240)
        if isBmpResoure {
            let image16 :Data = ImageHelper.convertUIImage(toBitmapRGB565: image240)! as Data
            //小端序修改为大端序
            var index = 0
            newByte.removeAll()
            while index<image16.count{
                let item1 = image16[index]
                let item2 = image16[index+1]
                newByte.append(item2)
                newByte.append(item1)
                index += 2
            }
        }
        newElement.imageSizes = [UInt32(newByte.count)]
        newElement.imageBuffer = newByte
        newArray.append(newElement)
        
        
        var newElement1 :Element = Element()
        newElement1.type = UInt8(faceBuilder.ELEMENT_PREVIEW)
        newElement1.w = pvWidth
        newElement1.h = pvHeight
        newElement1.gravity = ylGravity
        newElement1.ignoreBlack = 0
        newElement1.x = pvX
        newElement1.y = pvY
        newElement1.bottomOffset = 0
        newElement1.leftOffset = 0
        newElement1.imageCount = UInt8(1)
        var newByte1 :Data = getBackBuffer(image150)
        if isBmpResoure {
            let image16 :Data = ImageHelper.convertUIImage(toBitmapRGB565: image150)! as Data
            var index = 0
            newByte1.removeAll()
            while index<image16.count{
                let item1 = image16[index]
                let item2 = image16[index+1]
                newByte1.append(item2)
                newByte1.append(item1)
                index += 2
            }
        }
        newElement1.imageSizes = [UInt32(newByte1.count)] //buffer每个元素大小
        newElement1.imageBuffer = newByte1
        newArray.append(newElement1)
        
        //处理其他元素
        let timeColor = UIColor.white
        let itemColor = UIColor.white
        var itemC = "_"
        var imageType = "png"
        if isBmpResoure {
            itemC = "_bmp_"
            imageType = "bmp"
        }
        for (key,value) in dataSourceArray {
            
            if key.elementsEqual("TimeAM"){
                bleLog("TimeAM is \(value)")
                let point :CGPoint = dataSourceArray["TimeAM"] as! CGPoint
                let colorNum = 0
                //am
                let amArray = identifyItemsColor(2,timeColor)
                var amElement :Element = Element()
                timeAMBuffer.removeAll()
                timeAMImageSize.removeAll()
                getImageBufferArray(amArray,0)
                //hour
                let hourArray = identifyItemsColor(3,timeColor)
                var hourElement :Element = Element()
                timeDateHourBuffer.removeAll()
                timeDateHourImageSize.removeAll()
                getImageBufferArray(hourArray,1)
                //dateSymbol
                var dateSyElement :Element = Element()
                timeDateSymbolBuffer.removeAll()
                timeDateSymbolImageSize.removeAll()
                timeDateSymbolBuffer.append (getImageBuffer(getImageDeviceType()+"hour"+"\(colorNum)"+itemC+"symbol"))
                let dateSySize = getImageSize(getImageDeviceType()+"hour"+"\(colorNum)"+itemC+"symbol",ofType: imageType)
               
                timeDateSymbolImageSize = [UInt32(timeDateSymbolBuffer.count)]
                //min
                let minArray = identifyItemsColor(3,timeColor)
                var minElement :Element = Element()
                timeDateMinBuffer.removeAll()
                timeDateMinImageSize.removeAll()
                getImageBufferArray(minArray,2)
                //month
                let monthArray = identifyItemsColor(4,timeColor)
                var monthElement :Element = Element()
                timeWeekMonthBuffer.removeAll()
                timeWeekMonthImageSize.removeAll()
                getImageBufferArray(monthArray,3)
                //weekSym
                var weekSymElement :Element = Element()
                let weekSymSize = getImageSize(getImageDeviceType()+"date"+"\(colorNum)"+itemC+"symbol",ofType: imageType)
                timeWeekSymbolBuffer.removeAll()
                timeWeekSymbolImageSize.removeAll()
                timeWeekSymbolBuffer.append(getImageBuffer(getImageDeviceType()+"date"+"\(colorNum)"+itemC+"symbol"))
                timeWeekSymbolImageSize = [UInt32(timeWeekSymbolBuffer.count)]
                //week day
                let weekDayArray = identifyItemsColor(4,timeColor)
                var weekDayElement :Element = Element()
                timeWeekDayBuffer.removeAll()
                timeWeekDayImageSize.removeAll()
                getImageBufferArray(weekDayArray,4)
                //week
                let weekArray = identifyItemsColor(5,timeColor)
                var weekElement :Element = Element()
                timeWeekBuffer.removeAll()
                timeWeekImageSize.removeAll()
                getImageBufferArray(weekArray,5)
                
                //point
                let hourY = point.y+timeAMSize.height+2
                let weekY = point.y+timeAMSize.height+timeDateHourSize.height+4
                let hourPoint = CGPoint(x: point.x-((timeDateHourSize.width*2)+(timeDateMinSize.width*2)+dateSySize.width+4), y: hourY)
                let dateSyPoint = CGPoint(x: point.x-((timeDateMinSize.width*2)+dateSySize.width+2), y: hourY)
                let minPoint = CGPoint(x: point.x-(timeDateMinSize.width*2), y: hourY)
                
                let monthPoint = CGPoint(x: point.x-((timeWeekMonthSize.width*2)+(timeWeekDaySize.width*2)+timeWeekSize.width+weekSymSize.width+6), y: weekY)
                let monthSyPoint = CGPoint(x: point.x-((timeWeekDaySize.width*2)+timeWeekSize.width+weekSymSize.width+4), y: weekY)
                let dayPoint = CGPoint(x: point.x-((timeWeekDaySize.width*2)+timeWeekSize.width+2), y: weekY)
                var weekPoint = CGPoint(x: point.x-timeWeekSize.width, y: weekY)
                let imageWidth :CGFloat = isBmpResoure ? 1.0:2.0
                if isFixCoordinate {
                    weekPoint = CGPoint(x: point.x-(timeWeekSize.width*0.5), y: weekY)
                }
                amElement.type = UInt8(faceBuilder.ELEMENT_DIGITAL_AMPM)
                amElement.gravity = apmGravity
                amElement.ignoreBlack = IgnoreBlack
                amElement.bottomOffset = 0
                amElement.leftOffset = UInt8(0)
                amElement.imageCount = UInt8(amArray.count)
                amElement.w = UInt16(timeAMSize.width)
                amElement.h = UInt16(timeAMSize.height)
                amElement.x = UInt16(point.x-timeAMSize.width)
                amElement.y = UInt16(point.y)
                amElement.imageSizes  = timeAMImageSize
                amElement.imageBuffer = timeAMBuffer
                newArray.append(amElement)

                
                hourElement.type = UInt8(faceBuilder.ELEMENT_DIGITAL_HOUR)
                hourElement.gravity = hourGravity
                hourElement.ignoreBlack = IgnoreBlack
                hourElement.bottomOffset = 0
                hourElement.leftOffset = UInt8(0)
                hourElement.imageCount = UInt8(hourArray.count)
                hourElement.w = UInt16(timeDateHourSize.width*imageWidth)
                hourElement.h = UInt16(timeDateHourSize.height)
                hourElement.x = UInt16(hourPoint.x)
                hourElement.y = UInt16(hourPoint.y)
                hourElement.imageSizes  = timeDateHourImageSize
                hourElement.imageBuffer = timeDateHourBuffer
                newArray.append(hourElement)
                
                
                dateSyElement.type = UInt8(faceBuilder.ELEMENT_DIGITAL_DIV_HOUR)
                dateSyElement.gravity = dayGravity
                dateSyElement.ignoreBlack = IgnoreBlack
                dateSyElement.bottomOffset = 0
                dateSyElement.leftOffset = UInt8(0)
                dateSyElement.imageCount = UInt8(1)
                dateSyElement.w = UInt16(dateSySize.width*imageWidth)
                dateSyElement.h = UInt16(dateSySize.height)
                dateSyElement.x = UInt16(dateSyPoint.x)
                dateSyElement.y = UInt16(dateSyPoint.y)
                dateSyElement.imageSizes = timeDateSymbolImageSize
                dateSyElement.imageBuffer = timeDateSymbolBuffer
                newArray.append(dateSyElement)
                
                minElement.type = UInt8(faceBuilder.ELEMENT_DIGITAL_MIN)
                minElement.gravity = minGravity
                minElement.ignoreBlack = IgnoreBlack
                minElement.bottomOffset = 0
                minElement.leftOffset = UInt8(0)
                minElement.imageCount = UInt8(minArray.count)
                minElement.w = UInt16(timeDateMinSize.width*imageWidth)
                minElement.h = UInt16(timeDateMinSize.height)
                minElement.x = UInt16(minPoint.x)
                minElement.y = UInt16(minPoint.y)
                minElement.imageSizes = timeDateMinImageSize
                minElement.imageBuffer = timeDateMinBuffer
                newArray.append(minElement)
                
                monthElement.type = UInt8(faceBuilder.ELEMENT_DIGITAL_MONTH)
                monthElement.gravity = monthGravity
                monthElement.ignoreBlack = IgnoreBlack
                monthElement.bottomOffset = 0
                monthElement.leftOffset = UInt8(0)
                monthElement.imageCount = UInt8(monthArray.count)
                monthElement.w = UInt16(timeWeekMonthSize.width*imageWidth)
                monthElement.h = UInt16(timeWeekMonthSize.height)
                monthElement.x = UInt16(monthPoint.x)
                monthElement.y = UInt16(monthPoint.y)
                monthElement.imageSizes = timeWeekMonthImageSize
                monthElement.imageBuffer = timeWeekMonthBuffer
                newArray.append(monthElement)
                
                weekSymElement.type = UInt8(faceBuilder.ELEMENT_DIGITAL_DIV_MONTH)
                weekSymElement.gravity = weekSymGravity
                weekSymElement.ignoreBlack = IgnoreBlack
                weekSymElement.bottomOffset = 0
                weekSymElement.leftOffset = UInt8(0)
                weekSymElement.imageCount = UInt8(1)
                weekSymElement.w = UInt16(weekSymSize.width)
                weekSymElement.h = UInt16(weekSymSize.height)
                weekSymElement.x = UInt16(monthSyPoint.x)
                weekSymElement.y = UInt16(monthSyPoint.y)
                weekSymElement.imageSizes = timeWeekSymbolImageSize
                weekSymElement.imageBuffer = timeWeekSymbolBuffer
                newArray.append(weekSymElement)
                
                weekDayElement.type = UInt8(faceBuilder.ELEMENT_DIGITAL_DAY)
                weekDayElement.gravity = weekDayGravity
                weekDayElement.ignoreBlack = IgnoreBlack
                weekDayElement.bottomOffset = 0
                weekDayElement.leftOffset = UInt8(0)
                weekDayElement.imageCount = UInt8(weekDayArray.count)
                weekDayElement.w = UInt16(timeWeekDaySize.width*imageWidth)
                weekDayElement.h = UInt16(timeWeekDaySize.height)
                weekDayElement.x = UInt16(dayPoint.x)
                weekDayElement.y = UInt16(dayPoint.y)
                weekDayElement.imageSizes = timeWeekDayImageSize
                weekDayElement.imageBuffer = timeWeekDayBuffer
                newArray.append(weekDayElement)
                
                weekElement.type = UInt8(faceBuilder.ELEMENT_DIGITAL_WEEKDAY)
                weekElement.gravity = weekGravity
                weekElement.ignoreBlack = IgnoreBlack
                weekElement.bottomOffset = 0
                weekElement.leftOffset = UInt8(0)
                weekElement.imageCount = UInt8(weekArray.count)
                weekElement.w = UInt16(timeWeekSize.width)
                weekElement.h = UInt16(timeWeekSize.height)
                weekElement.x = UInt16(weekPoint.x)
                weekElement.y = UInt16(weekPoint.y)
                weekElement.imageSizes = timeWeekImageSize
                weekElement.imageBuffer = timeWeekBuffer
                newArray.append(weekElement)

            }else if key.elementsEqual("Step"){
                bleLog("Step is \(value)")
                let point :CGPoint = dataSourceArray["Step"] as! CGPoint
                let imaArray = identifyItemsColor(1,itemColor)
                var newElement :Element = Element()
                newElement.type = UInt8(faceBuilder.ELEMENT_DIGITAL_STEP)
                newElement.gravity = stepGravity
                newElement.ignoreBlack = IgnoreBlack
                newElement.bottomOffset = 0
                newElement.leftOffset = UInt8(0)
                newElement.imageCount = UInt8(imaArray.count)
                stepBuffer.removeAll()
                stepImageSize.removeAll()
                getImageBufferArray(imaArray,6)
                newElement.x = UInt16(point.x)
                newElement.y = UInt16(point.y)
                newElement.w = UInt16(stepSize.width)
                newElement.h = UInt16(stepSize.height)
                newElement.imageSizes = stepImageSize
                newElement.imageBuffer = stepBuffer
                newArray.append(newElement)

            }else if key.elementsEqual("HR"){
                bleLog("HR is \(value)")
                let point :CGPoint = dataSourceArray["HR"] as! CGPoint
                let imaArray = identifyItemsColor(1,itemColor)
                var newElement :Element = Element()
                newElement.type = UInt8(faceBuilder.ELEMENT_DIGITAL_HEART)
                newElement.gravity = hrGravity
                newElement.ignoreBlack = IgnoreBlack
                newElement.bottomOffset = 0
                newElement.leftOffset = UInt8(0)
                newElement.imageCount = UInt8(imaArray.count)
                hrBuffer.removeAll()
                hrImageSize.removeAll()
                getImageBufferArray(imaArray,7)
                newElement.w = UInt16(hrSize.width)
                newElement.h = UInt16(hrSize.height)
                newElement.x = UInt16(point.x)
                newElement.y = UInt16(point.y)
                newElement.imageSizes = hrImageSize
                newElement.imageBuffer = hrBuffer
                newArray.append(newElement)

            }else if key.elementsEqual("Dis"){
                bleLog("Dis is \(value)")
                let point :CGPoint = dataSourceArray["Dis"] as! CGPoint
                let imaArray = identifyItemsColor(1,itemColor)
                var newElement :Element = Element()
                newElement.type = UInt8(faceBuilder.ELEMENT_DIGITAL_DISTANCE)
                newElement.gravity = disGravity
                newElement.ignoreBlack = IgnoreBlack
                newElement.bottomOffset = 0
                newElement.leftOffset = UInt8(0)
                newElement.imageCount = UInt8(imaArray.count)
                disBuffer.removeAll()
                disImageSize.removeAll()
                getImageBufferArray(imaArray,8)
                newElement.w = UInt16(disSize.width)
                newElement.h = UInt16(disSize.height)
                newElement.x = UInt16(point.x-disSize.width)
                newElement.y = UInt16(point.y)
                newElement.imageSizes = disImageSize
                newElement.imageBuffer = disBuffer
                newArray.append(newElement)

            }else if key.elementsEqual("Cal"){
                bleLog("Cal is \(value)")
                let point :CGPoint = dataSourceArray["Cal"] as! CGPoint
                let imaArray = identifyItemsColor(1,itemColor)
                var newElement :Element = Element()
                newElement.type = UInt8(faceBuilder.ELEMENT_DIGITAL_CALORIE)
                newElement.gravity = calGravity
                newElement.ignoreBlack = IgnoreBlack
                newElement.bottomOffset = 0
                newElement.leftOffset = UInt8(0)
                newElement.imageCount = UInt8(imaArray.count)
                calBuffer.removeAll()
                calImageSize.removeAll()
                getImageBufferArray(imaArray,9)
                newElement.x = UInt16(point.x)
                newElement.y = UInt16(point.y)
                newElement.w = UInt16(calSize.width)
                newElement.h = UInt16(calSize.height)
                newElement.imageSizes = calImageSize
                newElement.imageBuffer = calBuffer
                newArray.append(newElement)

            }else if key.elementsEqual("PointerNumber"){
                bleLog("PointerNumber is \(value)")
                let selNum :String = dataSourceArray["PointerNumber"] as! String
                getPointerImage(selNum)
                for index in 0..<3{
                    var newElement :Element = Element()
                    newElement.gravity = pointGravity
                    newElement.ignoreBlack = IgnoreBlack
                    newElement.x = bgX-1
                    newElement.y = bgY-1
                    newElement.imageCount = UInt8(1)
                    switch index {
                    case 0:
                        newElement.w = UInt16(hourSize.width)
                        newElement.h = UInt16(hourSize.height)
                        newElement.type = UInt8(faceBuilder.ELEMENT_NEEDLE_HOUR)
                        newElement.imageSizes = pointerHourImageSize
                        newElement.imageBuffer = pointerHourBuffer
                        newElement.bottomOffset = isBmpResoure ?  UInt8(hourSize.height/2) : UInt8(0)
                        newElement.leftOffset = isBmpResoure ?  UInt8(hourSize.width/2) : UInt8(0)
                        break
                    case 1:
                        newElement.w = UInt16(minSize.width)
                        newElement.h = UInt16(minSize.height)
                        newElement.type = UInt8(faceBuilder.ELEMENT_NEEDLE_MIN)
                        newElement.imageSizes = pointerMinImageSize
                        newElement.imageBuffer = pointerMinBuffer
                        newElement.bottomOffset = isBmpResoure ?  UInt8(minSize.height/2) : UInt8(0)
                        newElement.leftOffset = isBmpResoure ?  UInt8(minSize.width/2) : UInt8(0)
                        break
                    case 2:
                        newElement.w = UInt16(secSize.width)
                        newElement.h = UInt16(secSize.height)
                        newElement.type = UInt8(faceBuilder.ELEMENT_NEEDLE_SEC)
                        newElement.imageSizes = pointerImageSize
                        newElement.imageBuffer = pointerBuffer
                        newElement.bottomOffset = isBmpResoure ?  UInt8(secSize.height/2) : UInt8(0)
                        newElement.leftOffset = isBmpResoure ?  UInt8(secSize.width/2) : UInt8(0)
                        break
                    default:
                        break
                    }
                    newArray.append(newElement)
                }
            }
        }
        
        if newArray.count > 0{
            let sendData = buildWatchFace(newArray, newArray.count, dialCustomSenderImageFormat() ? Int32(faceBuilder.PNG_ARGB_8888) : Int32(faceBuilder.BMP_565))
            bleLog("bin文件大小 - \(sendData.toData().count)")
            if mBleConnector.sendStream(.WATCH_FACE, sendData.toData(),self.watchFaceIdNum){
                bleLog("sendStream - WATCH_FACE")
            }

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
    
    func buildWatchFace(_ elements:[Element],_ elementCount:Int,_ imageFormat:Int32) ->BleWatchFaceBin{

        //header
        bleBin.header = BleWatchFaceBinToHeader.init(ImageTotal: UInt16(imageCountStart), ElementCount: UInt8(elements.count), ImageFormat: UInt8(imageFormat))

        // ElementInfo[]
        var imageSizeIndex :UInt16 = 0
        let infoSize : Int = elementCount * BleWatchFaceBinElementInfo.ITEM_LENGTH
        bleBin.ElementInfo.removeAll()
        for i in 0..<elementCount {
            let newInfo = BleWatchFaceBinElementInfo.init(imageBufferOffset: 0, imageSizeIndex: imageSizeIndex, w: elements[i].w, h: elements[i].h, x: elements[i].x, y: elements[i].y, imageCount: elements[i].imageCount, type: elements[i].type, gravity: elements[i].gravity,ignoreBlack:  elements[i].ignoreBlack, bottomOffset: elements[i].bottomOffset, leftOffset: elements[i].leftOffset, reserved: 0)
            imageSizeIndex += UInt16(elements[i].imageCount)
            bleBin.ElementInfo.append(newInfo)
        }
        
        // uint32_t[] 所有图片的长度
        var elementImageBufferOffset : UInt32 = UInt32(BleWatchFaceBinToHeader.ITEM_LENGTH + infoSize+(4*imageCountStart))
        bleBin.imageCount.removeAll()
        for i in 0..<elementCount {
            bleBin.ElementInfo[i].infoImageBufferOffset = elementImageBufferOffset
            for j in 0..<Int(elements[i].imageSizes.count) {
                elementImageBufferOffset += elements[i].imageSizes[j]
                bleBin.imageCount.append(elements[i].imageSizes[j])
            }
        }

        // int8_t[] 所有图片buffer
        bleBin.imageBuffer.removeAll()
        for i in 0..<elementCount {
            bleBin.imageBuffer.append(elements[i].imageBuffer)
        }
        return bleBin
    }
    
    
    func getBackBuffer(_ imageBuffer:UIImage)-> Data{
        imageCountStart = imageCountStart+1
        return imageBuffer.pngData()!
    }
    
    func identifyItemsColor(_ type:Int,_ idColor:UIColor) -> NSMutableArray{

        let colorNum : Int  = 0
        let imagArray = NSMutableArray()
        var imageNumber :Int = 0
        if type == 1{ //加载控件颜色
            imageNumber = 10
            if isBmpResoure {
                imageNumber = 11
            }
        }else if type == 2{
            imageNumber = 2
        }else if type == 3{
            imageNumber = 10
        }else if type == 4{
            imageNumber = 10
        }else if type == 5{
            imageNumber = 7
        }
        var itemC = "_"
        if isBmpResoure {
            itemC = "_bmp_"
        }
//        device(a)_date(b)_bmp_(c) a->尺寸 默认240 b->颜色 c->图片数组下标
        for index in 0..<imageNumber{
            var newImage :String = ""
            if type == 1{
                //items color
                newImage = getImageDeviceType()+"items"+"\(colorNum)"+itemC+"\(index)"
                imagArray.add(newImage)
            }else if type == 2 {
                //am pm
                imagArray.add(getImageDeviceType()+"am"+itemC+"\(colorNum)")
                imagArray.add(getImageDeviceType()+"pm"+itemC+"\(colorNum)")
            }else if type == 3 {
                //时间
                imagArray.add(getImageDeviceType()+"hour"+"\(colorNum)"+itemC+"\(index)")
            }else if type == 4 {
                //日期
                imagArray.add(getImageDeviceType()+"date"+"\(colorNum)"+itemC+"\(index)")
                
            }else if type == 5{
                imagArray.add(getImageDeviceType()+"week"+"\(colorNum)"+itemC+"\(index)")
            }
        }
        
        return imagArray
    }
    
    func getImageDeviceType()-> String{
        var imageSize = "device_"
        switch BleCache.shared.mWatchFaceType {
        case BleDeviceInfo.WATCH_FACE_REALTEK_ROUND_454x454:
            imageSize = "device454_"
            break
        default:
            imageSize = "device_"
        }
        return imageSize
    }
    
    func getPointerImage(_ number:String){
        imageCountStart = imageCountStart+3
        
        pointerHourImageSize.removeAll()
        pointerMinImageSize.removeAll()
        pointerImageSize.removeAll()
        
        pointerHourBuffer.removeAll()
        pointerMinBuffer.removeAll()
        pointerBuffer.removeAll()
        var pHour = "device_pointerHour_"
        var pMinute = "device_pointerminute_"
        var pSecond = "device_pointerSecond_"
        var pType = "png"
        if isBmpResoure {
            pHour = getImageDeviceType()+"pointerHour_bmp_"
            pMinute = getImageDeviceType()+"pointerminute_bmp_"
            pSecond = getImageDeviceType()+"pointerSecond_bmp_"
            pType = "bmp"
        }
        
        let path1 = Bundle.main.path(forResource: pHour+number, ofType: pType)
        let path2 = Bundle.main.path(forResource: pMinute+number, ofType: pType)
        let path3 = Bundle.main.path(forResource: pSecond+number, ofType: pType)
        
        let newData1 :Data = getImagePathToData(pHour+number, ofType: pType)
        let newData2 :Data = getImagePathToData(pMinute+number, ofType: pType)
        let newData3 :Data = getImagePathToData(pSecond+number, ofType: pType)

        let newImage1 = UIImage(contentsOfFile: path1!)
        let newImage2 = UIImage(contentsOfFile: path2!)
        let newImage3 = UIImage(contentsOfFile: path3!)
        
        hourSize = CGSize(width: newImage1!.size.width, height: newImage1!.size.height)
        minSize = CGSize(width: newImage2!.size.width, height: newImage2!.size.height)
        secSize = CGSize(width: newImage3!.size.width, height: newImage3!.size.height)
        
        pointerHourBuffer.append(newData1)
        pointerMinBuffer.append(newData2)
        pointerBuffer.append(newData3)
        
        pointerHourImageSize = [UInt32(pointerHourBuffer.count)]
        pointerMinImageSize = [UInt32(pointerMinBuffer.count)]
        pointerImageSize = [UInt32(pointerBuffer.count)]

    }
    func getImagePathToData(_ imageName:String, ofType:String)-> Data{
        let newPath = Bundle.main.path(forResource: imageName, ofType: ofType)
        var newData :Data = Data()
        if ofType.elementsEqual("bmp"){
            //bmp图片特殊处理方式
            let newImage = UIImage(contentsOfFile: newPath!)//用于计算图片宽度
            let bmpWidth: Int = Int(newImage!.size.width)  //图片宽度
            let bitCount: Int = 16 //位深度，可为8，16，24，32
            let isReverseRows  = false  //是否反转行数据，就是将第一行置换为最后一行
            let rowSize: Int = (bitCount * bmpWidth + 31) / 32 * 4
            var offset = 0
            if !(bmpWidth % 2 == 0){
                offset = 2;
            }
            var image16 :Data  = NSData.init(contentsOfFile:String(newPath!) )! as Data
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
            let newImage = UIImage(contentsOfFile: newPath!)
            newData = newImage!.pngData()!
        }
        return newData
    }
    
    func getImageBuffer(_ imageName:String)-> Data{
        imageCountStart = imageCountStart+1
        var imageType = "png"
        if isBmpResoure {
            imageType = "bmp"
        }
        return getImagePathToData(imageName, ofType: imageType)
    }
    
    func getImageBufferArray(_ imageArray :NSMutableArray,_ getType:Int){
        imageCountStart = imageCountStart+imageArray.count
        for index in 0..<imageArray.count{
            var imageType = "png"
            if isBmpResoure {
                imageType = "bmp"
            }
            let path = Bundle.main.path(forResource: (imageArray[index] as! String), ofType: imageType)
            let newImage = UIImage(contentsOfFile: path!)
            let imageData = getImagePathToData(imageArray[index] as! String, ofType: imageType)
            switch getType {
            case 0:
                timeAMSize = CGSize(width: newImage!.size.width, height: newImage!.size.height)
                timeAMBuffer.append(imageData)
                timeAMImageSize.append(UInt32(imageData.count))
                break
            case 1:
                timeDateHourSize = CGSize(width: newImage!.size.width, height: newImage!.size.height)
                timeDateHourBuffer.append(imageData)
                timeDateHourImageSize.append(UInt32(imageData.count))
                break
            case 2:
                timeDateMinSize = CGSize(width: newImage!.size.width, height: newImage!.size.height)
                timeDateMinBuffer.append(imageData)
                timeDateMinImageSize.append(UInt32(imageData.count))
                break
            case 3:
                timeWeekMonthSize = CGSize(width: newImage!.size.width, height: newImage!.size.height)
                timeWeekMonthBuffer.append(imageData)
                timeWeekMonthImageSize.append(UInt32(imageData.count))
                break
            case 4:
                timeWeekDaySize = CGSize(width: newImage!.size.width, height: newImage!.size.height)
                timeWeekDayBuffer.append(imageData)
                timeWeekDayImageSize.append(UInt32(imageData.count))
                break
            case 5:
                timeWeekSize = CGSize(width: newImage!.size.width, height: newImage!.size.height)
                timeWeekBuffer.append(imageData)
                timeWeekImageSize.append(UInt32(imageData.count))
                break
            case 6:
                stepSize = CGSize(width: newImage!.size.width, height: newImage!.size.height)
                stepBuffer.append(imageData)
                stepImageSize.append(UInt32(imageData.count))
                break
            case 7:
                hrSize = CGSize(width: newImage!.size.width, height: newImage!.size.height)
                hrBuffer.append(imageData)
                hrImageSize.append(UInt32(imageData.count))
                break
            case 8:
                disSize = CGSize(width: newImage!.size.width, height: newImage!.size.height)
                disBuffer.append(imageData)
                disImageSize.append(UInt32(imageData.count))
                break
            case 9:
                calSize = CGSize(width: newImage!.size.width, height: newImage!.size.height)
                calBuffer.append(imageData)
                calImageSize.append(UInt32(imageData.count))
                break
            default:
                break
            }
        }
    }
    
    func getImageSize(_ imageName:String, ofType:String)-> CGSize{
        let path = Bundle.main.path(forResource: imageName, ofType: ofType)
        let newImage = UIImage(contentsOfFile: path!)
        return CGSize(width: newImage!.size.width, height: newImage!.size.height)
    }
}


extension BleCustomizeWatchFace {
    // MARK: - Tools
    func getMainBgImage()->UIImage{
        //设备主页背景
        drawLogoToBackImage() //判断是否添加特殊字符
        if clock_pointer.isHidden == false{
            clock_pointer.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now()+1.5) {
                self.clock_pointer.isHidden = false
            }
        }
        if digitalTime.isHidden == false{
            digitalTime.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now()+1.5) {
                self.digitalTime.isHidden = false
            }
        }
        UIGraphicsBeginImageContextWithOptions(bgView.bounds.size,true, UIScreen.main.scale)
        bgView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        switch BleCache.shared.mWatchFaceType {
        case BleDeviceInfo.WATCH_FACE_REALTEK_ROUND_454x454:
            bgWidth  = 454
            bgHeight = 454
            break
        default:
            bgWidth  = 240
            bgHeight = 240
            break
        }
        let newImage  = image?.resize(to: CGSize(width: bgWidth, height: bgHeight))
        timeSymView.removeFromSuperview()
        dateSymView.removeFromSuperview()
        //square watch face return newImage
        return maskRoundedImage(image: newImage!, radius: CGFloat(bgWidth/2))
    }

    func getThumbnailImage() -> UIImage{//Thumbnail preview
        var previewWidth :CGFloat = 0
        var previewHeight :CGFloat = 0
        switch  BleCache.shared.mWatchFaceType  {
        case BleDeviceInfo.WATCH_FACE_REALTEK_ROUND_454x454:
            previewWidth  = 280
            previewHeight = 280
            break
        default:
            previewWidth  = 140
            previewHeight = 140
            break
        }
        UIGraphicsBeginImageContextWithOptions(bgView.bounds.size,true, UIScreen.main.scale)
        bgView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let newImage  = image?.resize(to: CGSize(width: previewWidth, height: previewHeight))
        //square watch face return newImage
        return maskRoundedImage(image: newImage!, radius: previewWidth/2)
    }
    
    func maskRoundedImage(image: UIImage, radius: CGFloat) -> UIImage {
           let imageView: UIImageView = UIImageView(image: image)
           let layer = imageView.layer
           layer.masksToBounds = true
           layer.cornerRadius = radius
           UIGraphicsBeginImageContext(imageView.bounds.size)
           layer.render(in: UIGraphicsGetCurrentContext()!)
           let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
           UIGraphicsEndImageContext()
           return roundedImage!
    }

    
    func getItemsPiont() -> NSMutableDictionary{
        /**
         the coordinate points will be offset due to the resource image and view size. please adjust the coordinate points according to the device and app UI design.
         */
        let newDic = NSMutableDictionary()
        //计算比例尺
        var scaleW = bgView.bounds.size.width/240
        var scaleH = bgView.bounds.size.height/240
        switch BleCache.shared.mWatchFaceType {
        case BleDeviceInfo.WATCH_FACE_REALTEK_ROUND_454x454:
            scaleW = bgView.bounds.size.width/454
            scaleH = bgView.bounds.size.height/454
            break
        default:
            break
        }

        if bg_hr.isHidden == false{
            //W 37 H 37 piont-> data below icon
            let rect :CGRect = bg_hr.frame
            let piont  = CGPoint(x: (rect.origin.x+(rect.size.width/2))/scaleW, y: (rect.origin.y+rect.size.height+15)/scaleH)
            newDic.setValue(piont, forKey: "HR")
        }
        
        if bg_cal.isHidden == false {
            //W 37 H 37
            let rect :CGRect = bg_cal.frame
            let piont  = CGPoint(x: (rect.origin.x+(rect.size.width/2))/scaleW, y: (rect.origin.y+rect.size.height+15)/scaleH)
            newDic.setValue(piont, forKey: "Cal")
        }
        
        if bg_dis.isHidden == false {
            //W 37 H 37
            let rect :CGRect = bg_dis.frame
            let piont  = CGPoint(x: (rect.origin.x+rect.size.width)/scaleW, y: (rect.origin.y+rect.size.height+15)/scaleH)
            newDic.setValue(piont, forKey: "Dis")
        }
        
        if bg_step.isHidden == false {
            //W 37 H 37
            let rect :CGRect = bg_step.frame
            let piont  = CGPoint(x: (rect.origin.x+(rect.size.width/2))/scaleW, y: (rect.origin.y+rect.size.height+15)/scaleH)
            newDic.setValue(piont, forKey: "Step")
        }
        
        if digitalTime.isHidden == false {
            //W 165 H 100 piont-> the coordinates of the upper right corner of the "digital_time" example
            let rect :CGRect = digitalTime.frame
            let piontAM  = CGPoint(x: (rect.origin.x+rect.size.width)/scaleW, y: rect.origin.y/scaleH)
            newDic.setValue(piontAM, forKey: "TimeAM")
        }else{
            /**
             this is a watch type dial, and only the resource pictures of the hour hand, minute hand, and second hand are transmitted.
             the scale and background image are combined as a new image to transfer to the device
             */
            newDic.setValue("1", forKey: "PointerNumber")
        }
        return newDic
    }
    
    /**
     Realtek部分设备固件代码未解析时间,日期的特殊符号 : \，需要手动添加到背景图显示
     */
    func drawLogoToBackImage() {
        var isReloadBgView = false
        if (mBleCache.mPlatform == BleDeviceInfo.PLATFORM_REALTEK || mBleCache.mPlatform == BleDeviceInfo.PLATFORM_NORDIC) && digitalTime.isHidden == false{
            //需要在背景图显示特殊符号
            isReloadBgView = true
        }
        if !isReloadBgView {
            return
        }
        var scaleW = bgView.bounds.size.width/240
        var scaleH = bgView.bounds.size.height/240
        var yOffset :CGFloat = 0.0
        var timeYOffset :CGFloat = 0.0
        var imageName = "device_"
        switch BleCache.shared.mWatchFaceType {
        case BleDeviceInfo.WATCH_FACE_REALTEK_ROUND_454x454:
            scaleW = bgView.bounds.size.width/454
            scaleH = bgView.bounds.size.height/454
            yOffset = -10.0
            timeYOffset = -10.0
            imageName = "device454_"
            break
        
        default:
            scaleW = bgView.bounds.size.width/240
            scaleH = bgView.bounds.size.height/240
            imageName = "device_"
            break
        }
        //获取路径的image 文件
        let numColor :Int = 0
        let imTimePng = imageName+"hour"+"\(numColor)"+"_symbol"
        let imDatePng = imageName+"date"+"\(numColor)"+"_symbol"
        let tpngPath = Bundle.main.path(forResource: imTimePng, ofType: "png")
        let dpngPath = Bundle.main.path(forResource: imDatePng, ofType: "png")
        timeSymView.image = UIImage(contentsOfFile: tpngPath!)
        dateSymView.image = UIImage(contentsOfFile: dpngPath!)
        
        //get bmp 计算坐标
        let imTimebmp   = imageName+"hour"+"\(numColor)"+"_bmp_symbol" //:
        let imDateSybmp = imageName+"date"+"\(numColor)"+"_bmp_symbol" //\
        let imAMbmp     = imageName+"am_bmp_"+"\(numColor)"
        let imHourbmp   = imageName+"hour"+"\(numColor)"+"_bmp_0"
        let imWeekbmp   = imageName+"week"+"\(numColor)"+"_bmp_0"
        let imDatebmp   = imageName+"date"+"\(numColor)"+"_bmp_0"
        
        let tbmpPath = Bundle.main.path(forResource: imTimebmp, ofType: "bmp")
        let dbmpPath = Bundle.main.path(forResource: imDateSybmp, ofType: "bmp")
        let ambmpPath = Bundle.main.path(forResource: imAMbmp, ofType: "bmp")
        let hourbmpPath = Bundle.main.path(forResource: imHourbmp, ofType: "bmp")
        let weekbmpPath = Bundle.main.path(forResource: imWeekbmp, ofType: "bmp")
        let datebmpPath = Bundle.main.path(forResource: imDatebmp, ofType: "bmp")
        
        let bmpTime :UIImage = UIImage(contentsOfFile: String(tbmpPath!))!
        let bmpDateSy :UIImage = UIImage(contentsOfFile: String(dbmpPath!))!
        let bmpAM :UIImage = UIImage(contentsOfFile: String(ambmpPath!))!
        let bmphour :UIImage = UIImage(contentsOfFile: String(hourbmpPath!))!
        let bmpWeek :UIImage = UIImage(contentsOfFile: String(weekbmpPath!))!
        let bmpDate :UIImage = UIImage(contentsOfFile: String(datebmpPath!))!
        //计算坐标
        let rect :CGRect = digitalTime.frame
        let piontAM  = CGPoint(x: (rect.origin.x+rect.size.width)/scaleW, y: (rect.origin.y)/scaleH)
        
        let timeSymRect :CGRect = CGRect(x: piontAM.x-(bmphour.size.width*2+(bmpTime.size.width*0.75)+2), y: piontAM.y+bmpAM.size.height+10+timeYOffset, width: bmpTime.size.width, height: bmpTime.size.height)
        let dateSymRect :CGRect = CGRect(x: piontAM.x-(bmpDate.size.width*2+bmpWeek.size.width+(bmpDateSy.size.width*0.75)+4), y: piontAM.y+bmpAM.size.height+bmphour.size.height+4+yOffset, width: bmpDateSy.size.width*scaleW, height: bmpDateSy.size.height*scaleH)
        
        timeSymView.frame = CGRect(x: timeSymRect.origin.x*scaleW, y: timeSymRect.origin.y*scaleH, width: timeSymRect.size.width, height: timeSymRect.size.height)
        dateSymView.frame = CGRect(x: dateSymRect.origin.x*scaleW, y: dateSymRect.origin.y*scaleH, width: dateSymRect.size.width, height: dateSymRect.size.height)
        bgView.addSubview(timeSymView)
        bgView.addSubview(dateSymView)

    }
}

extension BleCustomizeWatchFace: BleHandleDelegate {

    func onStreamProgress(_ status: Bool, _ errorCode: Int, _ total: Int, _ completed: Int) {
        print("onStreamProgress \(status) \(errorCode) \(total) \(completed)")
        let progressValue = CGFloat(completed) / CGFloat(total)
        progressLab.text = "progress:\(String(format: "%.f", progressValue * 100.0))%"
        if errorCode == 0 && total == completed {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func onReadWatchFaceId(_ watchFaceId: BleWatchFaceId) {
        bleWatchFaceID = watchFaceId
    }
    
    func onWatchFaceIdUpdate(_ status: Bool) {
        self.startCreateBinFile()
    }
}

extension UIImage {
    /**
     *  重设图片大小
     */
    func resize(to newSize: CGSize) -> UIImage {
      UIGraphicsBeginImageContextWithOptions(newSize, true, 1)
      draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
      let result = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      return result!
    }
}
