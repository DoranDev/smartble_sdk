//
//  ABHBackgroundMonitoring.swift
//  blesdk3
//
//  Created by SMA-IOS on 2022/3/28.
//  Copyright © 2022 szabh. All rights reserved.
//

import Foundation
import CoreLocation
import AVFoundation
import SmartWatchCodingBleKit

class ABHBackgroundMonitoring :NSObject{
    
    static let share = ABHBackgroundMonitoring()
    private var monitor: BeaconMonitor?
    var player : AVAudioPlayer?
    var monitorUUID = ""
    private var isPlayingFindphone = false
    override init() {
        super.init()
        BleConnector.shared.addBleHandleDelegate(String(obj: self), self)
        self.initPlayer()
        //监听进入后台
        NotificationCenter.default.addObserver(self as Any, selector: #selector(enterBackgroundiBeacon(notification:)), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackgroundiBeacon(notification:)), name:UIApplication.didEnterBackgroundNotification,object: nil)
        //监测程序被激活
        NotificationCenter.default.addObserver(self, selector: #selector(enterBecomeActiveiBeacon(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func initPlayer() {
        gteSystemAuthority()
        if  player == nil{
            let path = Bundle.main.path(forResource: "find_phone", ofType: "mp3")
            let url : URL = URL.init(fileURLWithPath: path!)
            do {
                player = try AVAudioPlayer.init(contentsOf: url)
                player?.prepareToPlay()
            }catch let error as NSError {
                print(error.description)
            }
        }else{
            bleLog("player - 已初始化")
        }
        
    }
    
    func gteSystemAuthority(){
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: AVAudioSession.Category.playback.rawValue))
        } catch let error{
            bleLog("AVAudioSession 设置错误 - \(error.localizedDescription)")
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error{
            bleLog("AVAudioSession setActive - \(error.localizedDescription)")
        }
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    
    func responseFindphone() {
        if player?.isPlaying == false{
            gteSystemAuthority()
            player?.numberOfLoops = -1
            player?.volume = 1.0
            player?.play()
        }        
    }
    
    func stopFindphone() {
        player?.stop()
    }
    
    @objc func enterBecomeActiveiBeacon(notification:Notification){
        bleLog("enterBecomeActiveiBeacon")
        isPlayingFindphone = true
    }
    
    @objc func enterBackgroundiBeacon(notification:Notification){
        bleLog("enterBackgroundiBeacon")
        isPlayingFindphone = false
    }
   
}
// MARK: BeaconMonitor
extension ABHBackgroundMonitoring{
    
    func asciiStringToByte(_ str:String)-> String{
        var uuidStr = ""
        var index = 0
        let bleStr = BleCache.shared.mBleAddress
        let endStr = bleStr.replacingOccurrences(of: ":", with: "")
        bleLog("mBleAddress - \(endStr)")
        for character in  str.unicodeScalars{
            index += 1
            let newUint = UInt8(character.value)
            let newStr = String.init(format: "%02x", newUint)
            
            if index == 4 || index == 6 || index == 8 || index == 10{
                uuidStr += newStr+"-"
                if index == 10 && endStr.count>0{
                    uuidStr += endStr
                    return uuidStr
                }
            }else{
                uuidStr += newStr
            }
            
        }
        return uuidStr
    }
    func startListening(_ uuidString:String = "CodingV0.116cff3"){

        let uuidStr = self.asciiStringToByte(uuidString)
        bleLog("UUID - \(String(describing: UUID(uuidString: uuidStr)))")
        monitor = BeaconMonitor(uuid: UUID(uuidString: uuidStr)!)
        monitor!.delegate = self
        monitor!.startListening()
        let str = UserDefaults.standard.string(forKey: "locationManager")
        bleLog("locationManager - \(String(describing: str))")
        UserDefaults.standard.removeObject(forKey: "locationManager")

    }
    
    func stopListening(_ uuidString:String = "CodingV0.116cff3"){
        bleLog("stopListening")
        let uuidStr = self.asciiStringToByte(uuidString)
        if monitor != nil{
            monitor!.stopListening()
        }else{
            monitor = BeaconMonitor(uuid: UUID(uuidString: uuidStr)!)
            monitor!.stopListening()
        }
        
    }
    
    func closeIBeaconControl(){
        if BleConnector.shared.sendInt8(.IBEACON_CONTROL, .UPDATE, 0){
            bleLog("close the current ibeacon broadcast")
        }
    }
    
    func setTime(){
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let strDate = dateFormatter.string(from: Date())
        let str = UserDefaults.standard.string(forKey: "locationManager") ?? "*****"
        var newStr = str+" \n "+strDate+" " //记录后台运行log,可删除
        
        if !BleConnector.shared.isAvailable() {
            newStr += "device not connected"
            bleLog("device not connected")
            UserDefaults.standard.set(newStr, forKey: "locationManager")
            UserDefaults.standard.synchronize()
            return
        }
        newStr += "device connected"
        UserDefaults.standard.set(newStr, forKey: "locationManager")
        UserDefaults.standard.synchronize()
        _ = BleConnector.shared.sendObject(.TIME, .UPDATE, BleTime.local())
        _ = BleConnector.shared.sendObject(.TIME_ZONE,.UPDATE, BleTimeZone())
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.closeIBeaconControl()
        }
        
    }
}

extension ABHBackgroundMonitoring: BeaconMonitorDelegate {
    
    @objc func receivedAllBeacons(_ monitor: BeaconMonitor, beacons: [CLBeacon]) {
        bleLog("receivedAllBeacons - \(beacons)")
        if beacons.first?.minor == 1{
            // Find phone
            gteSystemAuthority()
            if  player == nil{
                let path = Bundle.main.path(forResource: "find_phone", ofType: "mp3")
                let url : URL = URL.init(fileURLWithPath: path!)
                do {
                    player = try AVAudioPlayer.init(contentsOf: url)
                    player?.prepareToPlay()
                }catch let error as NSError {
                    print(error.description)
                }
            }else{
                bleLog("player - 已初始化")
            }
            if isPlayingFindphone == false{
                responseFindphone()
            }
        }else if beacons.first?.minor == 2{
            // connect ble
            setTime()
        }
        
    }
    
}


extension ABHBackgroundMonitoring: BleHandleDelegate{
    
    func onFindPhone(_ start: Bool) {
        bleLog("ABHBackgroundMonitoring - onFindPhone")
        if start == false{
            isPlayingFindphone = true
            DispatchQueue.main.asyncAfter(deadline: .now()+1.5) {
                self.isPlayingFindphone = true
            }
            stopFindphone()
        }
    }
}
