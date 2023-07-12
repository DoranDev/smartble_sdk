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
    
    //let btn240 = UIButton()
    //let btn454 = UIButton()
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
    var selectView = ABHSelectWatchFaceId()
    var bleWatchFaceID : BleWatchFaceId?
    
    /// 用于处理表盘转换的数据, 还未完整, 后面写完整
    private let viewModel = CustomWatchFaceViewModel()
    // 是否支持2D加速? 如果支持需要特别处理
    private let isSupp2D = BleCache.shared.mSupport2DAcceleration != 0
    
    var image150 :UIImage?//预览图
    var image240 :UIImage?//背景图
    
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
        
        //btn240.setTitleColor(.black, for: .normal)
        //btn240.frame = CGRect(x: 20, y: 10, width: 80, height: 40)
        //btn240.setTitle("240*240", for: .normal)
        //btn240.addTarget(self, action: #selector(selectWatchSize(_:)), for: .touchUpInside)
        //btn240.tag = 100
        //self.view.addSubview(btn240)
        //
        //btn454.setTitleColor(.black, for: .normal)
        //btn454.frame = CGRect(x: 110, y: 10, width: 80, height: 40)
        //btn454.setTitle("454*454", for: .normal)
        //btn454.addTarget(self, action: #selector(selectWatchSize(_:)), for: .touchUpInside)
        //btn454.tag = 101
        //self.view.addSubview(btn454)
        //if BleCache.shared.mWatchFaceType == BleDeviceInfo.WATCH_FACE_REALTEK_ROUND_454x454 {
        //    btn454.backgroundColor = .lightGray
        //    bgWidth = 454
        //    bgHeight = 454
        //}else{
        //    btn240.backgroundColor = .lightGray
        //}
        
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
        
        
        
        let isSquare = dialCustomIsRound()
        if isSquare {
            
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
        } else {
            
            // 方形表盘
            let bgimage = UIImageView()
            bgimage.image = UIImage.init(named: "watchface_square_bk3")
            bgimage.frame = CGRect(x: 0, y: 0, width: bgWidth, height: bgWidth)
            bgView.addSubview(bgimage)
            
            clock_pointer.image = UIImage.init(named: "pointer_1")
            clock_pointer.frame = CGRect(x: 0, y: 0, width: bgWidth, height: bgWidth)
            bgView.addSubview(clock_pointer)
            
            clock_scale.image = UIImage.init(named: "sqScale_1")
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
    
    //@objc func selectWatchSize(_ sender:UIButton){
    //    if sender.tag == 100{
    //        btn240.backgroundColor = .lightGray
    //        btn454.backgroundColor = .white
    //    }else{
    //        btn240.backgroundColor = .white
    //        btn454.backgroundColor = .lightGray
    //    }
    //
    //}
    
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
        if BleCache.shared.mSupportWatchFaceId == 1{            
            self.isShowSelectWatchFaceId()
        }else{
            self.startCreateBinFile()
        }
    }
}

// MARK: - mSupportWatchFaceId == 1
extension BleCustomizeWatchFace {
    func isShowSelectWatchFaceId(){

        selectView = ABHSelectWatchFaceId()
        let bkBtn = UIButton()
        bkBtn.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        bkBtn.addTarget(self, action: #selector(selectRemoveFromSuperview(_ :)), for: .touchUpInside)
        bkBtn.frame = CGRect(x: 0, y: 0, width: MaxWidth, height: MaxHeight)
        self.view.addSubview(bkBtn)
    
        selectView.frame = CGRect(x: 0, y: MaxHeight-400, width: MaxWidth, height: 300)
        self.view.addSubview(selectView)

        if bleWatchFaceID != nil{
            selectView.watchFaceId = bleWatchFaceID
        }
        selectView.makeView()
        selectView.selectItem = ({ (num:Int) in
            bleLog("selectItem - \(num)")
            self.watchFaceIdNum = num
            self.saveSelectImage(num)
            self.senderWatchFaceID(num)
            bkBtn.sendActions(for: .touchUpInside)
        })
        
        
    }
    
    @objc func selectRemoveFromSuperview(_ sender:UIButton) {
        self.navigationItem.leftBarButtonItem?.isEnabled = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        sender.removeFromSuperview()
        self.selectView.removeFromSuperview()
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
        image150 = getThumbnailImage()
        image240 = getMainBgImage()
        isBmpResoure = false
        
        var bgWidth :UInt16 = 0
        var bgHeight :UInt16 = 0
        var bgX :UInt16 = 0
        var bgY :UInt16 = 0
        var pvWidth :UInt16 = 0
        var pvHeight :UInt16 = 0
        var pvX :UInt16 = 0
        var pvY :UInt16 = 0
        
        
        var isFixCoordinate = false
        if BleCache.shared.mPlatform ==  BleDeviceInfo.PLATFORM_REALTEK ||
            BleCache.shared.mPlatform ==  BleDeviceInfo.PLATFORM_NORDIC ||
        (BleCache.shared.mSupportJLWatchFace == 0 && BleCache.shared.mPlatform == BleDeviceInfo.PLATFORM_JL){
            isBmpResoure = true
            isFixCoordinate = true
        }

        switch BleCache.shared.mWatchFaceType {
        case BleDeviceInfo.WATCH_FACE_320x363:
            bgWidth  = 320
            bgHeight = 385
            bgX = 160
            bgY = 181
            pvWidth  = 160
            pvHeight = 180
            pvX = 80
            pvY = 90
            break
        case BleDeviceInfo.WATCH_FACE_REALTEK_SQUARE_240x280,BleDeviceInfo.WATCH_FACE_REALTEK_SQUARE_240x280_2,BleDeviceInfo.WATCH_FACE_REALTEK_SQUARE_240x280_19,BleDeviceInfo.WATCH_FACE_REALTEK_SQUARE_240x280_20,BleDeviceInfo.WATCH_FACE_REALTEK_SQUARE_240x295_21:
            bgWidth  = 240
            bgHeight = 280
            // 用于设置表盘的x轴中心点的偏移值
            bgX = 120
            // 用于设置表盘的y轴中心点的偏移值
            bgY = 140

            // 预览图宽度
            pvWidth  = 150
            // 预览图高度
            pvHeight = 170
            pvX = 120
            pvY = 120
            isBmpResoure = true
            isFixCoordinate = true
            break
        case BleDeviceInfo.WATCH_FACE_REALTEK_ROUND_360x360:
            bgWidth  = 360
            bgHeight = 360
            bgX = 180
            bgY = 180
            pvWidth  = 225
            pvHeight = 225
            pvX = 112
            pvY = 112
            isBmpResoure = true
            isFixCoordinate = true
            break
        
        case BleDeviceInfo.WATCH_FACE_REALTEK_RACKET:
            bgWidth  = 240
            bgHeight = 240
            bgX = 120
            bgY = 120
            pvWidth  = 106
            pvHeight = 106
            pvX = 120
            pvY = 120
            break
        case BleDeviceInfo.WATCH_FACE_REALTEK_ROUND_454x454:
            bgWidth  = 454
            bgHeight = 454
            bgX = 227
            bgY = 227
            pvWidth  = 280
            pvHeight = 280
            pvX = 140
            pvY = 140
            break
        case BleDeviceInfo.WATCH_FACE_SERVER: // 这里表示自定义表盘
            let thArray = getThumbnailImageWidthHeight()
            let bkArray = getWatchDialBKWidthHeight()
            bgWidth  = UInt16(bkArray[0])
            bgHeight = UInt16(bkArray[1])
            bgX = UInt16(bgWidth/2)
            bgY = UInt16(bgHeight/2)
            pvWidth  = UInt16(thArray[0])
            pvHeight = UInt16(thArray[1])
            pvX = pvWidth/2
            pvY = pvHeight/2
            break
        default:
            bgWidth  = 240
            bgHeight = 240
            bgX = 120
            bgY = 120
            pvWidth  = 150
            pvHeight = 150
            pvX = 120
            pvY = 120
            break
        }
        
        
        if self.isSupp2D {
            
            // 支持2D表盘, x, y传递0即可
            let bgFrame = WatchFaceRect(x: 0, y: 0, width: bgWidth, height: bgHeight)
            let pvFrame = WatchFaceRect(x: 0, y: 0, width: pvWidth, height: pvHeight)
            self.createBinForSupport2DWatchFace(dataSourceArray, isFixCoordinate: isFixCoordinate, bgFrame: bgFrame, pvFrame: pvFrame)
        } else {
            
            let bgFrame = WatchFaceRect(x: bgX, y: bgY, width: bgWidth, height: bgHeight)
            let pvFrame = WatchFaceRect(x: pvX, y: pvY, width: pvWidth, height: pvHeight)
            // 不支持2D, 如果使用bmp资源图片, 使用下面的方法
            //self.createBinForBMP_File(dataSourceArray, isFixCoordinate: isFixCoordinate, bgFrame: bgFrame, pvFrame: pvFrame)
            // 不支持2D, 如果使用png资源图片, 使用下面的方法
            // 2D is not supported, if you use png resource images, use the following method
            self.createBinForNotSupport2DWatchFace(dataSourceArray, isFixCoordinate: isFixCoordinate, bgFrame: bgFrame, pvFrame: pvFrame)
            
        }
        
    }
    
    /// 支持2D表盘的处理
    private func createBinForSupport2DWatchFace(_ dataSourceArray: [String:Any], isFixCoordinate: Bool, bgFrame: WatchFaceRect, pvFrame: WatchFaceRect) {
        
        //固件坐标
        var bkGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_CENTER)//背景图
        var ylGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_CENTER)//预览图
        let apmGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//am pm
        let hourGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//hour
        let dayGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//Day
        let minGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//min
        let monthGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//month
        let weekSymGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//weekSym
        let weekDayGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//weekDay
        var weekGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_TOP)//week
        var stepGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_CENTER)//step
        var hrGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_CENTER)
        var disGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_CENTER)
        var calGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_CENTER)
        let pointGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)
        

        //Realtek需要修正坐标参数
        if isFixCoordinate {
            bkGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_CENTER_R)
            ylGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_CENTER_R)
            weekGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_TOP)
            stepGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_CENTER_R)
            hrGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_CENTER_R)
            disGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_CENTER_R)
            calGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_CENTER_R)
        }
        
        // 这个背景问题, 有疑问, 参考安卓修改为这个值
        if isSupp2D {
            bkGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//背景图
        }
        
        // 存储表盘的所有元素数据
        var watchFaceElements = [Element]()
        
        // 背景图 虽然使用了使用的是 image240?.pngData()! 带透明的资源, 但是经过 .getImgWith(UIImage(data: bgPngData!)!, isAlpha: false) 方法转换, 就是不带透明度的资源了, 所以isAlpha应该设置为0
        // Although the background image uses image240?.pngData()! with transparent resources, but after conversion by .getImgWith(UIImage(data: bgPngData!), isAlpha: false) method, it is a resource without transparency, so isAlpha should be set to 0
        var elementBg = Element(type: faceBuilder.ELEMENT_BACKGROUND, isAlpha: 0)
        elementBg.w = bgFrame.width
        elementBg.h = bgFrame.height
        elementBg.gravity = bkGravity
        elementBg.ignoreBlack = isSupp2D ? 4:0 //支持2D使用4, 背景缩略图固定为0
        elementBg.x = 0 // 支持2的直接传递0
        elementBg.y = 0 // 支持2的直接传递0
        elementBg.imageCount = UInt8(1)
        // 支持2D, 表盘背景二进制数据
        let bgPngData = image240?.pngData()!
        let newByteBg = ImageConverTools.getImgWith(UIImage(data: bgPngData!)!, isAlpha: false)
        let bgByte = self.viewModel.byteAlignment(newByteBg)
        elementBg.imageSizes = [UInt32(bgByte.count)]
        elementBg.imageBuffer = bgByte
        watchFaceElements.append(elementBg)
        
        
        // 预览图, 虽然使用了使用的是 image150?.pngData()! 带透明的资源, 但是经过 .getImgWith(UIImage(data: pvPngData!)!, isAlpha: false) 方法转换, 就是不带透明度的资源了, 所以isAlpha应该设置为0
        // Although the preview image uses image150?.pngData()! resources with transparency, but after conversion with the .getImgWith(UIImage(data: pvPngData!), isAlpha: false) method, it is a resource without transparency. So isAlpha should be set to 0
        var elementPrevie = Element(type: faceBuilder.ELEMENT_PREVIEW, isAlpha: 0)
        elementPrevie.w = pvFrame.width
        elementPrevie.h = pvFrame.height
        elementPrevie.gravity = ylGravity
        elementPrevie.ignoreBlack = isSupp2D ? 4:0 //支持2D使用4
        elementPrevie.x = 0 // 支持2的直接传递0
        elementPrevie.y = 0 // 支持2的直接传递0
        elementPrevie.imageCount = UInt8(1)
        // 预览图二进制数据
        let pvPngData = image150?.pngData()!
        let newBytePv = ImageConverTools.getImgWith(UIImage(data: pvPngData!)!, isAlpha: false)
        let pvByte = self.viewModel.byteAlignment(newBytePv)
        
        elementPrevie.imageSizes = [UInt32(pvByte.count)] //buffer每个元素大小
        elementPrevie.imageBuffer = pvByte
        watchFaceElements.append(elementPrevie)
        
        //处理其他元素
        var timeColor = dial_select_color1
        var itemColor = dial_select_color1
        if dataSourceArray.keys.contains("ItemsColor"){
            itemColor = dataSourceArray["ItemsColor"] as! UIColor
        }
        if dataSourceArray.keys.contains("TimeColor"){
            timeColor = dataSourceArray["TimeColor"] as! UIColor
        }
        
        
        for (key,value) in dataSourceArray {
            
            if key.elementsEqual("TimeAM"){
                bleLog("TimeAM is \(value)")
                
                // 在资源文件中, 颜色的索引
                let colorNum = getColorNumber(timeColor)
                let point :CGPoint = dataSourceArray["TimeAM"] as! CGPoint
                
                
                //am
                let ampmRes = self.viewModel.getImageBufferArray(.AMPM, true, colorNum)
                
                // hour
                let hourRes = self.viewModel.getImageBufferArray(.HOUR, true, colorNum)
                // min
                let minRes = self.viewModel.getImageBufferArray(.MINUTES, true, colorNum)
                
                
                // month
                let monthRes = self.viewModel.getImageBufferArray(.MONTH, true, colorNum)
                let timeWeekMonthSize = monthRes.imageSize
                // day
                let dayRes = self.viewModel.getImageBufferArray(.DAY, true, colorNum)
                let timeWeekDaySize = dayRes.imageSize
                // week
                let weekRes = self.viewModel.getImageBufferArray(.WEAK, true, colorNum)
                let timeWeekSize = weekRes.imageSize
                
                
                // 日期之间的分割线
                let dateSymbolRes = self.viewModel.getImageBufferArray(.dateSymbol, true, colorNum)
                let dateSySize = dateSymbolRes.imageSize
                // 星期之间的分割线
                let weekSymbolRes = self.viewModel.getImageBufferArray(.weakSymbol, true, colorNum)
                let weekSymSize = weekSymbolRes.imageSize
                
                //point
                let hourY = point.y+ampmRes.imageSize.height+2
                let weekY = point.y+ampmRes.imageSize.height+hourRes.imageSize.height+4
                let hourPoint = CGPoint(x: point.x-((hourRes.imageSize.width*2)+(minRes.imageSize.width*2)+dateSySize.width+4), y: hourY)
                let dateSyPoint = CGPoint(x: point.x-((minRes.imageSize.width*2)+dateSySize.width+2), y: hourY)
                let minPoint = CGPoint(x: point.x-(minRes.imageSize.width*2), y: hourY)
                
                
                // 月 / 日, 数据增加偏移值, 在F11上面周一, 周三, 周日出现日期和星期太靠近
                let monthEleOffset:CGFloat = 10
                let monthPoint = CGPoint(x: point.x-((timeWeekMonthSize.width*2)+(timeWeekDaySize.width*2)+timeWeekSize.width+weekSymSize.width+6) - monthEleOffset, y: weekY)
                let monthSyPoint = CGPoint(x: point.x-((timeWeekDaySize.width*2)+timeWeekSize.width+weekSymSize.width+4) - monthEleOffset, y: weekY)
                let dayPoint = CGPoint(x: point.x-((timeWeekDaySize.width*2)+timeWeekSize.width+2) - monthEleOffset, y: weekY)
                
                var weekPoint = CGPoint(x: point.x-timeWeekSize.width, y: weekY)
                let imageWidth :CGFloat = isBmpResoure ? 1.0:2.0
                if isFixCoordinate {
                    weekPoint = CGPoint(x: point.x-(timeWeekSize.width*0.5), y: weekY)
                }
                
                
                
                // am pm  支持2D  ignoreBlack使用4;
                //let ampmImgArray = self.viewModel.identifyItemsColor(.AMPM, colorNum)
                //let ampmRes = self.viewModel.getImageBufferArray(ampmImgArray, .AMPM)
                let tempAmPmPoint = CGPoint(x: point.x-ampmRes.imageSize.width, y: point.y)
                
                var amElement = Element(type: faceBuilder.ELEMENT_DIGITAL_AMPM, isAlpha: 1)
                amElement.setElementData(point: tempAmPmPoint, size: ampmRes.imageSize, ignoreBlack: 4, watchRes: ampmRes)
                amElement.gravity = apmGravity
                
                watchFaceElements.append(amElement)


                // hour  支持2D  ignoreBlack使用4;
                //let hourImgArray = self.viewModel.identifyItemsColor(.HOUR, colorNum)
                //let hourRes = self.viewModel.getImageBufferArray(hourImgArray, .HOUR)

                let tempHourSize = CGSize(width: hourRes.imageSize.width * imageWidth, height: hourRes.imageSize.height)
                
                var hourElement = Element(type: faceBuilder.ELEMENT_DIGITAL_HOUR, isAlpha: 1)
                hourElement.setElementData(point: hourPoint, size: tempHourSize, ignoreBlack: 4, watchRes: hourRes)
                hourElement.gravity = hourGravity
                
                watchFaceElements.append(hourElement)


                // 日期之间的分割线  支持2D  ignoreBlack使用4;
                //let dateSymbolImgArray = self.viewModel.identifyItemsColor(.dateSymbol, colorNum)
                //let dateSymbolRes = self.viewModel.getImageBufferArray(dateSymbolImgArray, .dateSymbol)

                let tempdateSySize = CGSize(width: dateSymbolRes.imageSize.width * imageWidth, height: dateSymbolRes.imageSize.height)
                
                var dateSyElement = Element(type: faceBuilder.ELEMENT_BACKGROUND, isAlpha: 1)
                dateSyElement.setElementData(point: dateSyPoint, size: tempdateSySize, ignoreBlack: 4, watchRes: dateSymbolRes)
                dateSyElement.gravity = dayGravity
                
                watchFaceElements.append(dateSyElement)



                // min  支持2D  ignoreBlack使用4;
                //let minImgArray = self.viewModel.identifyItemsColor(.MINUTES, colorNum)
                //let minRes = self.viewModel.getImageBufferArray(minImgArray, .MINUTES)

                let tempMinSySize = CGSize(width: minRes.imageSize.width * imageWidth, height: minRes.imageSize.height)
                
                var minElement = Element(type: faceBuilder.ELEMENT_DIGITAL_MIN, isAlpha: 1)
                minElement.setElementData(point: minPoint, size: tempMinSySize, ignoreBlack: 4, watchRes: minRes)
                minElement.gravity = minGravity
                watchFaceElements.append(minElement)



                // month  支持2D  ignoreBlack使用4;
                //let monthImgArray = self.viewModel.identifyItemsColor(.MONTH, colorNum)
                //let monthRes = self.viewModel.getImageBufferArray(monthImgArray, .MONTH)
                
                let tempMonthSize = CGSize(width: monthRes.imageSize.width * imageWidth, height: monthRes.imageSize.height)
                
                var monthElement = Element(type: faceBuilder.ELEMENT_DIGITAL_MONTH, isAlpha: 1)
                monthElement.setElementData(point: monthPoint, size: tempMonthSize, ignoreBlack: 4, watchRes: monthRes)
                monthElement.gravity = monthGravity
                watchFaceElements.append(monthElement)
                
                

                // 日期之间的分割线  支持2D  ignoreBlack使用4;
                //let weekSymbolImgArray = self.viewModel.identifyItemsColor(.weakSymbol, colorNum)
                //let weekSymbolRes = self.viewModel.getImageBufferArray(weekSymbolImgArray, .weakSymbol)

                var weekSymElement = Element(type: faceBuilder.ELEMENT_BACKGROUND, isAlpha: 1)
                weekSymElement.setElementData(point: monthSyPoint, size: weekSymbolRes.imageSize, ignoreBlack: 4, watchRes: weekSymbolRes)
                weekSymElement.gravity = weekSymGravity
                
                watchFaceElements.append(weekSymElement)



                // day  支持2D  ignoreBlack使用4;
                //let dayImgArray = self.viewModel.identifyItemsColor(.DAY, colorNum)
                //let dayRes = self.viewModel.getImageBufferArray(dayImgArray, .DAY)
                
                let tempDaySize = CGSize(width: dayRes.imageSize.width * imageWidth, height: dayRes.imageSize.height)

                var dayElement = Element(type: faceBuilder.ELEMENT_DIGITAL_DAY, isAlpha: 1)
                dayElement.setElementData(point: dayPoint, size: tempDaySize, ignoreBlack: 4, watchRes: dayRes)
                dayElement.gravity = weekDayGravity
                watchFaceElements.append(dayElement)



                // week  支持2D  ignoreBlack使用4;
                //let weekImgArray = self.viewModel.identifyItemsColor(.WEAK, colorNum)
                //let weekRes = self.viewModel.getImageBufferArray(weekImgArray, .DAY)

                var weekElement = Element(type: faceBuilder.ELEMENT_DIGITAL_WEEKDAY, isAlpha: 1)
                weekElement.setElementData(point: weekPoint, size: weekRes.imageSize, ignoreBlack: 4, watchRes: weekRes)

                weekElement.gravity = weekGravity
                weekElement.ignoreBlack = UInt8(4)
                watchFaceElements.append(weekElement)

            }else if key.elementsEqual("Step"){
                bleLog("Step is \(value)")
                // 在资源文件中, 颜色的索引
                let colorNum = getColorNumber(itemColor)
                let point :CGPoint = dataSourceArray["Step"] as! CGPoint
                
                // 脚步  支持2D  ignoreBlack使用4;
                let stepRes = self.viewModel.getImageBufferArray(.STEP, true, colorNum)
                
                var elementStep = Element(type: faceBuilder.ELEMENT_DIGITAL_STEP, isAlpha: 1)
                elementStep.setElementData(point: point, size: stepRes.imageSize, ignoreBlack: 4, watchRes: stepRes)
                
                elementStep.gravity = stepGravity
                watchFaceElements.append(elementStep)

            }else if key.elementsEqual("HR"){
                bleLog("HR is \(value)")
                // 在资源文件中, 颜色的索引
                let colorNum = getColorNumber(itemColor)
                let point :CGPoint = dataSourceArray["HR"] as! CGPoint
                
                // 心率  支持2D  ignoreBlack使用4;
                let hrRes = self.viewModel.getImageBufferArray(.HEART_RATE, true, colorNum)
                
                var elementHR = Element(type: faceBuilder.ELEMENT_DIGITAL_HEART, isAlpha: 1)
                elementHR.setElementData(point: point, size: hrRes.imageSize, ignoreBlack: 4, watchRes: hrRes)
                elementHR.gravity = hrGravity
                watchFaceElements.append(elementHR)

            }else if key.elementsEqual("Dis"){
                bleLog("Dis is \(value)")
                // 在资源文件中, 颜色的索引
                let colorNum = getColorNumber(itemColor)
                let rawDisPoint = dataSourceArray["Dis"] as! CGPoint
                bleLog("表盘元素rawDisPoint:\(rawDisPoint)")
                
                // 距离  支持2D  ignoreBlack使用4;
                let disRes = self.viewModel.getImageBufferArray(.DISTANCE, true, colorNum)
                let disPoint = CGPoint(x: rawDisPoint.x-disRes.imageSize.width, y: rawDisPoint.y)
                bleLog("表盘元素disPoint:\(disPoint)")
                
                var elementDis = Element(type: faceBuilder.ELEMENT_DIGITAL_DISTANCE, isAlpha: 1)
                elementDis.setElementData(point: disPoint, size: disRes.imageSize, ignoreBlack: 4, watchRes: disRes)
                elementDis.gravity = disGravity
                
                /**
                 (lldb) po disSize
                 ▿ (18.0, 24.0)
                 - width : 18.0
                 - height : 24.0
                 
                 (lldb) po dataSourceArray["Dis"]
                 ▿ Optional<Any>
                 - some : NSPoint: {432.13372093023253, 266.86627906976742}
                 
                 (lldb) po newElement.x
                 414

                 (lldb) po newElement.y
                 266
                 */
                
                watchFaceElements.append(elementDis)

            }else if key.elementsEqual("Cal"){
                bleLog("Cal is \(value)")
                // 在资源文件中, 颜色的索引
                let colorNum = getColorNumber(itemColor)
                let point :CGPoint = dataSourceArray["Cal"] as! CGPoint
                
                // 卡路里  支持2D  ignoreBlack使用4;
                let calRes = self.viewModel.getImageBufferArray(.CALORIES, true, colorNum)
                
                var elementCal = Element(type: faceBuilder.ELEMENT_DIGITAL_CALORIE, isAlpha: 1)
                elementCal.setElementData(point: point, size: calRes.imageSize, ignoreBlack: 4, watchRes: calRes)
                elementCal.gravity = calGravity
                watchFaceElements.append(elementCal)

            }else if key.elementsEqual("PointerNumber"){
                bleLog("PointerNumber is \(value)")
                let tempNum = dataSourceArray["PointerNumber"] as! String
                
                guard var index = Int(tempNum) else {
                    bleLog("获取指针转换失败")
                    return
                }
                
                // 指针资源图片索引, 这个需要开发者根据自己的资源图片来布局
                index -= 1
                if index < 0 {
                    index = 0
                }
                
                guard let pinitGroup = self.viewModel.getPointerImage(index, isPNG: true) else {

                    // 这里代表获取指针失败, 需要提示用户
                    bleLog("获取指针数据失败, 需要提示用户")
                    return
                }
                
                for index in 0..<3{
                    
                    var newElement: Element?
                    switch index {
                    case 0:
                        newElement = getPointElement(type: faceBuilder.ELEMENT_NEEDLE_HOUR, isAlpha: 1)
                        newElement?.setElementForPointerData(isPoint: true, rawSize: pinitGroup.hourRes.rawImageSize, size: pinitGroup.hourRes.imageSize, watchRes: pinitGroup.hourRes)
                        break
                    case 1:
                        newElement = getPointElement(type: faceBuilder.ELEMENT_NEEDLE_MIN, isAlpha: 1)
                        newElement?.setElementForPointerData(isPoint: true, rawSize: pinitGroup.minRes.rawImageSize, size: pinitGroup.minRes.imageSize, watchRes: pinitGroup.minRes)
                        break
                    case 2:
                        newElement = getPointElement(type: faceBuilder.ELEMENT_NEEDLE_SEC, isAlpha: 1)
                        newElement?.setElementForPointerData(isPoint: true, rawSize: pinitGroup.secRes.rawImageSize, size: pinitGroup.secRes.imageSize, watchRes: pinitGroup.secRes)
                        break
                    default:
                        break
                    }
                    
                    newElement?.gravity = pointGravity
                    newElement?.ignoreBlack = UInt8(1)  // 指针,支持2D  ignoreBlack应该使用固定值 1
                    newElement?.x = bgFrame.width / 2
                    newElement?.y = bgFrame.height / 2
                    newElement?.imageCount = UInt8(1)
                    if let tempEle = newElement {
                        watchFaceElements.append(tempEle)
                    }
                }
            }
        }
       
        if watchFaceElements.count > 0{
            #warning("For devices that support 2D, you must use faceBuilder.PNG_ARGB_8888")
            // 支持2D的设备, 必须使用faceBuilder.PNG_ARGB_8888
            let sendData = buildWatchFace(watchFaceElements, watchFaceElements.count, Int32(faceBuilder.PNG_ARGB_8888))
            bleLog("支持2d表盘bin文件大小 - \(sendData.toData().count)")
            //if timeAuto == nil{
            //    timeAuto = Timer.scheduledTimer(withTimeInterval: TimeInterval(10), repeats: true, block: { _ in
            //        self.timeAutoCount += 10
            //        if self.timeAutoCount >= 60{
            //            bleLog("一分钟没有新进度取消同步")
            //            self.doneAction(false)
            //        }
            //    })
            //}
            if mBleConnector.sendStream(.WATCH_FACE, sendData.toData(),watchFaceIdNum){
                bleLog("sendStream - WATCH_FACE")
            }

        }
    }
    
    /// 不支持2D表盘的处理
    private func createBinForNotSupport2DWatchFace(_ dataSourceArray: [String:Any], isFixCoordinate: Bool, bgFrame: WatchFaceRect, pvFrame: WatchFaceRect) {
        
        //固件坐标
        var bkGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_CENTER)//背景图
        var ylGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_CENTER)//预览图
        let apmGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//am pm
        let hourGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//hour
        let dayGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//Day
        let minGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//min
        let monthGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//month
        let weekSymGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//weekSym
        let weekDayGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//weekDay
        var weekGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_TOP)//week
        var stepGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_CENTER)//step
        var hrGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_CENTER)
        var disGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_CENTER)
        var calGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_CENTER)
        let pointGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)


        //Realtek需要修正坐标参数
        if isFixCoordinate {
            bkGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_CENTER_R)
            ylGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_CENTER_R)
            weekGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_TOP)
            stepGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_CENTER_R)
            hrGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_CENTER_R)
            disGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_CENTER_R)
            calGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_CENTER_R)
        }

        // 这个背景问题, 有疑问, 参考安卓修改为这个值
        if isSupp2D {
            bkGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//背景图
        }

        // 存储表盘的所有元素数据
        var watchFaceElements = [Element]()

        // 不支持2D设备, 背景图片, 由于调用了rearrangePixels(1.0).pixData得出的是8565带透明度的图片, 所以isAlpha需要传递1
        // 2D devices and background images are not supported, and the result of calling rearrangePixels(1.0).pixData is 8565 images with transparency, so isAlpha needs to pass 1
        var elementBg = Element(type: faceBuilder.ELEMENT_BACKGROUND, isAlpha: 1)
        elementBg.w = bgFrame.width
        elementBg.h = bgFrame.height
        elementBg.gravity = bkGravity
        elementBg.ignoreBlack = 0 // 2D is not supported, 0 should be used
        // 不支持2D的设备, 传递背景图片的x,y值需要注意
        elementBg.x = bgFrame.x
        elementBg.y = bgFrame.y
        elementBg.imageCount = UInt8(1)
        // 不支持2D的背景二进制数据
        let bgPngData = image240?.pngData()!
        let bgByte = UIImage(data: bgPngData!)?.rearrangePixels(1.0).pixData

        elementBg.imageSizes = [UInt32(bgByte!.count)]
        elementBg.imageBuffer = bgByte!
        
        watchFaceElements.append(elementBg)


        // 不支持2D设备, 预览图片, 由于调用了rearrangePixels(1.0).pixData得出的是8565带透明度的图片, 所以isAlpha需要传递1
        // Does not support 2D devices, preview pictures, because rearrangePixels(1.0).pixData is called to get 8565 pictures with transparency, so isAlpha needs to pass 1
        var elementPrevie = Element(type: faceBuilder.ELEMENT_PREVIEW, isAlpha: 1)
        elementPrevie.w = pvFrame.width
        elementPrevie.h = pvFrame.height
        elementPrevie.gravity = ylGravity
        elementPrevie.ignoreBlack = 0 // 2D is not supported, 0 should be used
        elementPrevie.imageCount = UInt8(1)

        // 预览图二进制数据
        let pvPngData = image150?.pngData()!
        let pvByte = UIImage(data: pvPngData!)?.rearrangePixels(1.0).pixData

        elementPrevie.imageSizes = [UInt32(pvByte!.count)] //buffer每个元素大小
        elementPrevie.imageBuffer = pvByte!
        watchFaceElements.append(elementPrevie)

        //处理其他元素
        var timeColor = dial_select_color1
        var itemColor = dial_select_color1
        if dataSourceArray.keys.contains("ItemsColor"){
            itemColor = dataSourceArray["ItemsColor"] as! UIColor
        }
        if dataSourceArray.keys.contains("TimeColor"){
            timeColor = dataSourceArray["TimeColor"] as! UIColor
        }


        #warning("The 2D ignoreBlack parameter is not supported to use a fixed value of 0")
        // 不支持2D ignoreBlack参数使用固定值0
        // The 2D ignoreBlack parameter is not supported to use a fixed value of 0
        let kNotSupport2D_IgnoreBlack = 0

        for (key,value) in dataSourceArray {

            if key.elementsEqual("TimeAM"){
                bleLog("TimeAM is \(value)")
                
                // 在资源文件中, 颜色的索引
                let colorNum = getColorNumber(timeColor)
                let point :CGPoint = dataSourceArray["TimeAM"] as! CGPoint
                
                
                //am  支持2D  ignoreBlack使用4;
                let ampmRes = self.viewModel.getImageBufferArray(.AMPM, false, colorNum)
                
                // hour  支持2D  ignoreBlack使用4;
                let hourRes = self.viewModel.getImageBufferArray(.HOUR, false, colorNum)
                // min  支持2D  ignoreBlack使用4;
                let minRes = self.viewModel.getImageBufferArray(.MINUTES, false, colorNum)
                
                
                // month  支持2D  ignoreBlack使用4;
                let monthRes = self.viewModel.getImageBufferArray(.MONTH, false, colorNum)
                let timeWeekMonthSize = monthRes.imageSize
                // day  支持2D  ignoreBlack使用4;
                let dayRes = self.viewModel.getImageBufferArray(.DAY, false, colorNum)
                let timeWeekDaySize = dayRes.imageSize
                // week  支持2D  ignoreBlack使用4;
                let weekRes = self.viewModel.getImageBufferArray(.WEAK, false, colorNum)
                let timeWeekSize = weekRes.imageSize
                
                
                // 日期之间的分割线  支持2D  ignoreBlack使用4;
                let dateSymbolRes = self.viewModel.getImageBufferArray(.dateSymbol, false, colorNum)
                let dateSySize = dateSymbolRes.imageSize
                // 星期之间的分割线  支持2D  ignoreBlack使用4;
                let weekSymbolRes = self.viewModel.getImageBufferArray(.weakSymbol, false, colorNum)
                let weekSymSize = weekSymbolRes.imageSize
                
                //point
                let hourY = point.y+ampmRes.imageSize.height+2
                let weekY = point.y+ampmRes.imageSize.height+hourRes.imageSize.height+4
                let hourPoint = CGPoint(x: point.x-((hourRes.imageSize.width*2)+(minRes.imageSize.width*2)+dateSySize.width+4), y: hourY)
                let dateSyPoint = CGPoint(x: point.x-((minRes.imageSize.width*2)+dateSySize.width+2), y: hourY)
                let minPoint = CGPoint(x: point.x-(minRes.imageSize.width*2), y: hourY)
                
                
                // 月 / 日, 数据增加偏移值, 在F11上面周一, 周三, 周日出现日期和星期太靠近
                let monthEleOffset:CGFloat = 10
                let monthPoint = CGPoint(x: point.x-((timeWeekMonthSize.width*2)+(timeWeekDaySize.width*2)+timeWeekSize.width+weekSymSize.width+6) - monthEleOffset, y: weekY)
                let monthSyPoint = CGPoint(x: point.x-((timeWeekDaySize.width*2)+timeWeekSize.width+weekSymSize.width+4) - monthEleOffset, y: weekY)
                let dayPoint = CGPoint(x: point.x-((timeWeekDaySize.width*2)+timeWeekSize.width+2) - monthEleOffset, y: weekY)
                
                var weekPoint = CGPoint(x: point.x-timeWeekSize.width, y: weekY)
                let imageWidth :CGFloat = isBmpResoure ? 1.0:2.0
                if isFixCoordinate {
                    weekPoint = CGPoint(x: point.x-(timeWeekSize.width*0.5), y: weekY)
                }
                
                
                
                // am pm  支持2D  ignoreBlack使用1, 否则使用0
                let tempAmPmPoint = CGPoint(x: point.x-ampmRes.imageSize.width, y: point.y)
                
                var amElement = Element(type: faceBuilder.ELEMENT_DIGITAL_AMPM, isAlpha: 1)
                amElement.setElementData(point: tempAmPmPoint, size: ampmRes.imageSize, ignoreBlack: kNotSupport2D_IgnoreBlack, watchRes: ampmRes)
                amElement.gravity = apmGravity
                
                watchFaceElements.append(amElement)
                
                
                // hour  支持2D  ignoreBlack使用1, 否则使用0
                let tempHourSize = CGSize(width: hourRes.imageSize.width * imageWidth, height: hourRes.imageSize.height)

                var hourElement = Element(type: faceBuilder.ELEMENT_DIGITAL_HOUR, isAlpha: 1)
                hourElement.setElementData(point: hourPoint, size: tempHourSize, ignoreBlack: kNotSupport2D_IgnoreBlack, watchRes: hourRes)
                hourElement.gravity = hourGravity

                watchFaceElements.append(hourElement)


                // 日期之间的分割线  ignoreBlack使用1, 否则使用0
                //let dateSymbolImgArray = self.viewModel.identifyItemsColor(.dateSymbol, colorNum)
                //let dateSymbolRes = self.viewModel.getImageBufferArray(dateSymbolImgArray, .dateSymbol)

                let tempdateSySize = CGSize(width: dateSymbolRes.imageSize.width * imageWidth, height: dateSymbolRes.imageSize.height)

                var dateSyElement = Element(type: faceBuilder.ELEMENT_BACKGROUND, isAlpha: 1)
                dateSyElement.setElementData(point: dateSyPoint, size: tempdateSySize, ignoreBlack: kNotSupport2D_IgnoreBlack, watchRes: dateSymbolRes)
                dateSyElement.gravity = dayGravity

                watchFaceElements.append(dateSyElement)



                // min  支持2D  ignoreBlack使用1, 否则使用0
                //let minImgArray = self.viewModel.identifyItemsColor(.MINUTES, colorNum)
                //let minRes = self.viewModel.getImageBufferArray(minImgArray, .MINUTES)

                let tempMinSySize = CGSize(width: minRes.imageSize.width * imageWidth, height: minRes.imageSize.height)

                var minElement = Element(type: faceBuilder.ELEMENT_DIGITAL_MIN, isAlpha: 1)
                minElement.setElementData(point: minPoint, size: tempMinSySize, ignoreBlack: kNotSupport2D_IgnoreBlack, watchRes: minRes)
                minElement.gravity = minGravity
                watchFaceElements.append(minElement)



                // month  支持2D  ignoreBlack使用1, 否则使用0
                //let monthImgArray = self.viewModel.identifyItemsColor(.MONTH, colorNum)
                //let monthRes = self.viewModel.getImageBufferArray(monthImgArray, .MONTH)

                let tempMonthSize = CGSize(width: monthRes.imageSize.width * imageWidth, height: monthRes.imageSize.height)

                var monthElement = Element(type: faceBuilder.ELEMENT_DIGITAL_MONTH, isAlpha: 1)
                monthElement.setElementData(point: monthPoint, size: tempMonthSize, ignoreBlack: kNotSupport2D_IgnoreBlack, watchRes: monthRes)
                monthElement.gravity = monthGravity
                watchFaceElements.append(monthElement)



                // 日期之间的分割线  支持2D  ignoreBlack使用1, 否则使用0
                //let weekSymbolImgArray = self.viewModel.identifyItemsColor(.weakSymbol, colorNum)
                //let weekSymbolRes = self.viewModel.getImageBufferArray(weekSymbolImgArray, .weakSymbol)

                var weekSymElement = Element(type: faceBuilder.ELEMENT_BACKGROUND, isAlpha: 1)
                weekSymElement.setElementData(point: monthSyPoint, size: weekSymbolRes.imageSize, ignoreBlack: kNotSupport2D_IgnoreBlack, watchRes: weekSymbolRes)
                weekSymElement.gravity = weekSymGravity

                watchFaceElements.append(weekSymElement)



                // day  支持2D  ignoreBlack使用1, 否则使用0
                //let dayImgArray = self.viewModel.identifyItemsColor(.DAY, colorNum)
                //let dayRes = self.viewModel.getImageBufferArray(dayImgArray, .DAY)

                let tempDaySize = CGSize(width: dayRes.imageSize.width * imageWidth, height: dayRes.imageSize.height)

                var dayElement = Element(type: faceBuilder.ELEMENT_DIGITAL_DAY, isAlpha: 1)
                dayElement.setElementData(point: dayPoint, size: tempDaySize, ignoreBlack: kNotSupport2D_IgnoreBlack, watchRes: dayRes)
                dayElement.gravity = weekDayGravity
                watchFaceElements.append(dayElement)



                // week  支持2D  ignoreBlack使用1, 否则使用0
                //let weekImgArray = self.viewModel.identifyItemsColor(.WEAK, colorNum)
                //let weekRes = self.viewModel.getImageBufferArray(weekImgArray, .DAY)

                var weekElement = Element(type: faceBuilder.ELEMENT_DIGITAL_WEEKDAY, isAlpha: 1)
                weekElement.setElementData(point: weekPoint, size: weekRes.imageSize, ignoreBlack: kNotSupport2D_IgnoreBlack, watchRes: weekRes)

                weekElement.gravity = weekGravity
                watchFaceElements.append(weekElement)
            }else if key.elementsEqual("Step"){
                bleLog("Step is \(value)")
                // 在资源文件中, 颜色的索引
                let colorNum = getColorNumber(itemColor)
                let point :CGPoint = dataSourceArray["Step"] as! CGPoint
                
                // 脚步  支持2D  ignoreBlack使用1, 否则使用0
                let stepRes = self.viewModel.getImageBufferArray(.STEP, false, colorNum)
                
                var elementStep = Element(type: faceBuilder.ELEMENT_DIGITAL_STEP, isAlpha: 1)
                elementStep.setElementData(point: point, size: stepRes.imageSize, ignoreBlack: kNotSupport2D_IgnoreBlack, watchRes: stepRes)
                
                elementStep.gravity = stepGravity
                watchFaceElements.append(elementStep)
            }else if key.elementsEqual("HR"){
                bleLog("HR is \(value)")
                // 在资源文件中, 颜色的索引
                let colorNum = getColorNumber(itemColor)
                let point :CGPoint = dataSourceArray["HR"] as! CGPoint
                
                // 心率  支持2D  ignoreBlack使用1, 否则使用0
                let hrRes = self.viewModel.getImageBufferArray(.HEART_RATE, false, colorNum)
                
                var elementHR = Element(type: faceBuilder.ELEMENT_DIGITAL_HEART, isAlpha: 1)
                elementHR.setElementData(point: point, size: hrRes.imageSize, ignoreBlack: kNotSupport2D_IgnoreBlack, watchRes: hrRes)
                elementHR.gravity = hrGravity
                watchFaceElements.append(elementHR)
            }else if key.elementsEqual("Dis"){
                bleLog("Dis is \(value)")
                // 在资源文件中, 颜色的索引
                let colorNum = getColorNumber(itemColor)
                let rawDisPoint = dataSourceArray["Dis"] as! CGPoint
                bleLog("表盘元素rawDisPoint:\(rawDisPoint)")
                
                // 距离  支持2D  ignoreBlack使用1, 否则使用0
                let disRes = self.viewModel.getImageBufferArray(.DISTANCE, false, colorNum)
                let disPoint = CGPoint(x: rawDisPoint.x-disRes.imageSize.width, y: rawDisPoint.y)
                bleLog("表盘元素disPoint:\(disPoint)")
                
                var elementDis = Element(type: faceBuilder.ELEMENT_DIGITAL_DISTANCE, isAlpha: 1)
                elementDis.setElementData(point: disPoint, size: disRes.imageSize, ignoreBlack: kNotSupport2D_IgnoreBlack, watchRes: disRes)
                elementDis.gravity = disGravity
                
                watchFaceElements.append(elementDis)
            }else if key.elementsEqual("Cal"){
                bleLog("Cal is \(value)")
                // 在资源文件中, 颜色的索引
                let colorNum = getColorNumber(itemColor)
                let point :CGPoint = dataSourceArray["Cal"] as! CGPoint

                // 卡路里  支持2D  ignoreBlack使用1, 否则使用0
                let calRes = self.viewModel.getImageBufferArray(.CALORIES, false, colorNum)

                var elementCal = Element(type: faceBuilder.ELEMENT_DIGITAL_CALORIE, isAlpha: 1)
                elementCal.setElementData(point: point, size: calRes.imageSize, ignoreBlack: kNotSupport2D_IgnoreBlack, watchRes: calRes)
                elementCal.gravity = calGravity
                watchFaceElements.append(elementCal)

            }else if key.elementsEqual("PointerNumber"){
                bleLog("PointerNumber is \(value)")
                let tempNum = dataSourceArray["PointerNumber"] as! String

                guard var index = Int(tempNum) else {
                    bleLog("获取指针转换失败")
                    return
                }

                // 支持2D的指针索引和不支持的有区别, 支持2D的是从0开始的
                index -= 1
                if index < 0 {
                    index = 0
                }

                guard let pinitGroup = self.viewModel.getPointerImage(index, isPNG: true) else {

                    // 这里代表获取指针失败, 需要提示用户
                    bleLog("获取指针数据失败, 需要提示用户")
                    return
                }


            
                for index in 0..<3{
                    
                    var newElement: Element?
                    
                    switch index {
                    case 0:
                        newElement = getPointElement(type: faceBuilder.ELEMENT_NEEDLE_HOUR, isAlpha: 1)
                        newElement?.setElementForPointerData(isPoint: true, rawSize: pinitGroup.hourRes.rawImageSize, size: pinitGroup.hourRes.imageSize, watchRes: pinitGroup.hourRes)
                        break
                    case 1:
                        newElement = getPointElement(type: faceBuilder.ELEMENT_NEEDLE_MIN, isAlpha: 1)
                        newElement?.setElementForPointerData(isPoint: true, rawSize: pinitGroup.minRes.rawImageSize, size: pinitGroup.minRes.imageSize, watchRes: pinitGroup.minRes)
                        break
                    case 2:
                        newElement = getPointElement(type: faceBuilder.ELEMENT_NEEDLE_SEC, isAlpha: 1)
                        newElement?.setElementForPointerData(isPoint: true, rawSize: pinitGroup.secRes.rawImageSize, size: pinitGroup.secRes.imageSize, watchRes: pinitGroup.secRes)
                        break
                    default:
                        break
                    }
                    
                    newElement?.gravity = pointGravity
                    newElement?.ignoreBlack = UInt8(1)  // 指针, 不支持2D  ignoreBlack应该使用固定值 1
                    newElement?.x = bgFrame.width / 2
                    newElement?.y = bgFrame.height / 2
                    newElement?.imageCount = UInt8(1)
                    
                    if let tempEle = newElement {
                        watchFaceElements.append(tempEle)
                    }
                }
            }
        }

        if watchFaceElements.count > 0{
            
            #warning("2D accelerated devices are not supported, you should use the faceBuilder.BMP_565 parameter")
            // 不支持2D加速设备, 应该使用 faceBuilder.BMP_565 参数
            // 2D accelerated devices are not supported, you should use the faceBuilder.BMP_565 parameter
            let sendData = buildWatchFace(watchFaceElements, watchFaceElements.count, Int32(faceBuilder.BMP_565))
            bleLog("不支持2D加速设备, bin文件大小 - \(sendData.toData().count)")
            //if timeAuto == nil{
            //    timeAuto = Timer.scheduledTimer(withTimeInterval: TimeInterval(10), repeats: true, block: { _ in
            //        self.timeAutoCount += 10
            //        if self.timeAutoCount >= 60{
            //            bleLog("一分钟没有新进度取消同步")
            //            self.doneAction(false)
            //        }
            //    })
            //}
            if mBleConnector.sendStream(.WATCH_FACE, sendData.toData(),watchFaceIdNum){
                bleLog("sendStream - WATCH_FACE")
            }

        }
    }
    
    private func getPointElement(type: Int, isAlpha: UInt8) -> Element {
        
        let newElementModel = Element(type: type, isAlpha: isAlpha)
        
        return newElementModel
    }
    
    func createBinForBMP_File(_ dataSourceArray: [String:Any], isFixCoordinate: Bool, bgFrame: WatchFaceRect, pvFrame: WatchFaceRect){
        
        //固件坐标
        var bkGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_CENTER)//背景图
        var ylGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_CENTER)//预览图
        let apmGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//am pm
        let hourGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//hour
        let dayGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//Day
        let minGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//min
        let monthGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//month
        let weekSymGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//weekSym
        let weekDayGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)//weekDay
        var weekGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_TOP)//week
        var stepGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_CENTER)//step
        var hrGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_CENTER)
        var disGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_CENTER)
        var calGravity = UInt8(faceBuilder.GRAVITY_X_CENTER|faceBuilder.GRAVITY_Y_CENTER)
        let pointGravity = UInt8(faceBuilder.GRAVITY_X_LEFT|faceBuilder.GRAVITY_Y_TOP)
        
        
        //MTK 平台默认为0
        var IgnoreBlack = UInt8(0)//默认为0 , bmp相关的图片用1
        
        //Realtek需要修正坐标参数
        if isFixCoordinate {
            bkGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_CENTER_R)
            ylGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_CENTER_R)
            weekGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_TOP)
            stepGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_CENTER_R)
            hrGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_CENTER_R)
            disGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_CENTER_R)
            calGravity = UInt8(faceBuilder.GRAVITY_X_CENTER_R|faceBuilder.GRAVITY_Y_CENTER_R)
            
            IgnoreBlack = UInt8(1)
        }
        
        
        
        var watchFaceElements :[Element] = []
        
        
        //背景、预览处理
        var elementBg :Element = Element(type: faceBuilder.ELEMENT_BACKGROUND, isAlpha: 0)
        elementBg.w = bgFrame.width
        elementBg.h = bgFrame.height
        elementBg.gravity = bkGravity
        elementBg.ignoreBlack = isSupp2D ? 4:0 //支持2D使用4, 背景缩略图固定为0
        elementBg.x = bgFrame.x
        elementBg.y = bgFrame.y
        //newElement.bottomOffset = 0
        //newElement.leftOffset = 0
        elementBg.imageCount = UInt8(1)
        // 背景二进制数据
        var bgByte = Data()
        if isSupp2D {
            let pngData = image240?.pngData()!
            let newByteBg = ImageConverTools.getImgWith(UIImage(data: pngData!)!, isAlpha: false)
            bgByte = self.viewModel.byteAlignment(newByteBg)
        } else {
            //buffer每个元素大小
            bgByte = getBackBuffer(image240!)
            if isBmpResoure {
                let image16 :Data = NewImageHelper.convertUIImage(toBitmapRGB565: image240)! as Data
                //小端序修改为大端序
                var index = 0
                bgByte.removeAll()
                while index<image16.count{
                    let item1 = image16[index]
                    let item2 = image16[index+1]
                    bgByte.append(item2)
                    bgByte.append(item1)
                    index += 2
                }
            }
        }
        elementBg.imageSizes = [UInt32(bgByte.count)]
        elementBg.imageBuffer = bgByte
        watchFaceElements.append(elementBg)
        
        
        // 预览图
        var elementPrevie = Element(type: faceBuilder.ELEMENT_PREVIEW, isAlpha: 0)
        elementPrevie.w = pvFrame.width
        elementPrevie.h = pvFrame.height
        elementPrevie.gravity = ylGravity
        elementPrevie.ignoreBlack = isSupp2D ? 4:0 //支持2D使用4, 背景缩略图固定为0
        elementPrevie.x = pvFrame.x
        elementPrevie.y = pvFrame.y
        //elementPrevie.bottomOffset = 0
        //elementPrevie.leftOffset = 0
        elementPrevie.imageCount = UInt8(1)
        // 预览图二进制数据
        var pvByte = getBackBuffer(image150!)
        if isBmpResoure {
            let image16 :Data = NewImageHelper.convertUIImage(toBitmapRGB565: image150)! as Data
            var index = 0
            pvByte.removeAll()
            while index<image16.count{
                let item1 = image16[index]
                let item2 = image16[index+1]
                pvByte.append(item2)
                pvByte.append(item1)
                index += 2
            }
        }
        elementPrevie.imageSizes = [UInt32(pvByte.count)] //buffer每个元素大小
        elementPrevie.imageBuffer = pvByte
        watchFaceElements.append(elementPrevie)
        
        //处理其他元素
        let timeColor = UIColor.white
        let itemColor = UIColor.white
        var itemC = "_"
        var imageType = "png"
        if isBmpResoure {
            itemC = "_bmp_"
            imageType = "bmp"
        }
        
        let colorNum = 0 // 颜色索引, 用于获取资源图片
        for (key,value) in dataSourceArray {
            
            if key.elementsEqual("TimeAM"){
                bleLog("TimeAM is \(value)")
                
                let point :CGPoint = dataSourceArray["TimeAM"] as! CGPoint

                //am
                let ampmRes = self.viewModel.getImageBmpBufferArray(.AMPM, colorNum)
                //hour
                let hourRes = self.viewModel.getImageBmpBufferArray(.HOUR, colorNum)
                // min
                let minRes = self.viewModel.getImageBmpBufferArray(.MINUTES, colorNum)
                
                // month
                let monthRes = self.viewModel.getImageBmpBufferArray(.MONTH, colorNum)
                let timeWeekMonthSize = monthRes.imageSize
                // day
                let dayRes = self.viewModel.getImageBmpBufferArray(.DAY, colorNum)
                let timeWeekDaySize = dayRes.imageSize
                // week
                let weekRes = self.viewModel.getImageBmpBufferArray(.WEAK, colorNum)
                let timeWeekSize = weekRes.imageSize
                
                
                // 日期之间的分割线
                let dateSymbolRes = self.viewModel.getImageBmpBufferArray(.dateSymbol, colorNum)
                let dateSySize = dateSymbolRes.imageSize
                // 星期之间的分割线
                let weekSymbolRes = self.viewModel.getImageBmpBufferArray(.weakSymbol, colorNum)
                let weekSymSize = weekSymbolRes.imageSize

                
                //point
                let hourY = point.y+ampmRes.imageSize.height+2
                let weekY = point.y+ampmRes.imageSize.height+hourRes.imageSize.height+4
                let hourPoint = CGPoint(x: point.x-((hourRes.imageSize.width*2)+(minRes.imageSize.width*2)+dateSySize.width+4), y: hourY)
                let dateSyPoint = CGPoint(x: point.x-((minRes.imageSize.width*2)+dateSySize.width+2), y: hourY)
                let minPoint = CGPoint(x: point.x-(minRes.imageSize.width*2), y: hourY)
                
                
                // 月 / 日, 数据增加偏移值, 在F11上面周一, 周三, 周日出现日期和星期太靠近
                let monthEleOffset:CGFloat = 10
                let monthPoint = CGPoint(x: point.x-((timeWeekMonthSize.width*2)+(timeWeekDaySize.width*2)+timeWeekSize.width+weekSymSize.width+6) - monthEleOffset, y: weekY)
                let monthSyPoint = CGPoint(x: point.x-((timeWeekDaySize.width*2)+timeWeekSize.width+weekSymSize.width+4) - monthEleOffset, y: weekY)
                let dayPoint = CGPoint(x: point.x-((timeWeekDaySize.width*2)+timeWeekSize.width+2) - monthEleOffset, y: weekY)
                
                var weekPoint = CGPoint(x: point.x-timeWeekSize.width, y: weekY)
                let imageWidth :CGFloat = isBmpResoure ? 1.0:2.0
                if isFixCoordinate {
                    weekPoint = CGPoint(x: point.x-(timeWeekSize.width*0.5), y: weekY)
                }
                
                
                
                // am pm
                //let ampmImgArray = self.viewModel.identifyItemsColor(.AMPM, colorNum)
                //let ampmRes = self.viewModel.getImageBufferArray(ampmImgArray, .AMPM)
                let tempAmPmPoint = CGPoint(x: point.x-ampmRes.imageSize.width, y: point.y)
                
                
                var amElement = Element(type: faceBuilder.ELEMENT_DIGITAL_AMPM, isAlpha: 0)
                amElement.setElementData(point: tempAmPmPoint, size: ampmRes.imageSize, ignoreBlack: Int(IgnoreBlack), watchRes: ampmRes)
                amElement.gravity = apmGravity
                
                watchFaceElements.append(amElement)


                // hour
                //let hourImgArray = self.viewModel.identifyItemsColor(.HOUR, colorNum)
                //let hourRes = self.viewModel.getImageBufferArray(hourImgArray, .HOUR)

                let tempHourSize = CGSize(width: hourRes.imageSize.width * imageWidth, height: hourRes.imageSize.height)
                
                var hourElement = Element(type: faceBuilder.ELEMENT_DIGITAL_HOUR, isAlpha: 0)
                hourElement.setElementData(point: hourPoint, size: tempHourSize, ignoreBlack: Int(IgnoreBlack), watchRes: hourRes)
                hourElement.gravity = hourGravity
                
                watchFaceElements.append(hourElement)


                // 日期之间的分割线
                //let dateSymbolImgArray = self.viewModel.identifyItemsColor(.dateSymbol, colorNum)
                //let dateSymbolRes = self.viewModel.getImageBufferArray(dateSymbolImgArray, .dateSymbol)

                let tempdateSySize = CGSize(width: dateSymbolRes.imageSize.width * imageWidth, height: dateSymbolRes.imageSize.height)
                
                var dateSyElement = Element(type: faceBuilder.ELEMENT_BACKGROUND, isAlpha: 0)
                dateSyElement.setElementData(point: dateSyPoint, size: tempdateSySize, ignoreBlack: Int(IgnoreBlack), watchRes: dateSymbolRes)
                dateSyElement.gravity = dayGravity
                
                watchFaceElements.append(dateSyElement)



                // min
                //let minImgArray = self.viewModel.identifyItemsColor(.MINUTES, colorNum)
                //let minRes = self.viewModel.getImageBufferArray(minImgArray, .MINUTES)

                let tempMinSySize = CGSize(width: minRes.imageSize.width * imageWidth, height: minRes.imageSize.height)
                
                var minElement = Element(type: faceBuilder.ELEMENT_DIGITAL_MIN, isAlpha: 0)
                minElement.setElementData(point: minPoint, size: tempMinSySize, ignoreBlack: Int(IgnoreBlack), watchRes: minRes)
                minElement.gravity = minGravity
                watchFaceElements.append(minElement)



                // month
                //let monthImgArray = self.viewModel.identifyItemsColor(.MONTH, colorNum)
                //let monthRes = self.viewModel.getImageBufferArray(monthImgArray, .MONTH)
                
                let tempMonthSize = CGSize(width: monthRes.imageSize.width * imageWidth, height: monthRes.imageSize.height)
                
                var monthElement = Element(type: faceBuilder.ELEMENT_DIGITAL_MONTH, isAlpha: 0)
                monthElement.setElementData(point: monthPoint, size: tempMonthSize, ignoreBlack: Int(IgnoreBlack), watchRes: monthRes)
                monthElement.gravity = monthGravity
                watchFaceElements.append(monthElement)
                
                

                // 日期之间的分割线
                //let weekSymbolImgArray = self.viewModel.identifyItemsColor(.weakSymbol, colorNum)
                //let weekSymbolRes = self.viewModel.getImageBufferArray(weekSymbolImgArray, .weakSymbol)

                var weekSymElement = Element(type: faceBuilder.ELEMENT_BACKGROUND, isAlpha: 0)
                weekSymElement.setElementData(point: monthSyPoint, size: weekSymbolRes.imageSize, ignoreBlack: Int(IgnoreBlack), watchRes: weekSymbolRes)
                weekSymElement.gravity = weekSymGravity
                
                watchFaceElements.append(weekSymElement)



                // day
                //let dayImgArray = self.viewModel.identifyItemsColor(.DAY, colorNum)
                //let dayRes = self.viewModel.getImageBufferArray(dayImgArray, .DAY)
                
                let tempDaySize = CGSize(width: dayRes.imageSize.width * imageWidth, height: dayRes.imageSize.height)

                var dayElement = Element(type: faceBuilder.ELEMENT_DIGITAL_DAY, isAlpha: 0)
                dayElement.setElementData(point: dayPoint, size: tempDaySize, ignoreBlack: Int(IgnoreBlack), watchRes: dayRes)
                dayElement.gravity = weekDayGravity
                watchFaceElements.append(dayElement)



                // week
                //let weekImgArray = self.viewModel.identifyItemsColor(.WEAK, colorNum)
                //let weekRes = self.viewModel.getImageBufferArray(weekImgArray, .DAY)

                var weekElement = Element(type: faceBuilder.ELEMENT_DIGITAL_WEEKDAY, isAlpha: 0)
                weekElement.setElementData(point: weekPoint, size: weekRes.imageSize, ignoreBlack: Int(IgnoreBlack), watchRes: weekRes)
                weekElement.gravity = weekGravity
                watchFaceElements.append(weekElement)
                
            }else if key.elementsEqual("Step") {
                bleLog("Step is \(value)")
                
                let point :CGPoint = dataSourceArray["Step"] as! CGPoint
                // 获取资源图片相关数据
                let stepRes = self.viewModel.getImageBmpBufferArray(.STEP, colorNum)
                print("测试数据stepRes:\(stepRes)")
                
                
                
                var elementStep = Element(type: faceBuilder.ELEMENT_DIGITAL_STEP, isAlpha: 0)
                elementStep.setElementData(point: point, size: stepRes.imageSize, ignoreBlack: Int(IgnoreBlack), watchRes: stepRes)
                elementStep.gravity = stepGravity
                
                watchFaceElements.append(elementStep)
            } else if key.elementsEqual("HR") {
                bleLog("HR is \(value)")
                
                let point :CGPoint = dataSourceArray["HR"] as! CGPoint
                let hrRes = self.viewModel.getImageBmpBufferArray(.HEART_RATE, colorNum)
                
                var elementHR = Element(type: faceBuilder.ELEMENT_DIGITAL_HEART, isAlpha: 0)
                elementHR.setElementData(point: point, size: hrRes.imageSize, ignoreBlack: Int(IgnoreBlack), watchRes: hrRes)
                elementHR.gravity = hrGravity
                watchFaceElements.append(elementHR)
            } else if key.elementsEqual("Dis") {
                bleLog("Dis is \(value)")
                
                let rawDisPoint :CGPoint = dataSourceArray["Dis"] as! CGPoint
                let disRes = self.viewModel.getImageBmpBufferArray(.DISTANCE, colorNum)
                let disPoint = CGPoint(x: rawDisPoint.x-disRes.imageSize.width, y: rawDisPoint.y)
                
                var elementDis = Element(type: faceBuilder.ELEMENT_DIGITAL_DISTANCE, isAlpha: 0)
                elementDis.setElementData(point: disPoint, size: disRes.imageSize, ignoreBlack: Int(IgnoreBlack), watchRes: disRes)
                elementDis.gravity = disGravity
                
                watchFaceElements.append(elementDis)
            } else if key.elementsEqual("Cal") {
                bleLog("Cal is \(value)")
                let point :CGPoint = dataSourceArray["Cal"] as! CGPoint
                
                // 卡路里  支持2D  ignoreBlack使用4;   
                let calRes = self.viewModel.getImageBmpBufferArray(.CALORIES, colorNum)
                
                var elementCal = Element(type: faceBuilder.ELEMENT_DIGITAL_CALORIE, isAlpha: 0)
                elementCal.setElementData(point: point, size: calRes.imageSize, ignoreBlack: Int(IgnoreBlack), watchRes: calRes)
                elementCal.gravity = calGravity
                watchFaceElements.append(elementCal)
            } else if key.elementsEqual("PointerNumber") {
                bleLog("PointerNumber is \(value)")
                
                let selNum :String = dataSourceArray["PointerNumber"] as! String
                
                guard var index = Int(selNum) else {
                    bleLog("获取指针转换失败")
                    return
                }
                
                
                index -= 1
                if index < 0 {
                    index = 0
                }
                
                guard let pinitGroup = self.viewModel.getPointerImage(index, isPNG: false) else {

                    // 这里代表获取指针失败, 需要提示用户
                    bleLog("获取指针数据失败, 需要提示用户")
                    return
                }
                
                for index in 0..<3{
                    
                    var newElement: Element?
                    
                    switch index {
                    case 0:
                        newElement = getPointElement(type: faceBuilder.ELEMENT_NEEDLE_HOUR, isAlpha: 0)
                        newElement?.setElementForPointerData(isPoint: true, rawSize: pinitGroup.hourRes.rawImageSize, size: pinitGroup.hourRes.imageSize, watchRes: pinitGroup.hourRes)
                        break
                    case 1:
                        newElement = getPointElement(type: faceBuilder.ELEMENT_NEEDLE_MIN, isAlpha: 0)
                        newElement?.setElementForPointerData(isPoint: true, rawSize: pinitGroup.minRes.rawImageSize, size: pinitGroup.minRes.imageSize, watchRes: pinitGroup.minRes)
                        break
                    case 2:
                        newElement = getPointElement(type: faceBuilder.ELEMENT_NEEDLE_SEC, isAlpha: 0)
                        newElement?.setElementForPointerData(isPoint: true, rawSize: pinitGroup.secRes.rawImageSize, size: pinitGroup.secRes.imageSize, watchRes: pinitGroup.secRes)
                        break
                    default:
                        break
                    }
                    
                    newElement?.gravity = pointGravity
                    newElement?.ignoreBlack = IgnoreBlack
                    newElement?.x = bgFrame.width / 2
                    newElement?.y = bgFrame.height / 2
                    newElement?.imageCount = UInt8(1)
                    
                    if let tempElement = newElement {
                        watchFaceElements.append(tempElement)
                    }
                }
            }
        }
        
        
        
        if watchFaceElements.count > 0{
            let sendData = buildWatchFace(watchFaceElements, watchFaceElements.count, Int32(faceBuilder.BMP_565))
            bleLog("bin文件大小 - \(sendData.toData().count)")
            if mBleConnector.sendStream(.WATCH_FACE, sendData.toData()){
                bleLog("sendStream - WATCH_FACE")
            }

        }
    }
    
    func dialCustomSenderImageFormat()->Bool{
        //true 表示传输协议用PNG false 表示BMP Realtek必须用BMP
//        var isImage = true
//        if BleCache.shared.mPlatform ==  BleDeviceInfo.PLATFORM_REALTEK{
//            isImage = false
//        }
//        return isImage
//
        
        return false
    }
    
    func buildWatchFace(_ elements:[Element],_ elementCount:Int,_ imageFormat:Int32) ->BleWatchFaceBin{
        
        var num = 0
        for item in elements {
            num += Int(item.imageCount)
        }
        imageCountStart = num

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

        let colorNum : Int  = getColorNumber(idColor)
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
                if BleCache.shared.mWatchFaceType == BleDeviceInfo.WATCH_FACE_320x363 && index == imageNumber-1{
                    //363表盘数据需要手动增加小数点
                    let image0 = getImageDeviceType()+"items"+"\(colorNum)"+itemC+"\(10)"
                    imagArray.add(image0)
                }
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
    
    private func identifyItemsColor2(_ type: WatchElementType, _ colorNum: Int) -> [String] {
        
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
        //UIGraphicsBeginImageContextWithOptions(bgView.bounds.size,true, UIScreen.main.scale)
        //bgView.layer.render(in: UIGraphicsGetCurrentContext()!)
        //let image = UIGraphicsGetImageFromCurrentImageContext()
        //UIGraphicsEndImageContext()
        var bgWidth :CGFloat = 0
        var bgHeight :CGFloat = 0
        let isSquare = dialCustomIsRound()
        switch BleCache.shared.mWatchFaceType {
        case BleDeviceInfo.WATCH_FACE_320x363:
            bgWidth  = 320
            bgHeight = 363
            break
        case BleDeviceInfo.WATCH_FACE_REALTEK_SQUARE_240x280,BleDeviceInfo.WATCH_FACE_REALTEK_SQUARE_240x280_2,BleDeviceInfo.WATCH_FACE_REALTEK_SQUARE_240x280_19,BleDeviceInfo.WATCH_FACE_REALTEK_SQUARE_240x280_20,BleDeviceInfo.WATCH_FACE_REALTEK_SQUARE_240x295_21:
            bgWidth  = 240
            bgHeight = 280
            break
        case BleDeviceInfo.WATCH_FACE_REALTEK_ROUND_360x360:
            bgWidth  = 360
            bgHeight = 360
            break
        case BleDeviceInfo.WATCH_FACE_REALTEK_ROUND_454x454:
            bgWidth  = 454
            bgHeight = 454
            break
        case BleDeviceInfo.WATCH_FACE_SERVER:
            let array = getWatchDialBKWidthHeight()
            bgWidth  = CGFloat(array[0])
            bgHeight = CGFloat(array[1])
            break
        default:
            bgWidth  = 240
            bgHeight = 240
            break
        }
        
        // 截图, 修改图片大小
        //let newImage  = image?.resize(to: CGSize(width: bgWidth, height: bgHeight))
        let newImage = self.screenshot(newSize: CGSize(width: bgWidth, height: bgHeight))
        
        var newImage1:UIImage?
        if isSquare == false {
            
            if BleCache.shared.mWatchFaceType == BleDeviceInfo.WATCH_FACE_320x363{
                var newIMA : UIImage?
                let newData = compressWithMaxCount(origin: newImage!, maxCount: 8192, newSize: CGSize(width: bgWidth, height: bgHeight-20))
                if newData!.count>10 {
                    newIMA = UIImage.init(data: newData!)
                }
                let bkImage = UIImage().createImageWithColor(UIColor.clear,CGRect(x: 0, y: 0, width: bgWidth, height: bgHeight+22))
                newImage1 =  composeImageWithLogo(bgImage: bkImage, imageRect: [CGRect(x: 0, y: 22, width: bgWidth, height: bgHeight)], images: [newIMA!])
            }else{
                let newData = compressWithMaxCount(origin: newImage!, maxCount: 8192, newSize: CGSize(width: bgWidth, height: bgHeight))
                if newData!.count>10 {
                    newImage1 = UIImage.init(data: newData!)
                }
            }
        }
        
        
        
        //let newImage  = image?.resize(to: CGSize(width: bgWidth, height: bgHeight))
        timeSymView.removeFromSuperview()
        dateSymView.removeFromSuperview()
        //square watch face return newImage
        //return maskRoundedImage(image: newImage!, radius: CGFloat(bgWidth/2))
        
        if isSquare {
            return maskRoundedImage(image: newImage!, radius: CGFloat(bgWidth/2))
        }else{
            return newImage1!
        }
    }

    //两图合并
    func composeImageWithLogo( bgImage: UIImage, imageRect: [CGRect],images:[UIImage]) -> UIImage {
        bleLog("---两图合并----")
        //以bgImage的图大小为底图
        let imageRef = bgImage.cgImage
        let w: CGFloat = CGFloat((imageRef?.width)!)
        let h: CGFloat = CGFloat((imageRef?.height)!)
        //以1.png的图大小为画布创建上下文
        UIGraphicsBeginImageContext(CGSize(width: w, height: h))
        bgImage.draw(in: CGRect(x: 0, y: 0, width: w, height: h))
        //先把1.png 画到上下文中
        for i in 0..<images.count {
            images[i].draw(in: CGRect(x: imageRect[i].origin.x,
                                      y: imageRect[i].origin.y,
                                      width: imageRect[i].size.width,
                                      height:imageRect[i].size.height))
        }
        //再把小图放在上下文中
        let resultImg: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        //从当前上下文中获得最终图片
        UIGraphicsEndImageContext()
        return resultImg!
        
    }
    
    func getThumbnailImage() -> UIImage{//Thumbnail preview
        
        var previewWidth :CGFloat = 0
        var previewHeight :CGFloat = 0
        
        let isSquare = dialCustomIsRound() // 圆形
        switch BleCache.shared.mWatchFaceType {
        case BleDeviceInfo.WATCH_FACE_320x363:
            previewWidth  = 160
            previewHeight = 180
            break
        case BleDeviceInfo.WATCH_FACE_REALTEK_SQUARE_240x280,BleDeviceInfo.WATCH_FACE_REALTEK_SQUARE_240x280_2,BleDeviceInfo.WATCH_FACE_REALTEK_SQUARE_240x280_19,BleDeviceInfo.WATCH_FACE_REALTEK_SQUARE_240x280_20,BleDeviceInfo.WATCH_FACE_REALTEK_SQUARE_240x295_21:
            previewWidth  = 150
            previewHeight = 170
            break
        case BleDeviceInfo.WATCH_FACE_REALTEK_ROUND_360x360:
            previewWidth  = 225
            previewHeight = 225
            break
        case BleDeviceInfo.WATCH_FACE_REALTEK_RACKET:
            previewWidth  = 106
            previewHeight = 106
            break
        case BleDeviceInfo.WATCH_FACE_REALTEK_ROUND_454x454:
            previewWidth  = 280
            previewHeight = 280
            break
        case BleDeviceInfo.WATCH_FACE_SERVER:
            let array = getThumbnailImageWidthHeight()
            previewWidth  = CGFloat(array[0])
            previewHeight = CGFloat(array[1])
            break
        default:
            previewWidth  = 150
            previewHeight = 150
            break
        }
        
        //UIGraphicsBeginImageContextWithOptions(bgView.bounds.size,true, UIScreen.main.scale)
        //bgView.layer.render(in: UIGraphicsGetCurrentContext()!)
        //let image = UIGraphicsGetImageFromCurrentImageContext()
        //UIGraphicsEndImageContext()
        //let newImage  = image?.resize(to: CGSize(width: previewWidth, height: previewHeight))
        ////square watch face return newImage
        //return maskRoundedImage(image: newImage!, radius: previewWidth/2)
        
        
        let newImage = self.screenshot(newSize: CGSize(width: previewWidth, height: previewHeight))
        var newImage1:UIImage?
        if isSquare {
            newImage1 = maskRoundedImage(image: newImage!, radius: previewWidth/2)
        }else{
            let newData = compressWithMaxCount(origin: newImage!, maxCount: 4608, newSize: CGSize(width: previewWidth, height: previewHeight))
            if newData!.count>10 {
                newImage1 = UIImage.init(data: newData!)
            }
            return newImage1!
        }
        
        return newImage1!
    }
    
    //方形表盘压缩
    func compressWithMaxCount(origin:UIImage,maxCount:Int,newSize:CGSize) -> Data? {

        var compression:CGFloat = 1
        guard var data = origin.jpegData(compressionQuality: compression) else { return nil }
        if data.count <= maxCount {
            return data
        }
        var max:CGFloat = 1,min:CGFloat = 0.8//最小0.8
        for _ in 0..<6 {//最多压缩6次
            compression = (max+min)/2
            if let tmpdata = origin.jpegData(compressionQuality: compression) {
                data = tmpdata
            } else {
                return nil
            }
            if data.count <= maxCount {
                return data
            } else {
                max = compression
            }
        }
//        //压缩分辨率
        guard var resultImage = UIImage(data: data) else { return nil }
        var lastDataCount:Int = 0
        while data.count > maxCount && data.count != lastDataCount {
            lastDataCount = data.count
            let size = CGSize(width: newSize.width, height: newSize.height)
            UIGraphicsBeginImageContextWithOptions(CGSize(width: CGFloat(Int(size.width)), height: CGFloat(Int(size.height))), true, 1)//防止黑边
            resultImage.draw(in: CGRect(origin: .zero, size: size))//比转成Int清晰
            if let tmp = UIGraphicsGetImageFromCurrentImageContext() {
                resultImage = tmp
                UIGraphicsEndImageContext()
            } else {
                UIGraphicsEndImageContext()
                return nil
            }
            if let tmpdata = resultImage.jpegData(compressionQuality: compression) {
                data = tmpdata
            } else {
                return nil
            }
        }
        return data
    }
    
    /// 截图, 截取指定View 生成Image
    private func screenshot(newSize: CGSize) -> UIImage? {
        
        /**
         注意: 这个为新的方法, 旧的方法是使用的  bgView来处理的, 这个方法会重新布局子视图, 导致表盘控件错乱
         */
        //    UIGraphicsBeginImageContextWithOptions(bgView.bounds.size,true, UIScreen.main.scale)
        //    bgView.layer.render(in: UIGraphicsGetCurrentContext()!)
        UIGraphicsBeginImageContextWithOptions(bgView.bounds.size,true, UIScreen.main.scale)
        bgView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let newImage  = image?.resize(to: newSize)
        
        return newImage
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
        var timeOffset :CGFloat = 0.0 //x 值
        var timeOffset_Y: CGFloat = 0.0 //y
        
        //步数
        var OffsetStep_X :CGFloat = 0.0 //y
        var OffsetStep_Y :CGFloat = 0.0 //y
        
        
        // 心率
        var OffsetHR_X :CGFloat = 0.0 // X
        var OffsetHR_Y :CGFloat = 0.0 // Y
        
        
        var OffsetDisX :CGFloat = 0.0 // X
        var OffsetDisY :CGFloat = 0.0 // Y
        
        var OffsetCalX :CGFloat = 10.0 // X
        var OffsetCalY :CGFloat = 0.0 // Y
        
        var stepImageHeight :CGFloat = 75.0
        var calImageHeight :CGFloat = 55.0
        var dispImageHeight :CGFloat = 55.0
        var hrImageHeight :CGFloat = 55.0
        var stepImageWidth :CGFloat = 40.0
        var calImageWidth :CGFloat = 40.0
        var dispImageWidth :CGFloat = 40.0
        var hrImageWidth :CGFloat = 40.0
        //计算比例尺
        var scaleW = bgView.bounds.size.width/240
        var scaleH = bgView.bounds.size.height/240
        

        print("当前屏幕类型mWatchFaceType:\(BleCache.shared.mWatchFaceType)")
        switch BleCache.shared.mWatchFaceType {
        case BleDeviceInfo.WATCH_FACE_240_240:
            scaleW = bgView.bounds.size.width/240
            scaleH = bgView.bounds.size.height/240
            break
        case BleDeviceInfo.WATCH_FACE_F3:
            scaleW = bgView.bounds.size.width/240
            scaleH = bgView.bounds.size.height/240
            break
        case BleDeviceInfo.WATCH_FACE_REALTEK_ROUND:
            
            // 已经经过验证 ---
            scaleW = bgView.bounds.size.width/240
            scaleH = bgView.bounds.size.height/240
            //Offset = 15.0
            OffsetHR_Y = 15
            OffsetCalY = 30
            
            OffsetDisX = 25.0
            OffsetDisY = 25.0
            break
        case BleDeviceInfo.WATCH_FACE_REALTEK_ROUND_240x240:
            
            //#warning("正在对接设备")
            // 已经经过验证 ---
            scaleW = bgView.bounds.size.width/240
            scaleH = bgView.bounds.size.height/240
            //Offset = 15
            OffsetHR_Y = 15
            OffsetCalY = 25
            OffsetDisY = 25
            //OffsetDis = 15.0
            OffsetDisX = 30
            break
        case BleDeviceInfo.WATCH_FACE_320x363:
            scaleW = bgView.bounds.size.width/320
            scaleH = bgView.bounds.size.height/363
            //Offset = 22.0
            OffsetHR_Y = 22
            OffsetCalY = 32
            OffsetDisY = 32
            break
        case BleDeviceInfo.WATCH_FACE_REALTEK:
            scaleW = bgView.bounds.size.width/240
            scaleH = bgView.bounds.size.height/240
            //Offset = 15
            OffsetHR_Y = 15
            OffsetCalY = 25
            OffsetDisY = 25
            //OffsetDis = 15.0
            OffsetDisX = 30
            break
        case BleDeviceInfo.WATCH_FACE_REALTEK_SQUARE_240x240:
            scaleW = bgView.bounds.size.width/240
            scaleH = bgView.bounds.size.height/240
            break
        case BleDeviceInfo.WATCH_FACE_REALTEK_ROUND_360x360:
            
            //
            // 已经经过验证 ---
            scaleW = bgView.bounds.size.width/360
            scaleH = bgView.bounds.size.height/360
            //Offset = 15
            OffsetHR_Y = 18
            OffsetCalY = 28
            OffsetDisY = 25
            //OffsetDis = 15.0
            OffsetDisX = 30
            
            // 还未调整好
            //if BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_R11 {
            //
            //    Offset = 10
            //    timeOffset = 10.0
            //}
            
            break
        case BleDeviceInfo.WATCH_FACE_REALTEK_SQUARE_240x280,BleDeviceInfo.WATCH_FACE_REALTEK_SQUARE_240x280_2,BleDeviceInfo.WATCH_FACE_REALTEK_SQUARE_240x280_19,BleDeviceInfo.WATCH_FACE_REALTEK_SQUARE_240x280_20,BleDeviceInfo.WATCH_FACE_REALTEK_SQUARE_240x295_21:
            scaleW = bgView.bounds.size.width/240
            scaleH = bgView.bounds.size.height/280

            // 已经经过验证 ---
            /// 修改时间x距离
            timeOffset = 0
            // 这个是用来表示数据的x轴偏移值, 例如步数, 心率, 距离, 卡路里数据值的x轴偏移
            OffsetStep_X = 5
            OffsetHR_X = 5
            // 步数的y轴偏移, 这个值, 仅仅对步数值有效, 其他无效
            //OffsetStep_Y = 0
            
            // 修改距离的y值
            //Offset = 15.0
            OffsetHR_Y = 15
            OffsetCalY = 30
            OffsetDisY = 25
            // 修改距离的x值
            //OffsetDis = 15.0
            OffsetDisX = 30
            break
        case BleDeviceInfo.WATCH_FACE_REALTEK_ROUND_CENTER_240x240:
            //Offset = 15
            OffsetHR_Y = 15
            OffsetCalY = 25
            OffsetDisY = 25
            //OffsetDis = 15.0
            break
        case BleDeviceInfo.WATCH_FACE_REALTEK_ROUND_454x454:
            
            // 已经经过验证 ---
            scaleW = bgView.bounds.size.width/454
            scaleH = bgView.bounds.size.height/454
            //Offset = 15
//            xOffset = 15.0
            OffsetHR_Y = 18
            
            OffsetDisY = 25
            OffsetCalY = 28
            //OffsetDis = 15
            OffsetDisX = 30
            OffsetHR_X = 5
            
            timeOffset = 35.0
            break
        case BleDeviceInfo.WATCH_FACE_SERVER:
            let array = getWatchDialBKWidthHeight()
            let aWidth = array[0]
            let aHeight = array[1]
            //scaleW = watchDial.bounds.size.width/CGFloat(aWidth)
            //scaleH = watchDial.bounds.size.height/CGFloat(aHeight)
            scaleW = bgView.bounds.size.width/CGFloat(aWidth)
            scaleH = bgView.bounds.size.height/CGFloat(aHeight)
            if dialCustomIs128(){
                //Offset = 15
                OffsetHR_Y = 15
                OffsetCalY = 25
                OffsetDisY = 25
                OffsetStep_Y = -5.0
                //OffsetDis = 15.0
                OffsetDisX = 30
            }else if BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_V2{
                //Offset = 15
                OffsetHR_Y = 15
                OffsetCalY = 25
                OffsetDisY = 25
                //OffsetDis = 15.0
                OffsetDisX = 30
            }else if dialCustomIsWristband(){
                
                // 已经通过验证--
                //Offset = 0.0
                OffsetHR_Y = 0.0
                OffsetCalX = 0
                OffsetCalY = 5
                
                OffsetDisX = 10
                OffsetDisY = 5
                
                stepImageHeight = 40.0
                calImageHeight = 40.0
                dispImageHeight = 40.0
                hrImageHeight = 40.0
                stepImageWidth = 30.0
                calImageWidth = 30.0
                dispImageWidth = 30.0
                hrImageWidth = 30.0
            }else if dialCustomIs320_320() {
                
                OffsetHR_X = 0
                //Offset = 15.0
                OffsetHR_Y = 15
                OffsetCalY = 16
                OffsetCalX = 0
                OffsetDisX = 13  // ==
                OffsetDisY = 16 // ==
            } else if dialCustomIs320_385() {
                // 需要注意, PROTOTYPE_F12Pro 屏幕是 320 X 385屏幕 由于没有资源, 只能使用 320x320
                OffsetHR_X = 0
                //Offset = 15.0
                OffsetHR_Y = 15
                OffsetCalY = 16
                OffsetCalX = 0
                OffsetDisX = 13  // ==
                OffsetDisY = 16 // ==
            }else if dialCustomIs368_448() {
                
                // 已经经过验证 ---
                OffsetHR_X = 0
                //Offset = 15.0
                OffsetHR_Y = 15
                // 卡路里
                OffsetCalX = 0
                OffsetCalY = 20
                // 距离
                OffsetDisX = 15
                OffsetDisY = 15
            }else if dialCustomIs240_286() {
                
                // 已经经过验证 ---
                OffsetHR_X = 0
                //Offset = 15.0
                OffsetHR_Y = 15
                // 卡路里
                OffsetCalX = 0
                OffsetCalY = 20
                // 距离
                OffsetDisX = 18
                OffsetDisY = 15
            }else if BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_HW01 ||
                            BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_A8 {
                // 已经经过验证 ---
                OffsetHR_X = 0
                //Offset = 15.0
                OffsetHR_Y = 15
                // 卡路里
                OffsetCalX = 0
                OffsetCalY = 20
                // 距离
                OffsetDisX = 18
                OffsetDisY = 15
            }else if BleCache.shared.mPrototype == BleDeviceInfo.PROTOTYPE_F2R_NEW {
                // F2R 设备修改下偏移值
                //Offset = 15.0
                OffsetHR_Y = 15
                OffsetCalY = 25
                OffsetDisY = 25
                //OffsetDis = 18.0
                OffsetDisX = 33
            } else if dialCustomIs240_240() {
                
                OffsetHR_Y = 5
                OffsetDisY = 5
                OffsetDisX = 15
                OffsetCalY = 10
                OffsetCalX = 5
            }else if dialCustomIs360_360() {
                timeOffset = 10
                timeOffset_Y = -10
                
                OffsetHR_Y = 8
                OffsetDisY = 8
                OffsetDisX = 13
                
                OffsetCalY = 10
                OffsetCalX = 3
            }else if dialCustomIs412_412() {
                timeOffset = 0
                timeOffset_Y = -10
                
                OffsetHR_Y = 8
                OffsetDisY = 8
                OffsetDisX = 13
                
                OffsetCalY = 10
                OffsetCalX = 3
            } else if dialCustomIs466_466() {
                // 这个屏幕和 WATCH_FACE_REALTEK_ROUND_454x454 差别10 可以参照
                // 已经经过验证 ---

                // 时间
                timeOffset = 10
                timeOffset_Y = -10
                
                // 步数
                //OffsetStep_X = 0
                OffsetStep_Y = -5
                
                OffsetHR_X = 0
                OffsetHR_Y = 15
                
                // 距离
                OffsetDisX = 15
                OffsetDisY = 15
                
                OffsetCalX = 3
                OffsetCalY = 15
            }else if dialCustomIs356_400() {
                
                OffsetDisX = 15
                OffsetDisY = 18
                
                OffsetHR_X = 0
                OffsetHR_Y = 13
                
                OffsetCalX = 0
                OffsetCalY = 18
            }else if dialCustomIs410_502() {
                
                OffsetDisX = 15
                OffsetDisY = 18
                
                OffsetHR_X = 0
                OffsetHR_Y = 13
                
                OffsetCalX = 0
                OffsetCalY = 18
            }
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
