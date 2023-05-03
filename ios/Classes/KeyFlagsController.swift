//
//  KeyFlagsController.swift
//  blesdk3
//
//  Created by Best Mafen on 2019/9/30.
//  Copyright © 2019 szabh. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class KeyFlagsController: UITableViewController {
    var mBleKey: BleKey!
    var mBleKeyFlags: [BleKeyFlag]!

    private var mCameraEntered = false
    var progressLab = UILabel()
    var proDuration = 0
    var phoneWorkOut = 0
    let mode = BlePhoneWorkOut()
//    let mJLOTA = JLOTA.shared()
    var watchFaceIdNum = 0
   // var selectView = ABHSelectWatchFaceId()
    var bleWatchFaceID : BleWatchFaceId?
    var watchFileURL = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = mBleKey.mDisplayName

        mBleKeyFlags = mBleKey.getBleKeyFlags()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BleConnector.shared.addBleHandleDelegate(String(obj: self), self)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        BleConnector.shared.removeBleHandleDelegate(String(obj: self))
        UIApplication.shared.isIdleTimerDisabled = false
        progressLab.removeFromSuperview()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mBleKeyFlags.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KeyFlagCell", for: indexPath) as! KeyFlagCell
        cell.label.text = "\(mBleKeyFlags[indexPath.row])"
        return cell
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      //  handleCommand(mBleKey, mBleKeyFlags[indexPath.row])
    }

//    func handleCommand(_ bleKey: BleKey, _ bleKeyFlag: BleKeyFlag) {
//       
//    }
    // MARK: - Phone WorkOut
    func senderPhoneWorkOut(){        
        mode.mStep += 10
        mode.mDistance += 1
        mode.mCalories += 1
        mode.mDuration += 1
        mode.mSmp = 1
        mode.mAltitude = -5
        mode.mAirPressure = 1
        mode.mAvgPace = 1
        mode.mAvgSpeed = 1
        mode.mModeSport = 8
        if BleConnector.shared.sendObject(.APP_SPORT_DATA, .UPDATE, mode){
            bleLog(" -- senderPhoneWorkOut --")
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+5.0) {
            self.senderPhoneWorkOut()
        }
    }
    
    // MARK: - AddressBook
    func selectAddressBook(){
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let Select = UIAlertAction(title: "Select Contact", style: .default) {[weak self] (action) in
            self!.selectContact()
        }
        let notchoose = UIAlertAction(title: "Not choose", style: .default) { [weak self](action) in
            self!.sendAddressBook()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(Select)
        alert.addAction(notchoose)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func selectContact(){
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        self.present(contactPicker, animated: true, completion: nil)
    }
    
    func sendAddressBook() {
        bleLog("Address Book")
        let contactStore = CNContactStore()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        var sendArray: [BleContactPerson] = []
        do {
            try contactStore.enumerateContacts(with: request) { (contact: CNContact, stop) in
                var userName: String = " "

                userName = contact.givenName + contact.familyName

                var phoneString: String = ""
                if contact.phoneNumbers.count > 0 {
                    let phoneNums = contact.phoneNumbers.first
                    phoneString = phoneNums!.value.stringValue
                }
//                let phone = phoneString.replacingOccurrences(of: " ", with: "")
                let phone = self.stringReplacingOccurrencesOfString(phoneString)
                //Name
                var bytes: [UInt8] = []
                var index = 0
                for items in userName.utf8 {
                    if index < 24 {
                        index += 1
                        bytes.append(items.advanced(by: 0))
                    }
                }

                let newDate = Data(bytes: bytes, count: bytes.count)
                userName = String.init(data: newDate, encoding: .utf8) ?? ""

                if phone.count > 2 {
                    sendArray.append(BleContactPerson.init(username: userName, userphone: phone))
                }
            }
        } catch {
        }

        let send: BleAddressBook = BleAddressBook.init(array: sendArray)
        if BleConnector.shared.sendStream(.CONTACT, send.toData()) {
            bleLog("sendStream - AddressBook")
        }
    }

    func addressBookAuthorization() -> Bool {
        let status = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        if status == .notDetermined {
            let contactStore = CNContactStore()
            contactStore.requestAccess(for: .contacts, completionHandler: { (_ granted, _ error) in
                if granted {
                    bleLog("notDetermined - succ")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.selectAddressBook()
                    }
                }
            })
            return false
        } else if status == .authorized {
            bleLog("addressBook - authorized")
            return true
        } else {
            bleLog("addressBook - other")
            return false
        }
    }
    //replace special characters
    func stringReplacingOccurrencesOfString(_ str:String) ->String {
        let str1: NSString = str as NSString
        let charactersInString = "[]{}（#%-*=_）\\|//~(＜＞$%^&*)_€£¥:;!@.`,"
        let doNotWant = CharacterSet.init(charactersIn: charactersInString)
        let componentsArrays = str1.components(separatedBy: doNotWant)
        let hmutStr = componentsArrays.joined(separator: "")
        return hmutStr
    }

    private func doBle(_ action: (BleConnector) -> Void) {
        let bleConnector = BleConnector.shared
        if bleConnector.isAvailable() {
            action(bleConnector)
        } else {
            print("BleConnector is not available!")
        }
    }

    private func unbindCompleted() {
        present(storyboard!.instantiateViewController(withIdentifier: "devices"), animated: true)
    }

    private func gotoOta() {
        switch BleCache.shared.mPlatform {
        case BleDeviceInfo.PLATFORM_NORDIC, BleDeviceInfo.PLATFORM_GOODIX:
            _ = BleConnector.shared.sendData(.OTA, .UPDATE)
        case BleDeviceInfo.PLATFORM_MTK:
            _ = BleConnector.shared.read(BleConnector.SERVICE_MTK, BleConnector.CH_MTK_OTA_META)
        default:
            break
        }
    }
    
    // MARK: - 0x0701_WATCH_FACE
    func selectWatchType(){
        if BleCache.shared.mSupportWatchFaceId == 1{
            _ = BleConnector.shared.sendData(.WATCHFACE_ID, .READ)
        }
        let alert = UIAlertController.init(title: "WATCH FACE", message: nil, preferredStyle: .actionSheet)
        let defaultAction = UIAlertAction(title: "default watch face", style: .default) { [weak self](action) in
            self!.senderDefaultWatchFace()
        }
        let customizeAction = UIAlertAction(title: "customize watch face", style: .default) { [weak self](action) in
            self!.selectCustomizeWatchFace()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(defaultAction)
        alert.addAction(customizeAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func senderDefaultWatchFace(){
        proDuration = 0
        let selectVC = selectOTAFileController()
        selectVC.reloadBlock = { (fileURL) in
//            bleLog("senderDefaultWatchFace - \(String(describing: fileURL))")
//            if BleCache.shared.mPlatform == BleDeviceInfo.PLATFORM_JL {//&&
////                BleCache.shared.mSupportJLWatchFace == 1
//                self.senderJLWatchFace(fileURL)
//            }else if BleCache.shared.mSupportWatchFaceId == 1{
//                self.watchFileURL = fileURL
//                self.isShowSelectWatchFaceId()
//            }else{
//                _ = BleConnector.shared.sendStream(.WATCH_FACE, URL.init(fileURLWithPath: fileURL))
//                self.proDuration = Int(Date().timeIntervalSince1970)
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
//                    progressLab.frame = CGRect(x: 20, y: 70, width: MaxWidth-40, height: 100)
//                    progressLab.numberOfLines = 0
//                    progressLab.font = .systemFont(ofSize: 15)
//                    progressLab.backgroundColor = .black
//                    progressLab.textColor = .white
//                    progressLab.textAlignment = .center
//                    self.tableView.addSubview(progressLab)
//                    UIApplication.shared.isIdleTimerDisabled = true
//                }
//            }
        }
        self.navigationController?.pushViewController(selectVC, animated: true)
    }
    
    func selectCustomizeWatchFace(){
        let cusVC = BleCustomizeWatchFace()
        self.navigationController?.pushViewController(cusVC, animated: true)
    }
    
//    func senderJLWatchFace(_ filePath:String){
//        mJLOTA.watchFaceName = "WATCH1"
//        mJLOTA.watchFacePath = filePath
//        mJLOTA.isWatchFace = true
//        if mJLOTA.isConnect == true{
//            mJLOTA.openWatchFace()
//        }else{
//            mJLOTA.connectPeripheral(withUUID: (BleConnector.shared.mPeripheral?.identifier.uuidString)!)
//        }
//
//    }
}
// MARK: - mSupportWatchFaceId == 1
extension KeyFlagsController {
    func isShowSelectWatchFaceId(){

//        selectView = ABHSelectWatchFaceId()
        let bkBtn = UIButton()
        bkBtn.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        bkBtn.addTarget(self, action: #selector(selectRemoveFromSuperview(_ :)), for: .touchUpInside)
        bkBtn.frame = CGRect(x: 0, y: 0, width: MaxWidth, height: MaxHeight)
        self.view.addSubview(bkBtn)
    
//        selectView.frame = CGRect(x: 0, y: MaxHeight-400, width: MaxWidth, height: 300)
//        self.view.addSubview(selectView)
//        if bleWatchFaceID != nil{
//            selectView.watchFaceId = bleWatchFaceID
//        }
 //       selectView.makeView()
//        selectView.selectItem = ({ (num:Int) in
//            bleLog("selectItem - \(num)")
//            self.watchFaceIdNum = num
//            self.saveSelectImage(num)
//            self.senderWatchFaceID(num)
//            bkBtn.sendActions(for: .touchUpInside)
//        })
        
        
    }
    
    @objc func selectRemoveFromSuperview(_ sender:UIButton) {
        self.navigationItem.leftBarButtonItem?.isEnabled = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        sender.removeFromSuperview()
       // self.selectView.removeFromSuperview()
    }
    
    func saveSelectImage(_ selectNum:Int){
        let fileName = "WatchFaceID"+"\(selectNum)"
        var imageName = "bg_1"
        if selectNum%2 == 0{
            imageName = "bg_2"
        }
        let imageSvae = UIImage.init(named: imageName)
        saveNSDataImage(currentData: imageSvae!.pngData()! as NSData, imageName: fileName)
    }
    
    func senderWatchFaceID(_ number:Int){
        let watchFaceId : Int32 = Int32(number+10000) //ID >= 100
        _ = BleConnector.shared.sendInt32(.WATCHFACE_ID, .UPDATE, Int(watchFaceId))
    }
    
    func senderBinFile(){
        if watchFileURL.count>0{
            _ = BleConnector.shared.sendStream(.WATCH_FACE, URL.init(fileURLWithPath: watchFileURL),self.watchFaceIdNum)
            self.proDuration = Int(Date().timeIntervalSince1970)
            progressLab.frame = CGRect(x: 20, y: 70, width: MaxWidth-40, height: 100)
            progressLab.numberOfLines = 0
            progressLab.font = .systemFont(ofSize: 15)
            progressLab.backgroundColor = .black
            progressLab.textColor = .white
            progressLab.textAlignment = .center
            self.tableView.addSubview(progressLab)
            UIApplication.shared.isIdleTimerDisabled = true
            watchFileURL = ""
        }
    }
    
    func saveNSDataImage(currentData: NSData, imageName: String){
        let fullPath = NSHomeDirectory().appending("/Documents/").appending(imageName)
        currentData.write(toFile: fullPath, atomically: true)
    }
}

//MARK: address book
extension KeyFlagsController :CNContactPickerDelegate{
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        var dataSource :[BleContactPerson] = []
        for contact in contacts{
            var userName :String = " "
            userName  = contact.givenName+contact.familyName
            var phoneString :NSString = ""
            if contact.phoneNumbers.count>0{
                let phoneNums  = contact.phoneNumbers.first
                phoneString  = phoneNums!.value.stringValue as NSString
            }
            var phone = phoneString.replacingOccurrences(of: " ", with: "")
            phone = phone.stringReplacingOccurrencesOfString()

            if phone.count>2{
                dataSource.append(BleContactPerson.init(username: userName, userphone: phone))
            }
            bleLog("userName - \(userName) phone \(phone)")
        }
        if dataSource.count>0 {
            let sende :BleAddressBook = BleAddressBook.init(array: dataSource)
            if BleConnector.shared.sendStream(.CONTACT,sende.toData()){
                bleLog("sendStream - AddressBook")
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension KeyFlagsController: BleHandleDelegate {

    func onDeviceConnected(){
        DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
            if BleCache.shared.miBeacon == 1{
                //manually open the iBeacon protocol
                _ =  BleConnector.shared.sendInt8(.IBEACON_SET, .UPDATE, 1)
            }
        }
    }
    
    func onOTA(_ status: Bool) {
        print("onOTA \(status)")
    }

    func onReadPower(_ power: Int) {
        print("onReadPower \(power)")
    }

    func onReadFirmwareVersion(_ version: String) {
        print("onReadFirmwareVersion \(version)")
    }

    func onReadBleAddress(_ address: String) {
        print("onReadBleAddress \(address)")
    }

    func onReadSedentariness(_ sedentarinessSettings: BleSedentarinessSettings) {
        print("onReadSedentariness \(sedentarinessSettings)")
    }

    func onReadNoDisturb(_ noDisturbSettings: BleNoDisturbSettings) {
        print("onReadNoDisturb \(noDisturbSettings)")
    }

    func onReadAlarm(_ alarms: Array<BleAlarm>) {
        print("onReadAlarm \(alarms)")
    }

    func onIdentityDelete(_ status: Bool) {
        print("onIdentityDelete \(status)")
        if status {
            unbindCompleted()
        }
    }

    func onSyncData(_ syncState: Int, _ bleKey: Int) {
        print("onSyncData \(syncState) \(bleKey)")
    }

    func onReadActivity(_ activities: [BleActivity]) {
        print("onReadActivity \(activities)")
    }

    func onReadHeartRate(_ heartRates: [BleHeartRate]) {
        print("onReadHeartRate \(heartRates)")
    }

    func onReadBloodPressure(_ bloodPressures: [BleBloodPressure]) {
        print("onReadBloodPressure \(bloodPressures)")
    }

    func onReadSleep(_ sleeps: [BleSleep]) {
        if BleCache.shared.mSleepAlgorithmType == 1 {
            for item in sleeps {
                if item.mMode == 4 {
                    let time = item.mSoft << 8 + item.mStrong
                    print("sleep time total length - \(time)min")
                } else if item.mMode == 5 {
                    let time = item.mSoft << 8 + item.mStrong
                    print("deep sleep time length - \(time)min")
                } else if item.mMode == 6 {
                    let time = item.mSoft << 8 + item.mStrong
                    print("light sleep time length - \(time)min")
                } else if item.mMode == 7 {
                    let time = item.mSoft << 8 + item.mStrong
                    print("awake time length - \(time)min")
                }
            }
        } else {
            print("onReadSleep \(sleeps)")
        }
    }

    func onReadSleepRaw(_ sleepRawData: Data) {
        /**
         this is the original firmware data, which can be saved to a text file for the firmware technician to
         analyze the problem
         固件原始数据,app端无需处理,如需固件端分析问题可以保存到text文件提供给我们固件技术员
         */
        print("onReadSleepRaw - \(sleepRawData.mHexString)")
    }

    func onReadLocation(_ locations: [BleLocation]) {
        print("onReadLocation \(locations)")
    }

    func onReadTemperature(_ temperatures: [BleTemperature]) {
        print("onReadTemperature \(temperatures)")
    }

    func onCameraStateChange(_ cameraState: Int) {
        print("onCameraStateChange \(CameraState.getState(cameraState))")
        if cameraState == CameraState.ENTER {
            mCameraEntered = true
        } else if cameraState == CameraState.EXIT {
            mCameraEntered = false
        }
    }

    func onCameraResponse(_ status: Bool, _ cameraState: Int) {
        print("onCameraResponse \(status) \(CameraState.getState(cameraState))")
        if status {
            if cameraState == CameraState.ENTER {
                mCameraEntered = true
            } else if cameraState == CameraState.EXIT {
                mCameraEntered = false
            }
        }
    }

    func onStreamProgress(_ status: Bool, _ errorCode: Int, _ total: Int, _ completed: Int) {
        
        let progressValue = CGFloat(completed) / CGFloat(total)
        var mSpeed :Double = 0.0
        let nowTime = Int(Date().timeIntervalSince1970)
        let sTime = nowTime-proDuration
        if errorCode == 0 && total == completed {
            mSpeed = Double(total/1024)/Double(sTime)
            progressLab.text = "speed:\(String.init(format: "%.3f",mSpeed)) kb/s \n time:"+String.init(format: "%02d:%02d:%02d", sTime/3600,(sTime%3600)/60,sTime%60)+" MTU:\(BleConnector.shared.mBaseBleMessenger.mPacketSize)"
//            self.navigationController?.popToRootViewController(animated: true)
        }else{
            
            if completed>0{
                mSpeed = Double(completed/1024)/Double(sTime)
            }
            progressLab.text = "progress:\(String(format: "%.f", progressValue * 100.0))% - \(String.init(format: "%.3f",mSpeed)) kb/s"+"\n"+String.init(format: "%02d:%02d:%02d", sTime/3600,(sTime%3600)/60,sTime%60)
        }
        
//        print("onStreamProgress \(status) \(errorCode) \(total) \(completed) - \(String.init(format: "%.3f",mSpeed))")
    }

    func onReadAerobicSettings(_ AerobicSettings: BleAerobicSettings) {
        print("onReadAerobicSettings - \(AerobicSettings)")
    }

    func onReadTemperatureUnitSettings(_ state: Int) {
        print("onReadTemperatureUnitSettings - \(state)")
    }

    func onReadDateFormatSettings(_ status: Int) {
        print("onReadDateFormatSettings - \(status)")
    }
    
    func onReadWatchFaceSwitch(_ value: Int){
        print("onReadWatchFaceSwitch - \(value)")
        
    }
    
    func onUpdateWatchFaceSwitch(_ status: Bool) {
        if status{
            print("set the default watch face success")
        }
    }
    
    func onUpdateSettings(_ bleKey: BleKey.RawValue) {
        switch bleKey {
        case BleKey.NO_DISTURB_RANGE.rawValue:
            bleLog("NO_DISTURB_RANGE is success")
            break
        default:
            break
        }
    }
    
    func onReadWatchFaceId(_ watchFaceId: BleWatchFaceId) {
        bleWatchFaceID = watchFaceId
    }
    
    func onWatchFaceIdUpdate(_ status: Bool) {
        senderBinFile()
    }
}

extension String {
    // MARK: 过滤字符串中的特殊字符
    func stringReplacingOccurrencesOfString() ->String {
        let str: NSString = self as NSString
        let charactersInString = "[]{}（#%-*=_）\\|//~(＜＞$%^&*)_+€£¥:;!@.`,"
        let doNotWant = CharacterSet.init(charactersIn: charactersInString)
        let componentsArrays = str.components(separatedBy: doNotWant)
        let hmutStr = componentsArrays.joined(separator: "")
        return hmutStr
    }
}
