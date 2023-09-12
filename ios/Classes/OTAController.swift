import Foundation
import UIKit
import CoreBluetooth
import iOSDFULibrary


class OTAController {

    let dataSoure :[String] = ["Realtek","MTK","Goodix","Nordic","JL(杰里)"]

    var filePath : String = "" //升级文件路径
//    let ROTA = RealtekOTA.sharedInstance()
    var isReadyROTA :Bool = false //wait for the Bluetooth connection to complete
    var refreshUI : Bool = false  //mark upgrade file type
    var upgradeType : Int = -1
    //goodix SDK
//    let goodix = GoodixUpgrade.shared()
    //MTK
//    let mtkOTA = MTKOTA.sharedInstance()
//    var mtkDevice = MTKDeviceInfo()
    /**
     产品调整,屏蔽汇顶、MTK2个平台OTA代码
     如需测试重新导入IOSDfuLib路径下对应的平台文件
     */

    let mBleConnector = BleConnector.shared
    let mBleScanner = BleScanner()
    let mBleCache: BleCache = BleCache.shared
    var peripheral :CBPeripheral?
    var isRealteOTA = false
    //杰里
    let mJLOTA = JLOTA.shared()
    let progressLab = UILabel()

}

extension OTAController {

    func startOTA(){
        switch  upgradeType{
        case 0:
            readyRealtekOTA()
            break
        case 1:
            readyMTKOTA()
            break
        case 2:
            readyGoodixOTA()
            break
        case 3:
            readyNordicOTA()
            break
        case 4:
            readyJLOTA()
            break
        default:
            break
        }
    }

    func readyRealtekOTA(){
//        /*
//          1. refreshUI -> true  upgrade firmware bin
//             refreshUI -> false upgrade UI or font bin
//          2.up to 3 files at once
//          3.when multiple files are upgraded at the same time, please upgrade the firmware first.
//         */
//        mBleConnector.closeConnection(true)//turn off Bluetooth connection
//        ROTA?.isUpgradeError = 0 //reset upgrade failure flag
//        ROTA?.imageNumber = 1 //number of upgrade files in this round
//
//        if self.isReadyROTA {
//            bleLog("check if the file is available")
//            realtekFileCheck()
//            return
//        }
//        ROTA?.haveSelectedPeripheral(peripheral)
//        ROTA!.refBlock = ({ [weak self](type:Int?,connected:Bool?,progress:CGFloat) in
//            if type == 0 {
//                if  connected! {
////                  if self?.ROTA?.imageNumber == (isupgrade){
//                    bleLog("The firmware upgrade is successful, the device restarts, and judges whether to continue to upgrade the next one")
////                  }else{
//                    bleLog("check file")
//                    self?.isRealteOTA = true
//                    self?.realtekFileCheck()
////                  }
//                } else {
//                    bleLog("ConnectState -- false")
//                }
//            }else{
//                if progress == 1 {
////                    if (isupgrade) {//determine whether the upgrade of all files in this upgrade is complete
//                        bleLog("readyRealtekOTA - OTA done")
//                    DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
//                        self?.reconnectDevice()
//                    }
//                        self?.ROTA?.imageNumber = 0
//
////                    }else{
////                        bleLog("readyRealtekOTA - next one ")
////                    }
//
//                }else if progress == -1 {
//                    bleLog("readyRealtekOTA - failed")
//
//                }else{
//                    bleLog("readyRealtekOTA -\(progress)")
//                    if (self?.ROTA!.isUpgradeError)! > 0{
//                        bleLog("readyRealtekOTA - failed - prompt the user to try again")
//                    }
//                }
//            }
//        })
    }

    func realtekFileCheck(){
//        let fileTrue = self.ROTA?.onFileHasSelected(filePath)
//        if fileTrue!{
//            self.isReadyROTA = true
//            ROTA?.clickStart(self.refreshUI)
//        }else{
//            bleLog("readyRealtekOTA -- File corruption is not available")
//        }
    }

    func readyMTKOTA(){
//        if mBleConnector.read(BleConnector.SERVICE_MTK, BleConnector.CH_MTK_OTA_META){
//            bleLog("readyMTKOTA - MTK查询版本")
//        }
//        mtkOTA?.mtkotaBlock = ({ [weak self](type,newUrl,newVersion) in
//
//            if type == 2101{
//                bleLog("readyMTKOTA - Latest firmware version")
//            }else if type == 0{
//                bleLog("readyMTKOTA - request failed")
//            }else if newUrl!.count>10 && type == 1{
//                bleLog("readyMTKOTA - the new version downUR - \(String(describing: newUrl))")
//
//            }
//            //test code
//            DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
//                self!.mBleConnector.mtkOta(self!.filePath) //start OTA
//            }
//        }) as MTKRefreshBlock
    }

    func readyGoodixOTA(){

//        if mBleConnector.sendData(.OTA, .UPDATE) {
//            bleLog("readyGoodixOTA -- Unlock device to allow upgrade")
//        }
//        //filePath is ZIP file package
//        goodix?.initGRDFirmware(filePath,  peripheral: mBleConnector.mPeripheral, centralManager: mBleConnector.mBleScanner.mCentralManager)
//        goodix?.dfuBlock = ({ [weak self](type:Int?,connected:Bool?,progress:CGFloat) in
//
//            if progress == 1 {
//                bleLog("readyGoodixOTA -- OTA done")
//            }else if progress == -1 {
//                bleLog("readyGoodixOTA -- OTA failed")
//            }else{
//                bleLog("readyGoodixOTA -- \(progress)")
//            }
//        }) as GoodixBlock
//
//        DispatchQueue.main.asyncAfter(deadline: .now()+5.0) {
//            //wait for the file to unzip
//            if self.goodix!.isFileValid() {
//                bleLog("readyGoodixOTA -- start OTA")
//                self.goodix!.clickStart()//start OTA
//            }else{
//                bleLog("readyGoodixOTA -- File corruption is not available, please download again")
//            }
//        }
    }

    func readyNordicOTA(){

        if mBleConnector.isAvailable(){
            if mBleConnector.sendData(.OTA, .UPDATE) {
                bleLog("readyNordicOTA -- start")
            }
        }else{
            //Connect to OTA service
            onOTA(true)
        }
    }

    func readyJLOTA(){


        if filePath.count > 5{
            mJLOTA.setPathFromOTAFile(filePath)
            mJLOTA.connectPeripheral(withUUID: (mBleConnector.mPeripheral?.identifier.uuidString)!)
            mJLOTA.jlBlock = ({ (messageType:Int?, message: String) in
                let type = messageType
                if type == 0{
                    bleLog("readyJLOTA - progress : \(message)%")
                    self.progressLab.text = "progress : \(message)%"
                }else if type == 1{
                    bleLog("readyJLOTA - error : \(message)")
                }else if type == 2{
                    bleLog("readyJLOTA - done : \(message)")
                    self.progressLab.text = "JLOTA - done"
                    DispatchQueue.main.asyncAfter(deadline: .now()+1.0){
                        self.mJLOTA.disconnectBLE()
                    }
                }else if type == 3{
                    bleLog("readyJLOTA - timeOut : \(message)")
                    self.progressLab.text = "timeOut : \(message)"
                }else if type == 4{
                    bleLog("readyJLOTA - Preparing : \(message)")
                    self.progressLab.text = "Preparing : \(message)"
                }else if type == 5{
                    bleLog("readyJLOTA - BleMacAddress : \(message)")
                }

            })
        }
    }

    func reconnectDevice(){
        bleLog("reconnectDevice - \( BleConnector.shared.isAvailable())")
        if BleConnector.shared.isAvailable() == false{
            BleConnector.shared.launch()//reconnect Bluetooth
            DispatchQueue.main.asyncAfter(deadline: .now()+8.0) {
                self.reconnectDevice()
            }
        }

    }
}

extension OTAController: BleHandleDelegate,LoggerDelegate,DFUServiceDelegate,DFUProgressDelegate,BleScanDelegate{

    func onDeviceConnected(_ peripheral: CBPeripheral){
        bleLog("OTAController - onDeviceConnected - \(isRealteOTA)")
        if isRealteOTA {
            mBleConnector.closeConnection(true)
        }
    }

    //MTK
    func onReadMtkOtaMeta(){
//        mtkDevice.initWithString(mBleCache.getMtkOtaMeta())
//        mtkOTA?.deviceInfo = mtkDevice
//        mtkOTA?.getMTKVersion()
//        bleLog("onReadMtkOtaMeta - \(mtkDevice)")
    }
    //Nordic
    func onBluetoothDisabled() {
        bleLog("Nordic - onBluetoothDisabled")
    }

    func onBluetoothEnabled() {
        bleLog("Nordic - onBluetoothEnabled")
    }

    func onScan(_ scan: Bool) {
        bleLog("Nordic - onScan")
    }

    func onOTA(_ status: Bool) {
        if status {
//            mBleScanner.mBleScanDelegate = self
//            mBleScanner.mBleScanFilter = nil
//            mBleConnector.mBleScanner.mCentralManager.stopScan()
////            mBleConnector.setTargetIdentifier("698A6B2A-6939-270B-CD48-79B5236DD923")
//            mBleScanner.mCentralManager.scanForPeripherals(withServices: [CBUUID.init(string: "FE59")], options: nil)
        }
    }

    func onDeviceFound(_ bleDevice: BleDevice) {
        print("Nordic - uuid:\(bleDevice.mPeripheral.identifier.uuidString)")
        mBleScanner.mCentralManager.stopScan()
        startDFU(bleDevice.mPeripheral)
    }

    func startDFU(_ per:CBPeripheral){
        do {
            let selectedFirmware = try DFUFirmware(urlToZipFile: URL(fileURLWithPath: filePath))
            let initiator = DFUServiceInitiator().with(firmware: selectedFirmware)
            initiator.logger = self // - to get log info
            initiator.delegate = self // - to be informed about current state and errors
            initiator.progressDelegate = self // - to show progress bar
            _ = initiator.start(target: per)
        } catch {
            // Handle the error here
            print("An error occurred while creating the DFUFirmware: \(error)")
        }

    }

    func dfuStateDidChange(to state: DFUState) {
     
        if state == .completed {
           // mBleConnector.setTargetIdentifier(mBleCache.getDeviceIdentify()!)
            bleLog("Nordic Back To view")
        }
    }

    func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
        print("Nordic - dfu error : \(message)")
    }

    func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        print("Nordic - part:\(part),total:\(totalParts),progress: \(progress)")
    }

    func logWith(_ level: LogLevel, message: String) {
        print("Nordic -  logWith (\(level.name())) : \(message)")
    }

    func onStreamProgress(_ status: Bool, _ errorCode: Int, _ total: Int, _ completed: Int) {
        let progressValue = CGFloat(completed)/CGFloat(total)
        if progressValue == 1 || errorCode > 0 {
            bleLog("MTK -  OTA done")
        }else{
            bleLog("MTK - progress:\(progressValue)")
        }

    }
}
