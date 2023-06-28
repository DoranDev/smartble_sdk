import Flutter
import Contacts
import UIKit
import MobileCoreServices
import CoreBluetooth

public class SwiftSmartbleSdkPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, BleHandleDelegate , BleScanDelegate , BleScanFilter {


    static let eventChannelNameScan = "smartble_sdk/scan";
    static let eventChannelNameOnDeviceConnected = "onDeviceConnected";
    static let eventChannelNameOnIdentityCreate = "onIdentityCreate";
    static let eventChannelNameOnCommandReply = "onCommandReply";
    static let eventChannelNameOnOTA = "onOTA";
    static let eventChannelNameOnReadPower = "onReadPower";
    static let eventChannelNameOnReadFirmwareVersion  = "onReadFirmwareVersion";
    static let eventChannelNameOnReadBleAddress  = "onReadBleAddress";
    static let eventChannelNameOnReadSedentariness  = "onReadSedentariness";
    static let eventChannelNameOnReadNoDisturb  = "onReadNoDisturb";
    static let eventChannelNameOnReadAlarm  = "onReadAlarm";
    static let eventChannelNameOnReadCoachingIds  = "onReadCoachingIds";
    static let eventChannelNameOnReadUiPackVersion  = "onReadUiPackVersion";
    static let eventChannelNameOnReadLanguagePackVersion  = "onReadLanguagePackVersion";
    static let eventChannelNameOnIdentityDeleteByDevice  = "onIdentityDeleteByDevice";
    static let eventChannelNameOnCameraStateChange  = "onCameraStateChange";
    static let eventChannelNameOnCameraResponse  = "onCameraResponse";
    static let eventChannelNameOnSyncData  = "onSyncData";
    static let eventChannelNameOnReadActivity  = "onReadActivity";
    static let eventChannelNameOnReadHeartRate  = "onReadHeartRate";
    static let eventChannelNameOnUpdateHeartRate  = "onUpdateHeartRate";
    static let eventChannelNameOnReadBloodPressure  = "onReadBloodPressure";
    static let eventChannelNameOnReadSleep  = "onReadSleep";
    static let eventChannelNameOnReadLocation  = "onReadLocation";
    static let eventChannelNameOnReadTemperature  = "onReadTemperature";
    static let eventChannelNameOnReadWorkout2  = "onReadWorkout2";
    static let eventChannelNameOnStreamProgress  = "onStreamProgress";
    static let eventChannelNameOnUpdateAppSportState  = "onUpdateAppSportState";
    static let eventChannelNameOnClassicBluetoothStateChange  = "onClassicBluetoothStateChange";
    static let eventChannelNameOnDeviceFileUpdate  = "onDeviceFileUpdate";
    static let eventChannelNameOnReadDeviceFile  = "onReadDeviceFile";
    static let eventChannelNameOnReadTemperatureUnit  = "onReadTemperatureUnit";
    static let eventChannelNameOnReadDateFormat  = "onReadDateFormat";
    static let eventChannelNameOnReadWatchFaceSwitch  = "onReadWatchFaceSwitch";
    static let eventChannelNameOnUpdateWatchFaceSwitch  = "onUpdateWatchFaceSwitch";
    static let eventChannelNameOnAppSportDataResponse = "onAppSportDataResponse";
    static let eventChannelNameOnReadWatchFaceId = "onReadWatchFaceId";
    static let eventChannelNameOnWatchFaceIdUpdate = "onWatchFaceIdUpdate";
    static let eventChannelNameOnHIDState = "onHIDState";
    static let eventChannelNameOnHIDValueChange = "onHIDValueChange";
    static let eventChannelNameOnDeviceSMSQuickReply = "onDeviceSMSQuickReply";
    static let eventChannelNameOnReadDeviceInfo = "onReadDeviceInfo";
    static let eventChannelNameOnSessionStateChange = "onSessionStateChange";
    static let eventChannelNameOnNoDisturbUpdate = "onNoDisturbUpdate";
    static let eventChannelNameOnAlarmUpdate = "onAlarmUpdate";
    static let eventChannelNameOnAlarmDelete = "onAlarmDelete";
    static let eventChannelNameOnAlarmAdd = "onAlarmAdd";
    static let eventChannelNameOnFindPhone = "onFindPhone";
    static let eventChannelNameOnRequestLocation = "onRequestLocation";
    static let eventChannelNameOnDeviceRequestAGpsFile = "onDeviceRequestAGpsFile";
    static let eventChannelNameOnReadBloodOxygen = "onReadBloodOxygen";
    static let eventChannelNameOnReadWorkout = "onReadWorkout";
    static let eventChannelNameOnReadBleHrv = "onReadBleHrv";
    static let eventChannelNameOnReadPressure = "onReadPressure";
    static let eventChannelNameOnReadWorldClock = "onReadWorldClock";
    static let eventChannelNameOnWorldClockDelete = "onWorldClockDelete";
    static let eventChannelNameOnDeviceConnecting = "onDeviceConnecting";
    static let eventChannelNameOnIncomingCallStatus = "onIncomingCallStatus";
    static let eventChannelNameOnReceiveMusicCommand = "onReceiveMusicCommand";
    static let eventChannelNameOnStockRead = "onStockRead";
    static let eventChannelNameOnStockDelete = "onStockDelete";
    static let eventChannelNameOnBleError = "onBleError";

    var scanSink: FlutterEventSink?
    var onDeviceConnectedSink: FlutterEventSink?
    var onIdentityCreateSink: FlutterEventSink?
    var onCommandReplySink: FlutterEventSink?
    var onOTASink: FlutterEventSink?
    var onReadPowerSink: FlutterEventSink?
    var onReadFirmwareVersionSink: FlutterEventSink?
    var onReadBleAddressSink: FlutterEventSink?
    var onReadSedentarinessSink: FlutterEventSink?
    var onReadNoDisturbSink: FlutterEventSink?
    var onReadAlarmSink: FlutterEventSink?
    var onReadCoachingIdsSink: FlutterEventSink?
    var onReadUiPackVersionSink: FlutterEventSink?
    var onReadLanguagePackVersionSink: FlutterEventSink?
    var onIdentityDeleteByDeviceSink: FlutterEventSink?
    var onCameraStateChangeSink: FlutterEventSink?
    var onCameraResponseSink: FlutterEventSink?
    var onSyncDataSink: FlutterEventSink?
    var onReadActivitySink: FlutterEventSink?
    var onReadHeartRateSink: FlutterEventSink?
    var onUpdateHeartRateSink: FlutterEventSink?
    var onReadBloodPressureSink: FlutterEventSink?
    var onReadSleepSink: FlutterEventSink?
    var onReadLocationSink: FlutterEventSink?
    var onReadTemperatureSink: FlutterEventSink?
    var onReadWorkout2Sink: FlutterEventSink?
    var onStreamProgressSink: FlutterEventSink?
    var onUpdateAppSportStateSink: FlutterEventSink?
    var onClassicBluetoothStateChangeSink: FlutterEventSink?
    var onDeviceFileUpdateSink: FlutterEventSink?
    var onReadDeviceFileSink: FlutterEventSink?
    var onReadTemperatureUnitSink: FlutterEventSink?
    var onReadDateFormatSink: FlutterEventSink?
    var onReadWatchFaceSwitchSink: FlutterEventSink?
    var onUpdateWatchFaceSwitchSink: FlutterEventSink?
    var onAppSportDataResponseSink: FlutterEventSink?
    var onReadWatchFaceIdSink: FlutterEventSink?
    var onWatchFaceIdUpdateSink: FlutterEventSink?
    var onHIDStateSink: FlutterEventSink?
    var onHIDValueChangeSink: FlutterEventSink?
    var onDeviceSMSQuickReplySink: FlutterEventSink?
    var onReadDeviceInfoSink: FlutterEventSink?
    var onSessionStateChangeSink: FlutterEventSink?
    var onNoDisturbUpdateSink: FlutterEventSink?
    var onAlarmUpdateSink: FlutterEventSink?
    var onAlarmDeleteSink: FlutterEventSink?
    var onAlarmAddSink: FlutterEventSink?
    var onFindPhoneSink: FlutterEventSink?
    var onRequestLocationSink: FlutterEventSink?
    var onDeviceRequestAGpsFileSink: FlutterEventSink?
    var onReadBloodOxygenSink: FlutterEventSink?
    var onReadWorkoutSink: FlutterEventSink?
    var onReadBleHrvSink: FlutterEventSink?
    var onReadPressureSink: FlutterEventSink?
    var onReadWorldClockSink: FlutterEventSink?
    var onWorldClockDeleteSink: FlutterEventSink?
    var onDeviceConnectingSink: FlutterEventSink?
    var onIncomingCallStatusSink: FlutterEventSink?
    var onReceiveMusicCommandSink: FlutterEventSink?
    var onStockReadSink: FlutterEventSink?
    var onStockDeleteSink: FlutterEventSink?
    var onBleErrorSink: FlutterEventSink?
    var filePath : String = "" //升级文件路径
    let mJLOTA = JLOTA.shared()

    func performNetworkRequest(urlString: String, completion: @escaping (String?) -> Void) {
        let fileURL = URL(string: urlString)
        if(fileURL == nil){
            completion(nil)
            return
        }
        let downloadTask = URLSession.shared.downloadTask(with: fileURL!) { (location, response, error) in
            if let error = error {
                // Handle download error
                print("Download error: \(error)")
                completion(nil)
                return
            }

            // Check if the download was successful based on the HTTP response status code
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                // File downloaded successfully
                // Get the documents directory URL
                guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                    // Handle error if documents directory is not available
                    return
                }

                // Create a destination URL in the documents directory using the lastPathComponent of the original file URL
                let destinationURL = documentsDirectory.appendingPathComponent(fileURL!.lastPathComponent)
                let fileManager = FileManager.default

                if fileManager.fileExists(atPath: destinationURL.path) {
                    do {
                        // Delete the existing file
                        try fileManager.removeItem(at: destinationURL)
                    } catch {
                        // Handle error while deleting the existing file
                        print("Error deleting existing file: \(error)")
                        return
                    }
                }

                do {
                    // Move the downloaded file to the destination URL
                    try fileManager.moveItem(at: location!, to: destinationURL)

                    // File saved successfully
                    print("File saved at: \(destinationURL.path)")
                    if fileManager.fileExists(atPath: destinationURL.path) {
                        print("File Path: \(destinationURL.path)")
                        completion(destinationURL.path)

                    } else {
                        print("File download completed, but not found at the specified path.")
                        completion(nil)
                        // Handle file not found error
                    }
                    // Proceed with further actions on the downloaded file
                } catch {
                    // Handle file saving error
                    print("Error saving file: \(error)")
                    completion(nil)
                }

            } else {
                // Handle unsuccessful download (e.g., non-200 status code)
                print("Download failed with HTTP response: \(String(describing: response))")
                completion(nil)
            }
        }

        downloadTask.resume()
    }


    func readyJLOTA(){
        if filePath.count > 5{
            mJLOTA.setPathFromOTAFile(filePath)
            mJLOTA.connectPeripheral(withUUID: (mBleConnector.mPeripheral?.identifier.uuidString)!)
            mJLOTA.jlBlock = ({ (messageType:Int?, message: String) in
                let type = messageType
                if type == 0{
                    bleLog("readyJLOTA - progress : \(message)%")
                }else if type == 1{
                    bleLog("readyJLOTA - error : \(message)")
                }else if type == 2{
                    bleLog("readyJLOTA - done : \(message)")
                    DispatchQueue.main.asyncAfter(deadline: .now()+1.0){
                        self.mJLOTA.disconnectBLE()
                    }
                }else if type == 3{
                    bleLog("readyJLOTA - timeOut : \(message)")

                }else if type == 4{
                    bleLog("readyJLOTA - Preparing : \(message)")

                }else if type == 5{
                    bleLog("readyJLOTA - BleMacAddress : \(message)")
                }

            })
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


    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        switch arguments as? String {
        case SwiftSmartbleSdkPlugin.eventChannelNameScan:
            scanSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnDeviceConnected:
            onDeviceConnectedSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnIdentityCreate:
            onIdentityCreateSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnCommandReply:
            onCommandReplySink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnOTA:
            onOTASink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReadPower:
            onReadPowerSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReadFirmwareVersion:
            onReadFirmwareVersionSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReadBleAddress:
            onReadBleAddressSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReadSedentariness:
            onReadSedentarinessSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReadNoDisturb:
            onReadNoDisturbSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReadAlarm:
            onReadAlarmSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReadCoachingIds:
            onReadCoachingIdsSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReadUiPackVersion:
            onReadUiPackVersionSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReadLanguagePackVersion:
            onReadLanguagePackVersionSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnIdentityDeleteByDevice:
            onIdentityDeleteByDeviceSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnCameraStateChange:
            onCameraStateChangeSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnCameraResponse:
            onCameraResponseSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnSyncData:
            onSyncDataSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReadActivity:
            onReadActivitySink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReadHeartRate:
            onReadHeartRateSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnUpdateHeartRate:
            onUpdateHeartRateSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReadBloodPressure:
            onReadBloodPressureSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReadSleep:
            onReadSleepSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReadLocation:
            onReadLocationSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReadTemperature:
            onReadTemperatureSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReadWorkout2:
            onReadWorkout2Sink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnStreamProgress:
            onStreamProgressSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnUpdateAppSportState:
            onUpdateAppSportStateSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnClassicBluetoothStateChange:
            onClassicBluetoothStateChangeSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnDeviceFileUpdate:
            onDeviceFileUpdateSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReadDeviceFile:
            onReadDeviceFileSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReadTemperatureUnit:
            onReadTemperatureUnitSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReadDateFormat:
            onReadDateFormatSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReadWatchFaceSwitch:
            onReadWatchFaceSwitchSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnUpdateWatchFaceSwitch:
            onUpdateWatchFaceSwitchSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnAppSportDataResponse:
            onAppSportDataResponseSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReadWatchFaceId:
            onReadWatchFaceIdSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnWatchFaceIdUpdate:
            onWatchFaceIdUpdateSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnHIDState:
            onHIDStateSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnHIDValueChange:
            onHIDValueChangeSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnDeviceSMSQuickReply:
            onDeviceSMSQuickReplySink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReadDeviceInfo:
            onReadDeviceInfoSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnSessionStateChange:
            onSessionStateChangeSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnNoDisturbUpdate:
            onNoDisturbUpdateSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnAlarmUpdate:
            onAlarmUpdateSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnAlarmDelete:
            onAlarmDeleteSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnAlarmAdd:
            onAlarmAddSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnFindPhone:
            onFindPhoneSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnRequestLocation:
            onRequestLocationSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnDeviceRequestAGpsFile:
            onDeviceRequestAGpsFileSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReadBloodOxygen:
            onReadBloodOxygenSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReadWorkout:
            onReadWorkoutSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReadBleHrv:
            onReadBleHrvSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReadPressure:
            onReadPressureSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReadWorldClock:
            onReadWorldClockSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnWorldClockDelete:
            onWorldClockDeleteSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnDeviceConnecting:
            onDeviceConnectingSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnIncomingCallStatus:
            onIncomingCallStatusSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnReceiveMusicCommand:
            onReceiveMusicCommandSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnStockRead:
            onStockReadSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnStockDelete:
            onStockDeleteSink = events
            break;
        case SwiftSmartbleSdkPlugin.eventChannelNameOnBleError:
            onBleErrorSink = events
            break;

        default:
            break
        }
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }

    let mBleConnector = BleConnector.shared
    let mBleScanner = BleScanner(/*[CBUUID(string: BleConnector.BLE_SERVICE)]*/)
    var mDevices = [[String:String]()]
    let mBleCache = BleCache.shared


//    var btn240 = false
//     var btn454 = false
//     let bgView = UIView()
//     var bgWidth :Int = 240
//     var bgHeight :Int = 240
//     var digitalTime = false
//     var clock_pointer = false
//     var clock_scale = false
//     var bg_step = false
//     var bg_hr  = false
//     var bg_dis = false
//     var bg_cal = false
 //
 //    let timeSymView :UIImageView = UIImageView() //Realtek平台特殊字符绘制 :
 //    let dateSymView :UIImageView = UIImageView() //Realtek平台特殊字符绘制
     var isBmpResoure = false
    var bleBin = BleWatchFaceBin()
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

     private let isSupp2D = BleCache.shared.mSupport2DAcceleration != 0

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

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "smartble_sdk", binaryMessenger: registrar.messenger())
      let instance = SwiftSmartbleSdkPlugin(channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
    let scanChannel = FlutterEventChannel(name: eventChannelNameScan, binaryMessenger:registrar.messenger())
      scanChannel.setStreamHandler(instance)
      let onDeviceConnectedChannel = FlutterEventChannel(name: eventChannelNameOnDeviceConnected, binaryMessenger:registrar.messenger())
      onDeviceConnectedChannel.setStreamHandler(instance)
      let onIdentityCreateChannel = FlutterEventChannel(name: eventChannelNameOnIdentityCreate, binaryMessenger:registrar.messenger())
      onIdentityCreateChannel.setStreamHandler(instance)
      let onCommandReplyChannel = FlutterEventChannel(name: eventChannelNameOnCommandReply, binaryMessenger:registrar.messenger())
      onCommandReplyChannel.setStreamHandler(instance)
      let onOTAChannel = FlutterEventChannel(name: eventChannelNameOnOTA, binaryMessenger:registrar.messenger())
      onOTAChannel.setStreamHandler(instance)
      let onReadPowerChannel = FlutterEventChannel(name: eventChannelNameOnReadPower, binaryMessenger:registrar.messenger())
      onReadPowerChannel.setStreamHandler(instance)
      let onReadFirmwareVersionChannel = FlutterEventChannel(name: eventChannelNameOnReadFirmwareVersion, binaryMessenger:registrar.messenger())
      onReadFirmwareVersionChannel.setStreamHandler(instance)
      let onReadBleAddressChannel = FlutterEventChannel(name: eventChannelNameOnReadBleAddress, binaryMessenger:registrar.messenger())
      onReadBleAddressChannel.setStreamHandler(instance)
      let onReadSedentarinessChannel = FlutterEventChannel(name: eventChannelNameOnReadSedentariness, binaryMessenger:registrar.messenger())
      onReadSedentarinessChannel.setStreamHandler(instance)
      let onReadNoDisturbChannel = FlutterEventChannel(name: eventChannelNameOnReadNoDisturb, binaryMessenger:registrar.messenger())
      onReadNoDisturbChannel.setStreamHandler(instance)
      let onReadAlarmChannel = FlutterEventChannel(name: eventChannelNameOnReadAlarm, binaryMessenger:registrar.messenger())
      onReadAlarmChannel.setStreamHandler(instance)
      let onReadCoachingIdsChannel = FlutterEventChannel(name: eventChannelNameOnReadCoachingIds, binaryMessenger:registrar.messenger())
      onReadCoachingIdsChannel.setStreamHandler(instance)
      let onReadUiPackVersionChannel = FlutterEventChannel(name: eventChannelNameOnReadUiPackVersion, binaryMessenger:registrar.messenger())
      onReadUiPackVersionChannel.setStreamHandler(instance)
      let onReadLanguagePackVersionChannel = FlutterEventChannel(name: eventChannelNameOnReadLanguagePackVersion, binaryMessenger:registrar.messenger())
      onReadLanguagePackVersionChannel.setStreamHandler(instance)
      let onIdentityDeleteByDeviceChannel = FlutterEventChannel(name: eventChannelNameOnIdentityDeleteByDevice, binaryMessenger:registrar.messenger())
      onIdentityDeleteByDeviceChannel.setStreamHandler(instance)
      let onCameraStateChangeChannel = FlutterEventChannel(name: eventChannelNameOnCameraStateChange, binaryMessenger:registrar.messenger())
      onCameraStateChangeChannel.setStreamHandler(instance)
      let onCameraResponseChannel = FlutterEventChannel(name: eventChannelNameOnCameraResponse, binaryMessenger:registrar.messenger())
      onCameraResponseChannel.setStreamHandler(instance)
      let onSyncDataChannel = FlutterEventChannel(name: eventChannelNameOnSyncData, binaryMessenger:registrar.messenger())
      onSyncDataChannel.setStreamHandler(instance)
      let onReadActivityChannel = FlutterEventChannel(name: eventChannelNameOnReadActivity, binaryMessenger:registrar.messenger())
      onReadActivityChannel.setStreamHandler(instance)
      let onReadHeartRateChannel = FlutterEventChannel(name: eventChannelNameOnReadHeartRate, binaryMessenger:registrar.messenger())
      onReadHeartRateChannel.setStreamHandler(instance)
      let onUpdateHeartRateChannel = FlutterEventChannel(name: eventChannelNameOnUpdateHeartRate, binaryMessenger:registrar.messenger())
      onUpdateHeartRateChannel.setStreamHandler(instance)
      let onReadBloodPressureChannel = FlutterEventChannel(name: eventChannelNameOnReadBloodPressure, binaryMessenger:registrar.messenger())
      onReadBloodPressureChannel.setStreamHandler(instance)
      let onReadSleepChannel = FlutterEventChannel(name: eventChannelNameOnReadSleep, binaryMessenger:registrar.messenger())
      onReadSleepChannel.setStreamHandler(instance)
      let onReadLocationChannel = FlutterEventChannel(name: eventChannelNameOnReadLocation, binaryMessenger:registrar.messenger())
      onReadLocationChannel.setStreamHandler(instance)
      let onReadTemperatureChannel = FlutterEventChannel(name: eventChannelNameOnReadTemperature, binaryMessenger:registrar.messenger())
      onReadTemperatureChannel.setStreamHandler(instance)
      let onReadWorkout2Channel = FlutterEventChannel(name: eventChannelNameOnReadWorkout2, binaryMessenger:registrar.messenger())
      onReadWorkout2Channel.setStreamHandler(instance)
      let onStreamProgressChannel = FlutterEventChannel(name: eventChannelNameOnStreamProgress, binaryMessenger:registrar.messenger())
      onStreamProgressChannel.setStreamHandler(instance)
      let onUpdateAppSportStateChannel = FlutterEventChannel(name: eventChannelNameOnUpdateAppSportState, binaryMessenger:registrar.messenger())
      onUpdateAppSportStateChannel.setStreamHandler(instance)
      let onClassicBluetoothStateChangeChannel = FlutterEventChannel(name: eventChannelNameOnClassicBluetoothStateChange, binaryMessenger:registrar.messenger())
      onClassicBluetoothStateChangeChannel.setStreamHandler(instance)
      let onDeviceFileUpdateChannel = FlutterEventChannel(name: eventChannelNameOnDeviceFileUpdate, binaryMessenger:registrar.messenger())
      onDeviceFileUpdateChannel.setStreamHandler(instance)
      let onReadDeviceFileChannel = FlutterEventChannel(name: eventChannelNameOnReadDeviceFile, binaryMessenger:registrar.messenger())
      onReadDeviceFileChannel.setStreamHandler(instance)
      let onReadTemperatureUnitChannel = FlutterEventChannel(name: eventChannelNameOnReadTemperatureUnit, binaryMessenger:registrar.messenger())
      onReadTemperatureUnitChannel.setStreamHandler(instance)
      let onReadDateFormatChannel = FlutterEventChannel(name: eventChannelNameOnReadDateFormat, binaryMessenger:registrar.messenger())
      onReadDateFormatChannel.setStreamHandler(instance)
      let onUpdateWatchFaceSwitchChannel = FlutterEventChannel(name: eventChannelNameOnUpdateWatchFaceSwitch, binaryMessenger:registrar.messenger())
      onUpdateWatchFaceSwitchChannel.setStreamHandler(instance)
      let onAppSportDataResponseChannel = FlutterEventChannel(name: eventChannelNameOnAppSportDataResponse, binaryMessenger:registrar.messenger())
      onAppSportDataResponseChannel.setStreamHandler(instance)
      let onReadWatchFaceIdChannel = FlutterEventChannel(name: eventChannelNameOnReadWatchFaceId, binaryMessenger:registrar.messenger())
      onReadWatchFaceIdChannel.setStreamHandler(instance)
      let onWatchFaceIdUpdateChannel = FlutterEventChannel(name: eventChannelNameOnWatchFaceIdUpdate, binaryMessenger:registrar.messenger())
      onWatchFaceIdUpdateChannel.setStreamHandler(instance)
      let onHIDStateChannel = FlutterEventChannel(name: eventChannelNameOnHIDState, binaryMessenger:registrar.messenger())
      onHIDStateChannel.setStreamHandler(instance)
      let onHIDValueChangeChannel = FlutterEventChannel(name: eventChannelNameOnHIDValueChange, binaryMessenger:registrar.messenger())
      onHIDValueChangeChannel.setStreamHandler(instance)
      let onDeviceSMSQuickReplyChannel = FlutterEventChannel(name: eventChannelNameOnDeviceSMSQuickReply, binaryMessenger:registrar.messenger())
      onDeviceSMSQuickReplyChannel.setStreamHandler(instance)
      let onReadDeviceInfoChannel = FlutterEventChannel(name: eventChannelNameOnReadDeviceInfo, binaryMessenger:registrar.messenger())
      onReadDeviceInfoChannel.setStreamHandler(instance)
      let onSessionStateChangeChannel = FlutterEventChannel(name: eventChannelNameOnSessionStateChange, binaryMessenger:registrar.messenger())
      onSessionStateChangeChannel.setStreamHandler(instance)
      let onNoDisturbUpdateChannel = FlutterEventChannel(name: eventChannelNameOnNoDisturbUpdate, binaryMessenger:registrar.messenger())
      onNoDisturbUpdateChannel.setStreamHandler(instance)
      let onAlarmUpdateChannel = FlutterEventChannel(name: eventChannelNameOnAlarmUpdate, binaryMessenger:registrar.messenger())
      onAlarmUpdateChannel.setStreamHandler(instance)
      let onAlarmDeleteChannel = FlutterEventChannel(name: eventChannelNameOnAlarmDelete, binaryMessenger:registrar.messenger())
      onAlarmDeleteChannel.setStreamHandler(instance)
      let onAlarmAddChannel = FlutterEventChannel(name: eventChannelNameOnAlarmAdd, binaryMessenger:registrar.messenger())
      onAlarmAddChannel.setStreamHandler(instance)
      let onFindPhoneChannel = FlutterEventChannel(name: eventChannelNameOnFindPhone, binaryMessenger:registrar.messenger())
      onFindPhoneChannel.setStreamHandler(instance)
      let onRequestLocationChannel = FlutterEventChannel(name: eventChannelNameOnRequestLocation, binaryMessenger:registrar.messenger())
      onRequestLocationChannel.setStreamHandler(instance)
      let onDeviceRequestAGpsFileChannel = FlutterEventChannel(name: eventChannelNameOnDeviceRequestAGpsFile, binaryMessenger:registrar.messenger())
      onDeviceRequestAGpsFileChannel.setStreamHandler(instance)
      let onReadBloodOxygenChannel = FlutterEventChannel(name: eventChannelNameOnReadBloodOxygen, binaryMessenger:registrar.messenger())
      onReadBloodOxygenChannel.setStreamHandler(instance)
      let onReadWorkoutChannel = FlutterEventChannel(name: eventChannelNameOnReadWorkout, binaryMessenger:registrar.messenger())
      onReadWorkoutChannel.setStreamHandler(instance)
      let onReadBleHrvChannel = FlutterEventChannel(name: eventChannelNameOnReadBleHrv, binaryMessenger:registrar.messenger())
      onReadBleHrvChannel.setStreamHandler(instance)
      let onReadPressureChannel = FlutterEventChannel(name: eventChannelNameOnReadPressure, binaryMessenger:registrar.messenger())
      onReadPressureChannel.setStreamHandler(instance)
      let onReadWorldClockChannel = FlutterEventChannel(name: eventChannelNameOnReadWorldClock, binaryMessenger:registrar.messenger())
      onReadWorldClockChannel.setStreamHandler(instance)
      let onWorldClockDeleteChannel = FlutterEventChannel(name: eventChannelNameOnWorldClockDelete, binaryMessenger:registrar.messenger())
      onWorldClockDeleteChannel.setStreamHandler(instance)
      let onDeviceConnectingChannel = FlutterEventChannel(name: eventChannelNameOnDeviceConnecting, binaryMessenger:registrar.messenger())
      onDeviceConnectingChannel.setStreamHandler(instance)
      let onIncomingCallStatusChannel = FlutterEventChannel(name: eventChannelNameOnIncomingCallStatus, binaryMessenger:registrar.messenger())
      onIncomingCallStatusChannel.setStreamHandler(instance)
      let onReceiveMusicCommandChannel = FlutterEventChannel(name: eventChannelNameOnReceiveMusicCommand, binaryMessenger:registrar.messenger())
      onReceiveMusicCommandChannel.setStreamHandler(instance)
      let onStockReadChannel = FlutterEventChannel(name: eventChannelNameOnStockRead, binaryMessenger:registrar.messenger())
      onStockReadChannel.setStreamHandler(instance)
      let onStockDeleteChannel = FlutterEventChannel(name: eventChannelNameOnStockDelete, binaryMessenger:registrar.messenger())
      onStockDeleteChannel.setStreamHandler(instance)
      let onBleErrorChannel = FlutterEventChannel(name: eventChannelNameOnBleError, binaryMessenger:registrar.messenger())
      onBleErrorChannel.setStreamHandler(instance)
  }

   init (_ channel: FlutterMethodChannel) {
       super.init()
        mBleScanner.mBleScanDelegate = self
        mBleScanner.mBleScanFilter = self
        mBleConnector.launch()
        mBleConnector.addBleHandleDelegate(String(obj: self), self)
      // ABHBackgroundMonitoring.share.startListening()
  }

 var bleKey: BleKey = BleKey.NONE
 var bleKeyFlag: BleKeyFlag=BleKeyFlag.NONE
    private func doBle(_ action: (BleConnector) -> Void) {
        let bleConnector = BleConnector.shared
        if bleConnector.isAvailable() {
            action(bleConnector)
        } else {
            print("BleConnector is not available!")
        }
    }



    private var controlViewStep = false
    private var controlViewStepX = 0
    private var controlViewStepY = 0

    // Heart rate
    private var controlViewHr = false
    private var controlViewHrX = 0
    private var controlViewHrY = 0

    // Calories
    private var controlViewCa = false
    private var controlViewCaX = 0
    private var controlViewCaY = 0

    // Distance
    private var controlViewDis = false
    private var controlViewDisX = 0
    private var controlViewDisY = 0

    // Digital time
    private var timeDigitalView = false
    private var timeDigitalViewWidth = 0

    // Pointer
    private var timePointView = false

    // Scale
    private var timeScaleView = false

    private var btnSync = false

    private var bgBitmapx: UIImage? = nil
    private var customizeDialBg: UIImage? = nil

    private var isRound = false // Whether it is a round screen
    private var roundCornerRadius: Float = 0 // The corner radius of the rounded rectangle
    private var screenReservedBoundary = 0 // The actual resolution of some devices is inconsistent with the displayed area, and the boundary needs to be reserved to avoid deviations, such as T88_pro devices
    private var controlValueInterval = 0 // Controls such as distance and steps, the distance interval between the picture and the number part below
    private var controlValueRange = 9 // The content of the digital part below the control such as distance and steps
    private var fileFormat = "png" // The original format of the image of the dial element is generally in png format, and Realtek's is in bmp format
    let faceBuilder = WatchFaceBuilder.sharedInstance
    private var imageFormat = WatchFaceBuilder.sharedInstance.BMP_565 // Image encoding, the default is 8888, Realtek is RGB565
    private var X_CENTER = WatchFaceBuilder.sharedInstance.GRAVITY_X_CENTER // Relative coordinate mark, MTK and Realtek have different implementations
    private var Y_CENTER = WatchFaceBuilder.sharedInstance.GRAVITY_Y_CENTER // Relative coordinate mark, MTK and Realtek have different implementations
//    private var borderSize = 0 // When drawing graphics, add the width of the ring
//    private var ignoreBlack = 0 // Whether to ignore black, 0-do not ignore; 1-ignore

    var screenWidth = 0 // The actual size of the device screen - width
    var screenHeight = 0 // The actual size of the device screen - height
    var screenPreviewWidth = 0 // The actual preview size of the device screen - width
    var screenPreviewHeight = 0 // The actual preview size of the device screen - height
    var digiLeft = 0
    var digiTop = 0

//    var valueColor = 0
   var custom = 0

    func convertToPNG(image: UIImage) -> UIImage? {
        guard let pngData = image.pngData() else {
            return nil
        }

        return UIImage(data: pngData)
    }

    func startCreateBinFile(){
         bleBin = BleWatchFaceBin()
         imageCountStart = 0
         pointerHourImageSize = [UInt32]()
         pointerMinImageSize = [UInt32]()
         pointerImageSize  = [UInt32]()

         timeAMImageSize  = [UInt32]()

         timeDateHourImageSize = [UInt32]()
         timeDateSymbolImageSize  = [UInt32]()
         timeDateMinImageSize  = [UInt32]()

         timeWeekMonthImageSize = [UInt32]()
         timeWeekSymbolImageSize  = [UInt32]()
         timeWeekDayImageSize  = [UInt32]()
         timeWeekImageSize   = [UInt32]()

         stepImageSize  = [UInt32]()
         hrImageSize  = [UInt32]()
         disImageSize  = [UInt32]()
         calImageSize  = [UInt32]()

         pointerHourBuffer = Data()
         pointerMinBuffer = Data()
         pointerBuffer = Data()

         timeAMBuffer = Data()

         timeDateHourBuffer = Data()
         timeDateSymbolBuffer = Data()
         timeDateMinBuffer = Data()

         timeWeekMonthBuffer = Data()
         timeWeekSymbolBuffer = Data()
         timeWeekDayBuffer = Data()
         timeWeekBuffer = Data()

         stepBuffer = Data()
         hrBuffer = Data()
         disBuffer = Data()
         calBuffer = Data()

         timeAMSize  = CGSize()
         timeDateHourSize  = CGSize()
         timeDateMinSize  = CGSize()
         timeWeekMonthSize  = CGSize()
         timeWeekDaySize  = CGSize()
         timeWeekSize  = CGSize()

         stepSize = CGSize()
         hrSize = CGSize()
         disSize = CGSize()
         calSize = CGSize()

         hourSize = CGSize()
         minSize = CGSize()
         secSize = CGSize()

        var IgnoreBlack = UInt8(1)//默认为0 , bmp相关的图片用1
        var isFixCoordinate = true

        let dataSourceArray = getItemsPiont() as! Dictionary<String, Any>
        let image150 = getThumbnailImage()
        let image240 = getMainBgImage()

        isBmpResoure = true
//        if custom == 2 {
//            isBmpResoure = false
////            IgnoreBlack = UInt8(0)
//          //  isFixCoordinate = false
//        }
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

        bgWidth16  = UInt16(screenWidth)
        bgHeight16 = UInt16(screenHeight)
        pvWidth  = UInt16(screenPreviewWidth)
        pvHeight = UInt16(screenPreviewHeight)

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
        newElement.ignoreBlack = IgnoreBlack //背景缩略图固定为0
        newElement.x = bgX
        newElement.y = bgY
        newElement.bottomOffset = 0
        newElement.leftOffset = 0
        newElement.imageCount = UInt8(1)
         //buffer每个元素大小
        var newByte :Data = getBackBuffer(image240)
        newElement.imageSizes = [UInt32(newByte.count)]
        newElement.imageBuffer = newByte
        newArray.append(newElement)


        var newElement1 :Element = Element()
        newElement1.type = UInt8(faceBuilder.ELEMENT_PREVIEW)
        newElement1.w = pvWidth
        newElement1.h = pvHeight
        newElement1.gravity = ylGravity
        newElement1.ignoreBlack = IgnoreBlack
        newElement1.x = pvX
        newElement1.y = pvY
        newElement1.bottomOffset = 0
        newElement1.leftOffset = 0
        newElement1.imageCount = UInt8(1)
        var newByte1 :Data = getBackBuffer(image150)
        newElement1.imageSizes = [UInt32(newByte1.count)] //buffer每个元素大小
        newElement1.imageBuffer = newByte1
        newArray.append(newElement1)

        //处理其他元素
        let timeColor = UIColor.white
        let itemColor = UIColor.white
        var itemC = "_bmp_"
        var imageType = "png"
        if isBmpResoure {
            itemC = "_bmp_"
            imageType = "bmp"
        }
        for (key,value) in dataSourceArray {

            if key.elementsEqual("TimeAM"){
                bleLog("TimeAM is \(value)")
                let point :CGPoint = dataSourceArray["TimeAM"] as! CGPoint
                bleLog("TimeAM is \(point)")
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
                    weekPoint = CGPoint(x: point.x-(timeWeekSize.width * 0.5), y: weekY)
                }

                amElement.type = UInt8(faceBuilder.ELEMENT_DIGITAL_AMPM)
                amElement.gravity = apmGravity
                amElement.ignoreBlack = IgnoreBlack
                amElement.bottomOffset = 0
                amElement.leftOffset = UInt8(0)
                amElement.imageCount = UInt8(amArray.count)
                amElement.w = UInt16(timeAMSize.width)
                amElement.h = UInt16(timeAMSize.height)
                amElement.x = UInt16(point.x - timeAMSize.width)
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
                hourElement.w = UInt16(timeDateHourSize.width * imageWidth)
                hourElement.h = UInt16(timeDateHourSize.height)
                hourElement.x = UInt16(max(0, hourPoint.x))
                hourElement.y = UInt16(max(0, hourPoint.y))
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
                dateSyElement.x = UInt16(max(0,dateSyPoint.x))
                dateSyElement.y = UInt16(max(0,dateSyPoint.y))
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
                minElement.x = UInt16(max(0,minPoint.x))
                minElement.y = UInt16(max(0,minPoint.y))
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
                monthElement.x = UInt16(max(0,monthPoint.x))
                monthElement.y = UInt16(max(0,monthPoint.y))
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
                weekSymElement.x = UInt16(max(0,monthSyPoint.x))
                weekSymElement.y = UInt16(max(0,monthSyPoint.y))
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
                weekDayElement.x = UInt16(max(0,dayPoint.x))
                weekDayElement.y = UInt16(max(0,dayPoint.y))
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
                weekElement.x = UInt16(max(0,weekPoint.x))
                weekElement.y = UInt16(max(0,weekPoint.y))
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
           // let sendData = buildWatchFace(newArray, newArray.count,Int32(faceBuilder.BMP_565))
            bleLog("bin文件大小 - \(sendData.toData().count)")
            if mBleConnector.sendStream(.WATCH_FACE, sendData.toData(),0){
                bleLog("sendStream - WATCH_FACE")
            }

        }
    }

    var controlViewSize = 38

    func getItemsPiont() -> NSMutableDictionary{
        /**
         the coordinate points will be offset due to the resource image and view size. please adjust the coordinate points according to the device and app UI design.
         */
        let newDic = NSMutableDictionary()
        //计算比例尺
        var scaleW = screenWidth/240
        var scaleH = screenHeight/240

        if (custom == 2){
            scaleW = screenWidth/454
            scaleH = screenHeight/454
            controlViewSize = 60
        }

        if controlViewHr == true {
            //W 37 H 37 piont-> data below icon
//            let rect :CGRect = bg_hr.frame
            // let piont  = CGPoint(x: (rect.origin.x+(37/2))/scaleW, y: (rect.origin.y+rect.size.height+15)/scaleH)
            //let piont  = CGPoint(x: (controlViewHrX + (controlViewSize/2))/scaleW, y: (controlViewHrY + controlViewSize + 15)/scaleH)
            let piont  = CGPoint(x:controlViewSize/2+controlViewHrX, y:controlViewSize+8+controlViewHrY)
            newDic.setValue(piont, forKey: "HR")
        }

        if controlViewCa == true {
            //W 37 H 37
            // let piont  = CGPoint(x: (rect.origin.x+(rect.size.width/2))/scaleW, y: (rect.origin.y+rect.size.height+15)/scaleH)
           // let piont  = CGPoint(x: (controlViewCaX + (controlViewSize/2))/scaleW, y: (controlViewCaY + controlViewSize + 15)/scaleH)
            let piont  = CGPoint(x:controlViewSize/2+controlViewCaX, y:controlViewSize+8+controlViewCaY)
            newDic.setValue(piont, forKey: "Cal")
        }

        if controlViewDis == true {
            //W 37 H 37
            // let rect :CGRect = bg_dis.frame
            // let piont  = CGPoint(x: (rect.origin.x+rect.size.width)/scaleW, y: (rect.origin.y+rect.size.height+15)/scaleH)
           // let piont  = CGPoint(x: (controlViewDisX + (controlViewSize/2))/scaleW, y: (controlViewDisY + controlViewSize + 15)/scaleH)
            let piont  = CGPoint(x:Int(Double(controlViewSize)/1.2)+controlViewDisX, y:controlViewSize+8+controlViewDisY)
            newDic.setValue(piont, forKey: "Dis")
        }

        if controlViewStep == true {
            //W 37 H 37
            // let rect :CGRect = bg_step.frame
            // let piont  = CGPoint(x: (rect.origin.x+(rect.size.width/2))/scaleW, y: (rect.origin.y+rect.size.height+15)/scaleH)
            let piont  = CGPoint(x:controlViewSize/2+controlViewStepX, y:controlViewSize+8+controlViewStepY)
            newDic.setValue(piont, forKey: "Step")
        }

        if timeDigitalView == true {
            //W 165 H 100 piont-> the coordinates of the upper right corner of the "digital_time" example
            // let rect :CGRect = digitalTime.frame
            // let piontAM  = CGPoint(x: (rect.origin.x + rect.size.width)/scaleW, y: rect.origin.y/scaleH)
            let piont  = CGPoint(x:digiLeft+Int(screenWidth/2), y: digiTop)
            newDic.setValue(piont, forKey: "TimeAM")
        }else{
            /**
             this is a watch type dial, and only the resource pictures of the hour hand, minute hand, and second hand are transmitted.
             the scale and background image are combined as a new image to transfer to the device
             */
            newDic.setValue("1", forKey: "PointerNumber")
        }
        return newDic
    }



    func buildWatchFace(_ elements:[Element],_ elementCount:Int,_ imageFormat:Int32) ->BleWatchFaceBin{
        bleBin = BleWatchFaceBin()
        bleBin.header = nil
        //header
        bleBin.header = BleWatchFaceBinToHeader.init(ImageTotal: UInt16(imageCountStart), ElementCount: UInt8(elements.count), ImageFormat: UInt8(imageFormat))

        // ElementInfo[]
        var imageSizeIndex :UInt16 = 0
        var infoSize : Int = elementCount * BleWatchFaceBinElementInfo.ITEM_LENGTH
        bleBin.ElementInfo.removeAll()
        for i in 0..<elementCount {
            var newInfo = BleWatchFaceBinElementInfo.init(imageBufferOffset: 0, imageSizeIndex: imageSizeIndex, w: elements[i].w, h: elements[i].h, x: elements[i].x, y: elements[i].y, imageCount: elements[i].imageCount, type: elements[i].type, gravity: elements[i].gravity,ignoreBlack:  elements[i].ignoreBlack, bottomOffset: elements[i].bottomOffset, leftOffset: elements[i].leftOffset, reserved: 0)
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
        let image16 :Data = ImageHelper.convertUIImage(toBitmapRGB565: imageBuffer)! as Data
        //小端序修改为大端序
        var index = 0
        var newByte :Data = imageBuffer.pngData()!
        newByte.removeAll()
        while index<image16.count{
            let item1 = image16[index]
            let item2 = image16[index+1]
            newByte.append(item2)
            newByte.append(item1)
            index += 2
        }
        return newByte
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
        var itemC = "_bmp_"
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
        if custom == 2 {
           imageSize = "device454_"
        } else {
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
        var pHour = getImageDeviceType()+"pointerHour_bmp_"
        var pMinute = getImageDeviceType()+"pointerminute_bmp_"
        var pSecond = getImageDeviceType()+"pointerSecond_bmp_"
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



    func showImageDialog(image: UIImage) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)

        let imageView = UIImageView(image: image)
        alertController.view.addSubview(imageView)

        let imageHeight = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
        let imageWidth = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
        imageView.addConstraints([imageHeight, imageWidth])

        let closeAction = UIAlertAction(title: "Close", style: .default, handler: nil)
        alertController.addAction(closeAction)

        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            rootViewController.present(alertController, animated: true, completion: nil)
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

    func getImageSize(_ imageName:String, ofType:String)-> CGSize{
        let path = Bundle.main.path(forResource: imageName, ofType: ofType)
        let newImage = UIImage(contentsOfFile: path!)
        return CGSize(width: newImage!.size.width, height: newImage!.size.height)
    }

    var bgImage: [UInt8]? = nil
    var thumbImage: [UInt8]? = nil

    func getMainBgImage()->UIImage{
        let image = UIImage(data: Data(bgImage!))!
        return convertToPNG(image: image)!
    }


    func getThumbnailImage() -> UIImage{//Thumbnail preview
        let image = UIImage(data: Data(thumbImage!))!
        return convertToPNG(image: image)!
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


    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
        let args = call.arguments as? Dictionary<String, Any>
        let flag = args?["flag"] as? String
        let mtd = call.method
        switch mtd {
        case "scan":
            let isScan = args?["isScan"] as? Bool ?? false
            mBleScanner.scan(isScan)
            break;
        case "setAddress":
            let bmac = (args?["bmac"] as? String)!
            mBleConnector.setTargetIdentifier(bmac)
            break;
       case "connect":
            mBleScanner.scan(false)
            mBleConnector.connect(true)
            break;
        case "isConnecting":
            result(mBleConnector.isConnecting)
             break;
        case "isBound":
            result(mBleConnector.isBound())
             break;
        case "disconnect":
            mBleConnector.connect(false)
            break;
        case "isAvailable":
            result(mBleConnector.isAvailable())
             break;
        case "closeConnection":
            mBleConnector.closeConnection(true)
             break;
        case "unbind":
            mBleConnector.unbind()
             break;
        case "customDials":
            timeDigitalView = args?["isDigital"] as! Bool
            isRound = args?["isRound"] as! Bool
            custom = args?["custom"] as! Int
            screenWidth = args?["screenWidth"] as! Int
            screenHeight = args?["screenHeight"] as! Int

            digiLeft = args?["digiLeft"] as! Int
            digiTop = args?["digiTop"] as! Int

            screenPreviewWidth = args?["screenPreviewWidth"] as! Int
            screenPreviewHeight = args?["screenPreviewHeight"] as! Int

            controlViewStep = args?["controlViewStep"] as! Bool
            controlViewStepX = args?["controlViewStepX"] as! Int
            controlViewStepY = args?["controlViewStepY"] as! Int

            controlViewCa = args?["controlViewCa"] as! Bool
            controlViewCaX = args?["controlViewCaX"] as! Int
            controlViewCaY = args?["controlViewCaY"] as! Int

            controlViewDis = args?["controlViewDis"] as! Bool
            controlViewDisX = args?["controlViewDisX"] as! Int
            controlViewDisY = args?["controlViewDisY"] as! Int

            controlViewHr = args?["controlViewHr"] as! Bool
            controlViewHrX = args?["controlViewHrX"] as! Int
            controlViewHrY = args?["controlViewHrY"] as! Int


            if let data = args?["bgBytes"] as? FlutterStandardTypedData {
                bgImage = [UInt8](data.data)
                // Use the 'bytes' array here
            } else {
                // Handle the case when 'bgPreviewBytes' is not in the expected format
            }
            if let data = args?["bgPreviewBytes"] as? FlutterStandardTypedData {
                thumbImage = [UInt8](data.data)
                // Use the 'bytes' array here
            } else {
                // Handle the case when 'bgPreviewBytes' is not in the expected format
            }


//            controlValueInterval = 1
//            ignoreBlack = 1
//            controlValueRange = 10
//
//            fileFormat = "bmp"
//            imageFormat = faceBuilder.BMP_565
//            X_CENTER = faceBuilder.GRAVITY_X_CENTER_R
//            Y_CENTER = faceBuilder.GRAVITY_Y_CENTER_R
            self.startCreateBinFile()
            break;
        case "OTA":
            bleKey = BleKey.OTA
            break;
        case "XMODEM":
            bleKey = BleKey.XMODEM
            break;
        case "TIME":
            bleKey = BleKey.TIME
            break;
        case "TIME_ZONE":
            bleKey = BleKey.TIME_ZONE
            break;
        case "POWER":
            bleKey = BleKey.POWER
            break;
        case "FIRMWARE_VERSION":
            bleKey = BleKey.FIRMWARE_VERSION
            break;
        case "BLE_ADDRESS":
            bleKey = BleKey.BLE_ADDRESS
            break;
        case "USER_PROFILE":
            bleKey = BleKey.USER_PROFILE
            break;
        case "STEP_GOAL":
            bleKey = BleKey.STEP_GOAL
            break;
        case "BACK_LIGHT":
            bleKey = BleKey.BACK_LIGHT
            break;
        case "SEDENTARINESS":
            bleKey = BleKey.SEDENTARINESS
            break;
        case "NO_DISTURB_RANGE":
            bleKey = BleKey.NO_DISTURB_RANGE
            break;
        case "VIBRATION":
            bleKey = BleKey.VIBRATION
            break;
        case "GESTURE_WAKE":
            bleKey = BleKey.GESTURE_WAKE
            break;
        case "HR_ASSIST_SLEEP":
            bleKey = BleKey.HR_ASSIST_SLEEP
            break;
        case "HOUR_SYSTEM":
            bleKey = BleKey.HOUR_SYSTEM
            break;
        case "LANGUAGE":
            bleKey = BleKey.LANGUAGE
            break;
        case "ALARM":
            bleKey = BleKey.ALARM
            break;
        case "COACHING":
            bleKey = BleKey.COACHING
            break;
        case "FIND_PHONE":
            bleKey = BleKey.FIND_PHONE
            break;
        case "NOTIFICATION_REMINDER":
            bleKey = BleKey.NOTIFICATION_REMINDER
            break;
        case "ANTI_LOST":
            bleKey = BleKey.ANTI_LOST
            break;
        case "HR_MONITORING":
            bleKey = BleKey.HR_MONITORING
            break;
        case "UI_PACK_VERSION":
            bleKey = BleKey.UI_PACK_VERSION
            break;
        case "LANGUAGE_PACK_VERSION":
            bleKey = BleKey.LANGUAGE_PACK_VERSION
            break;
        case "SLEEP_QUALITY":
            bleKey = BleKey.SLEEP_QUALITY
            break;
//        case "GIRL_CARE":
//            bleKey = BleKey.GIRLCARE
        case "TEMPERATURE_DETECTING":
            bleKey = BleKey.TEMPERATURE_DETECTING
            break;
        case "AEROBIC_EXERCISE":
            bleKey = BleKey.AEROBIC_EXERCISE
            break;
        case "TEMPERATURE_UNIT":
            bleKey = BleKey.TEMPERATURE_UNIT
            break;
        case "DATE_FORMAT":
            bleKey = BleKey.DATE_FORMAT
            break;
        case "WATCH_FACE_SWITCH":
            bleKey = BleKey.WATCH_FACE_SWITCH
            break;
        case "AGPS_PREREQUISITE":
            bleKey = BleKey.AGPS_PREREQUISITE
            break;
        case "DRINK_WATER":
            bleKey = BleKey.DRINKWATER
            break;
//        case "SHUTDOWN":
//            bleKey = BleKey.SHUTDOWN
        case "APP_SPORT_DATA":
            bleKey = BleKey.APP_SPORT_DATA
            break;
        case "REAL_TIME_HEART_RATE":
            bleKey = BleKey.REAL_TIME_HEART_RATE
            break;
        case "BLOOD_OXYGEN_SET":
            bleKey = BleKey.BLOOD_OXYGEN_SET
            break;
        case "WASH_SET":
            bleKey = BleKey.WASH_SET
            break;
        case "WATCHFACE_ID":
            bleKey = BleKey.WATCHFACE_ID
            break;
        case "IBEACON_SET":
            bleKey = BleKey.IBEACON_SET
            break;
        case "MAC_QRCODE":
            bleKey = BleKey.MAC_QRCODE
            break;
        case "REAL_TIME_TEMPERATURE":
            bleKey = BleKey.REAL_TIME_TEMPERATURE
            break;
        case "REAL_TIME_BLOOD_PRESSURE":
            bleKey = BleKey.REAL_TIME_BLOOD_PRESSURE
            break;
        case "TEMPERATURE_VALUE":
            bleKey = BleKey.TEMPERATURE
            break;
        case "GAME_SET":
            bleKey = BleKey.GAME_SET
            break;
        case "FIND_WATCH":
            bleKey = BleKey.FIND_WATCH
            break;
        case "SET_WATCH_PASSWORD":
            bleKey = BleKey.SET_WATCH_PASSWORD
            break;
        case "REALTIME_MEASUREMENT":
            bleKey = BleKey.REALTIME_MEASUREMENT
            break;
//        case "LOCATION_GSV":
//            bleKey = BleKey.LOCATION_GSV
//        case "HR_RAW":
//            bleKey = BleKey.HR_RAW
        case "REALTIME_LOG":
            bleKey = BleKey.REALTIME_LOG
            break;
        case "GSENSOR_OUTPUT":
            bleKey = BleKey.GSENSOR_OUTPUT
            break;
        case "GSENSOR_RAW":
            bleKey = BleKey.GSENSOR_RAW
            break;
        case "MOTION_DETECT":
            bleKey = BleKey.MOTION_DETECT
            break;
        case "LOCATION_GGA":
            bleKey = BleKey.LOCATION_GGA
            break;
        case "RAW_SLEEP":
            bleKey = BleKey.RAW_SLEEP
            break;
        case "NO_DISTURB_GLOBAL":
            bleKey = BleKey.NO_DISTURB_GLOBAL
            break;
        case "IDENTITY":
            bleKey = BleKey.IDENTITY
            break;
        case "SESSION":
            bleKey = BleKey.SESSION
            break;
        case "NOTIFICATION":
            bleKey = BleKey.NOTIFICATION_REMINDER
            break;
        case "MUSIC_CONTROL":
            bleKey = BleKey.MUSIC_CONTROL
            break;
        case "SCHEDULE":
            bleKey = BleKey.SCHEDULE
            break;
        case "WEATHER_REALTIME":
            bleKey = BleKey.WEATHER_REALTIME
            break;
        case "WEATHER_FORECAST":
            bleKey = BleKey.WEATHER_FORECAST
            break;
//        case "HID":
//            bleKey = BleKey.HID
        case "WORLD_CLOCK":
            bleKey = BleKey.WORLD_CLOCK
            break;
        case "STOCK":
            bleKey = BleKey.STOCK
            break;
//        case "SMS_QUICK_REPLY_CONTENT":
//            bleKey = BleKey.SMS_QUICK_REPLY_CONTENT
        case "NOTIFICATION2":
            bleKey = BleKey.NOTIFICATION_REMINDER
            break;
        case "DATA_ALL":
            bleKey = BleKey.DATA_ALL
            break;
        case "ACTIVITY_REALTIME":
            bleKey = BleKey.ACTIVITY_REALTIME
            break;
        case "ACTIVITY":
            bleKey = BleKey.ACTIVITY
            break;
        case "HEART_RATE":
            bleKey = BleKey.HEART_RATE
            break;
        case "SLEEP":
            bleKey = BleKey.SLEEP
            break;
        case "LOCATION":
            bleKey = BleKey.LOCATION
            break;
        case "TEMPERATURE":
            bleKey = BleKey.TEMPERATURE
            break;
        case "BLOOD_OXYGEN":
            bleKey = BleKey.BLOODOXYGEN
            break;
        case "HRV":
            bleKey = BleKey.HRV
            break;
        case "LOG":
            bleKey = BleKey.LOG
            break;
        case "SLEEP_RAW_DATA":
            bleKey = BleKey.SLEEP_RAW_DATA
            break;
        case "PRESSURE":
            bleKey = BleKey.PRESSURE
            break;
        case "WORKOUT2":
            bleKey = BleKey.WORKOUT2
            break;
        case "MATCH_RECORD":
            bleKey = BleKey.MATCH_RECORD
            break;
        case "CAMERA":
            bleKey = BleKey.CAMERA
            break;
        case "REQUEST_LOCATION":
            bleKey = BleKey.PHONE_GPSSPORT
            break;
//        case "INCOMING_CALL":
//            bleKey = BleKey.INCOMING_CALL
        case "APP_SPORT_STATE":
            bleKey = BleKey.APP_SPORT_STATE
            break;
//        case "CLASSIC_BLUETOOTH_STATE":
//            bleKey = BleKey.CLASSIC_BLUETOOTH_STATE
//        case "DEVICE_SMS_QUICK_REPLY":
//            bleKey = BleKey.DEVICE_SMS_QUICK_REPLY
        case "WATCH_FACE":
            bleKey = BleKey.WATCH_FACE
            break;
        case "AGPS_FILE":
            bleKey = BleKey.AGPS_FILE
            break;
        case "FONT_FILE":
            bleKey = BleKey.FONT_FILE
            break;
        case "CONTACT":
            bleKey = BleKey.CONTACT
            break;
        case "UI_FILE":
            bleKey = BleKey.UI_FILE
            break;
//        case "DEVICE_FILE":
//            bleKey = BleKey.DEVICE_FILE
        case "LANGUAGE_FILE":
            bleKey = BleKey.LANGUAGE_FILE
            break;
//        case "BRAND_INFO_FILE":
//            bleKey = BleKey.BRAND_INFO_FILE
        case "BLOOD_PRESSURE":
            bleKey = BleKey.BLOOD_PRESSURE
            break;
        default:
            bleKey=BleKey.NONE
    }
        switch flag {
            case "UPDATE":
                bleKeyFlag=BleKeyFlag.UPDATE
                break;
            case "READ":
                bleKeyFlag=BleKeyFlag.READ
                break;
            case "CREATE":
                bleKeyFlag=BleKeyFlag.CREATE
                break;
            case "DELETE":
                bleKeyFlag=BleKeyFlag.DELETE
                break;
            default:
                bleKeyFlag=BleKeyFlag.NONE
        }
      if bleKey == BleKey.IDENTITY {
          if bleKeyFlag == BleKeyFlag.DELETE {
              if BleConnector.shared.isAvailable() {
                  _ = BleConnector.shared.sendData(bleKey, bleKeyFlag)
              }
              BleConnector.shared.unbind()
             // unbindCompleted()
              return
          }
      }
      if !BleConnector.shared.isAvailable() {
          bleLog("device not connected")
          return
      }
      doBle { bleConnector in
          switch bleKey {
              // BleCommand.UPDATE
          case BleKey.OTA:
             // gotoOta()
              let url = args?["url"] as? String
              // Perform your network request to obtain the filePath
              print("url \(String(describing: url))")
              self.performNetworkRequest(urlString: String(url ?? "")) { [weak self] (fileURL) in
                  self?.filePath = fileURL ?? ""
                  print("performNetworkRequest - \(self?.filePath ?? "")")

                  let fileManager = FileManager.default
                  if fileManager.fileExists(atPath: self?.filePath ?? "") {
                      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                          self?.readyJLOTA()
                      }
                  } else {
                      print("File does not exist at the specified path.")
                  }


              }
              print("OTA")
          case BleKey.XMODEM:
              _ = bleConnector.sendData(bleKey, bleKeyFlag)

              // BleCommand.SET
          case BleKey.TIME:
              if bleKeyFlag == BleKeyFlag.UPDATE {
                  //设置设备时间
                  _ = bleConnector.sendObject(bleKey, bleKeyFlag, BleTime.local())
              } else if bleKeyFlag == BleKeyFlag.READ {
                  //READ
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          case BleKey.TIME_ZONE:
              if bleKeyFlag == BleKeyFlag.UPDATE {
                  //设置设备时区
                  _ = bleConnector.sendObject(bleKey, bleKeyFlag, BleTimeZone())
              } else if bleKeyFlag == BleKeyFlag.READ {
                  //READ
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          case BleKey.POWER:
              //bleKeyFlag =  BleKeyFlag.READ 获取设备电量
              _ = bleConnector.sendData(bleKey, bleKeyFlag)
          case BleKey.FIRMWARE_VERSION:
              //bleKeyFlag =  BleKeyFlag.READ 获取设备固件版本号
              _ = bleConnector.sendData(bleKey, bleKeyFlag)
          case BleKey.BLE_ADDRESS:
              //bleKeyFlag =  BleKeyFlag.READ 获取设备Mac地址
              _ = bleConnector.sendData(bleKey, bleKeyFlag)
          case BleKey.USER_PROFILE:
              if bleKeyFlag == BleKeyFlag.UPDATE {
                  //更新设备上的用户个人信息
                  let bleUserProfile = BleUserProfile(0, 0, 20, 170.0, 60.0)
                  _ = bleConnector.sendObject(bleKey, bleKeyFlag, bleUserProfile)
              } else if bleKeyFlag ==  BleKeyFlag.READ {
                  //READ
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          case BleKey.STEP_GOAL:
              if bleKeyFlag == BleKeyFlag.UPDATE {
                  //更新设备上的运动目标
                  _ = bleConnector.sendInt32(bleKey, bleKeyFlag, 0x1234)
              } else if bleKeyFlag ==  BleKeyFlag.READ {
                  //READ
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          case BleKey.BACK_LIGHT:
              if bleKeyFlag ==  BleKeyFlag.UPDATE {
                  //背光设置
                  let times = (args?["times"] as? Int)
                  if times != nil {
                      _ = bleConnector.sendInt8(bleKey, bleKeyFlag, times!)
                  } // 0 is off, or 5 ~ 20
              } else if bleKeyFlag ==  BleKeyFlag.READ {
                  //READf
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          case BleKey.WORLD_CLOCK:
              // Create a clock
              let index = (args?["index"] as? Int)
              let isLocal = (args?["isLocal"] as? Int)
              let mTimeZoneOffset = (args?["mTimeZoneOffSet"] as? Int)
              let reversed = (args?["reversed"] as? Int)
              let mCityName = (args?["mCityName"] as? String)

               if bleKeyFlag == .CREATE {
                   let worldClock = BleWorldClock()
                   worldClock.mLocal = isLocal ?? 0
                   worldClock.mTimeZoneOffset = mTimeZoneOffset ?? 0 / 1000 / 60 / 15
                   worldClock.mReversed = reversed ?? 0
                   worldClock.mCityName = mCityName ?? ""
                   _ = mBleConnector.sendObject(
                       bleKey,
                       bleKeyFlag,
                       worldClock
                   )
               } else if bleKeyFlag == .DELETE {
                   // If there are clocks in the cache, delete the first one
                   let clocks: [BleWorldClock] = BleCache.shared.getArray(.WORLD_CLOCK)
                   if !clocks.isEmpty {
                       _ =  bleConnector.sendInt8(bleKey, bleKeyFlag, clocks[index ?? 0].mId)
                   }
               } else if bleKeyFlag == .UPDATE {
                   let clocks: [BleWorldClock] = BleCache.shared.getArray(.WORLD_CLOCK)
                   if !clocks.isEmpty {
                       let clock = clocks[index ?? 0]
                           clock.mLocal = clock.mLocal == 0 ? 1 : 0
                           _ =  mBleConnector.sendObject(bleKey, bleKeyFlag, clock)
                   }
               } else if bleKeyFlag == .READ {
                   // Read all clocks from the device
                   _ = mBleConnector.sendInt8(bleKey, bleKeyFlag, ID_ALL)
               }
              break
          case BleKey.WEATHER_REALTIME:

                  let weatherRealTime = args?["realTime"] as? String
              print("weatherRealTime \(String(describing: weatherRealTime))")
              let realTime = try? JSONSerialization.jsonObject(with: weatherRealTime?.data(using: .utf8) ?? Data(), options: []) as? [String:Any]
                      if bleKeyFlag == .UPDATE {
                          print("WEATHER_REALTIME \(String(describing: realTime!["mCurrentTemperature"]) )")
                          let bleWeather = BleWeather()
                          bleWeather.mCurrentTemperature = ("\(realTime!["mCurrentTemperature"] ?? 0)" as NSString).integerValue
                          bleWeather.mMaxTemperature =  ("\(realTime!["mMaxTemperature"] ?? 0)" as NSString).integerValue
                          bleWeather.mMinTemperature = ("\(realTime!["mMinTemperature"] ?? 0)" as NSString).integerValue
                          bleWeather.mWeatherCode = ("\(realTime!["mWeatherCode"] ?? 0)" as NSString).integerValue
                          bleWeather.mWindSpeed = 1
                          bleWeather.mHumidity = 1
                          bleWeather.mVisibility = 1
                          bleWeather.mUltraVioletIntensity = 1
                          bleWeather.mPrecipitation = 1
                         let bleWeatherRealtime = BleWeatherRealtime()
                          bleWeatherRealtime.mTime = Int(Date().timeIntervalSince1970)
                          bleWeatherRealtime.mWeather = bleWeather
                          _ = mBleConnector.sendObject(
                              BleKey.WEATHER_REALTIME,
                              bleKeyFlag,
                              bleWeatherRealtime
                          )
                      }


              break
          case BleKey.WEATHER_FORECAST:

                  let weatherForecast1 = args?["forecast1"] as? String
                  let weatherForecast2 = args?["forecast2"] as? String
                  let weatherForecast3 = args?["forecast3"] as? String
              let forecast1 = try? JSONSerialization.jsonObject(with: weatherForecast1?.data(using: .utf8) ?? Data(), options: []) as? [String:Any]
              let forecast2 = try? JSONSerialization.jsonObject(with: weatherForecast2?.data(using: .utf8) ?? Data(), options: []) as? [String:Any]
              let forecast3 = try? JSONSerialization.jsonObject(with: weatherForecast3?.data(using: .utf8) ?? Data(), options: []) as? [String:Any]
                      if bleKeyFlag == .UPDATE {
                          let currentTime = Date().timeIntervalSince1970
                          let oneDayInSeconds: TimeInterval = 24 * 60 * 60
                          let tomorrowTime = currentTime + oneDayInSeconds
                          let tomorrowDate = Date(timeIntervalSince1970: tomorrowTime)
                          print("mCurrentTemperature \(String(describing: forecast1!["mCurrentTemperature"]) )")
                          let bleWeather = BleWeather()
                          bleWeather.mCurrentTemperature = ("\(forecast1!["mCurrentTemperature"] ?? 0)" as NSString).integerValue
                          bleWeather.mMaxTemperature =  ("\(forecast1!["mMaxTemperature"] ?? 0)" as NSString).integerValue
                          bleWeather.mMinTemperature = ("\(forecast1!["mMinTemperature"] ?? 0)" as NSString).integerValue
                          bleWeather.mWeatherCode = ("\(forecast1!["mWeatherCode"] ?? 0)" as NSString).integerValue
                          bleWeather.mWindSpeed = 2
                          bleWeather.mHumidity = 2
                          bleWeather.mVisibility = 2
                          bleWeather.mUltraVioletIntensity = 2
                          bleWeather.mPrecipitation = 2

                          let bleWeather2 = BleWeather()
                          bleWeather.mCurrentTemperature = ("\(forecast2!["mCurrentTemperature"] ?? 0)" as NSString).integerValue
                          bleWeather.mMaxTemperature =  ("\(forecast2!["mMaxTemperature"] ?? 0)" as NSString).integerValue
                          bleWeather.mMinTemperature = ("\(forecast2!["mMinTemperature"] ?? 0)" as NSString).integerValue
                          bleWeather.mWeatherCode = ("\(forecast2!["mWeatherCode"] ?? 0)" as NSString).integerValue
                          bleWeather2.mWindSpeed = 3
                          bleWeather2.mHumidity = 3
                          bleWeather2.mVisibility = 3
                          bleWeather2.mUltraVioletIntensity = 3
                          bleWeather2.mPrecipitation = 3

                          let bleWeather3 = BleWeather()
                          bleWeather.mCurrentTemperature = ("\(forecast3!["mCurrentTemperature"] ?? 0)" as NSString).integerValue
                          bleWeather.mMaxTemperature =  ("\(forecast3!["mMaxTemperature"] ?? 0)" as NSString).integerValue
                          bleWeather.mMinTemperature = ("\(forecast3!["mMinTemperature"] ?? 0)" as NSString).integerValue
                          bleWeather.mWeatherCode = ("\(forecast3!["mWeatherCode"] ?? 0)" as NSString).integerValue
                          bleWeather3.mWindSpeed = 4
                          bleWeather3.mHumidity = 4
                          bleWeather3.mVisibility = 4
                          bleWeather3.mUltraVioletIntensity = 4
                          bleWeather3.mPrecipitation = 4

                         let bleWeatherForecast = BleWeatherForecast()
                          bleWeatherForecast.mTime = Int(Date().timeIntervalSince1970)
                          bleWeatherForecast.mWeather1 = bleWeather
                          bleWeatherForecast.mWeather2 = bleWeather2
                          bleWeatherForecast.mWeather3 = bleWeather3

                          _ = mBleConnector.sendObject(
                              BleKey.WEATHER_FORECAST,
                              bleKeyFlag,
                              bleWeatherForecast
                          )
                      }

              break
          case BleKey.STOCK:
              let index = args?["index"] as? Int
              let dataStock = args?["stock"] as? String
              if let convertStock = try? JSONSerialization.jsonObject(with: dataStock?.data(using: .utf8) ?? Data(), options: []) as? [String: Any] {
                  print("dataStockSM - \(index ?? 0) -> \(convertStock)")
                  var open : Float = 0.0
                  if let stringValue = convertStock["open"] as? String,
                      let numericValue = Float(stringValue) {
                      open = Float(numericValue)
                      // Use the converted value here
                  } else {
                       open = 0.0
                      // Handle the case where the conversion fails
                  }
                  var close : Float = 0.0
                  if let stringValue = convertStock["close"] as? String,
                      let numericValue = Float(stringValue) {
                      close = Float(numericValue)
                      // Use the converted value here
                  } else {
                      close = 0.0
                      // Handle the case where the conversion fails
                  }
                  var volume : Float = 0.0
                  if let stringValue = convertStock["volume"] as? String,
                      let numericValue = Float(stringValue) {
                      volume = Float(numericValue)
                      // Use the converted value here
                  } else {
                      volume = 0.0
                      // Handle the case where the conversion fails
                  }
                  let byPoint = close - open
                  let byPercent = ((close - open) / open) * 100
                  let marketCap = close * volume
                  print("convertStock \(convertStock)")
                  if bleKeyFlag == .CREATE {
                      let stock = BleStock()
                      stock.mColorType = 1
                      stock.mStockCode = convertStock["ticker"] as? String ?? ""
                      stock.mSharePrice = close
                      stock.mNetChangePoint = byPoint
                      stock.mNetChangePercent = byPercent
                      stock.mMarketCapitalization = marketCap
                      _ = mBleConnector.sendObject(
                          bleKey,
                          bleKeyFlag,
                          stock
                      )
                  } else if bleKeyFlag == .DELETE {
                      let stocks : [BleStock] = BleCache.shared.getArray(.STOCK)
                      if let stockIndex = stocks.firstIndex(where: { $0.mStockCode == convertStock["ticker"] as? String }) {
                          if !stocks.isEmpty {
                              _ = mBleConnector.sendInt8(bleKey, bleKeyFlag, stocks[stockIndex].mId)
                          }
                      }
                  } else if bleKeyFlag == .UPDATE {
                      let stocks : [BleStock] = BleCache.shared.getArray(.STOCK)
                      if !stocks.isEmpty {
                         let stock = stocks[index ?? 0]
                              stock.mSharePrice = close
                              stock.mNetChangePoint = byPoint
                              stock.mNetChangePercent = byPercent
                              stock.mMarketCapitalization = marketCap
                          _ = mBleConnector.sendObject(bleKey, bleKeyFlag, stock)

                      }
                  } else if bleKeyFlag == .READ {
                      _ = mBleConnector.sendInt8(bleKey, bleKeyFlag, ID_ALL)
                  }
              }

              break
          case BleKey.SEDENTARINESS:
              //久坐提醒
              if bleKeyFlag ==  BleKeyFlag.UPDATE {
                  let mEnabled = args?["mEnabled"] as? Int ?? 0
                  let mRepeat = args?["mRepeat"] as? Int ?? 0
                  let mStartHour = args?["mStartHour"] as? Int ?? 0
                  let mStartMinute = args?["mStartMinute"] as? Int ?? 0
                  let mEndHour = args?["mEndHour"] as? Int ?? 0
                  let mEndMinute = args?["mEndMinute"] as? Int ?? 0
                  let mInterval = args?["mInterval"] as? Int ?? 0
                  let listRepeat = args?["listRepeat"] as? [String]
                  var bleRepeat: Int? = nil
                  if let listRepeat = listRepeat {
                      bleRepeat = 0
                      for item in listRepeat {
                          var itemRepeat: Int? = nil
                          switch item {
                          case "MONDAY":
                              itemRepeat = BleRepeat.MONDAY
                          case "TUESDAY":
                              itemRepeat = BleRepeat.TUESDAY
                          case "THURSDAY":
                              itemRepeat = BleRepeat.THURSDAY
                          case "FRIDAY":
                              itemRepeat = BleRepeat.FRIDAY
                          case "SATURDAY":
                              itemRepeat = BleRepeat.SATURDAY
                          case "SUNDAY":
                              itemRepeat = BleRepeat.SUNDAY
                          case "ONCE":
                              itemRepeat = BleRepeat.ONCE
                          case "WORKDAY":
                              itemRepeat = BleRepeat.WORKDAY
                          case "WEEKEND":
                              itemRepeat = BleRepeat.WEEKEND
                          case "EVERYDAY":
                              itemRepeat = BleRepeat.EVERYDAY
                          default:
                              break
                          }
                          if var bleRepeat = bleRepeat {
                              bleRepeat = bleRepeat
                          } else {
                              bleRepeat = itemRepeat
                          }

                      }
                  }
                  let bleSedentariness = BleSedentarinessSettings()
                  bleSedentariness.mEnabled = mEnabled
                  bleSedentariness.mRepeat = mRepeat // Monday ~ Saturday
                  bleSedentariness.mStartHour = mStartHour
                  bleSedentariness.mEndHour = mEndHour
                  bleSedentariness.mInterval = mInterval
                  _ = bleConnector.sendObject(bleKey,  BleKeyFlag.UPDATE, bleSedentariness)
              } else if bleKeyFlag ==  BleKeyFlag.READ {
                  //READ
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          case BleKey.NOTIFICATION_REMINDER:
              //消息提醒CALL
              let listApp = args?["listApp"] as? [[String: Any]]
              print("listApp \(String(describing: listApp))")
               if bleKeyFlag ==  BleKeyFlag.UPDATE {
                   let bleNotificationSettings = BleNotificationSettings()
                   print("listAPP \(String(describing: listApp))")
                   listApp?.forEach { app in
                       switch "\(app["app_name"] ?? "")" {
                       case "phone":
                           bleNotificationSettings.enable(BleNotificationSettings.MIRROR_PHONE)
                           bleNotificationSettings.enable(BleNotificationSettings.CALL)
                           break
                       case "Whatsapp":
                           bleNotificationSettings.enable(BleNotificationSettings.WHATS_APP)
                           break
                       case "SMS":
                           bleNotificationSettings.enable(BleNotificationSettings.SMS)
                           break
                       case "WeChat":
                           bleNotificationSettings.enable(BleNotificationSettings.WE_CHAT)
                           break
                       case "Facebook Messenger":
                           bleNotificationSettings.enable(BleNotificationSettings.FACEBOOK_MESSENGER)
                           break
                       case "Twitter":
                           bleNotificationSettings.enable(BleNotificationSettings.TWITTER)
                           break
                       case "Facebook":
                           bleNotificationSettings.enable(BleNotificationSettings.FACEBOOK_MESSENGER)
                           break
                       case "LINE":
                           bleNotificationSettings.enable(BleNotificationSettings.LINE)
                           break
                       case "Instagram":
                           bleNotificationSettings.enable(BleNotificationSettings.INSTAGRAM)
                           break
                       case "LinkedIn":
                           bleNotificationSettings.enable(BleNotificationSettings.LINKED_IN)
                           break
                       default:
                           print("Nothing")
                       }
                   }
                  print(bleNotificationSettings)
                  _ = bleConnector.sendObject(bleKey,  BleKeyFlag.UPDATE, bleNotificationSettings)
              }
          case BleKey.NO_DISTURB_RANGE:
              //设置勿扰
              if bleKeyFlag ==  BleKeyFlag.UPDATE {
                  let noDisturb = BleNoDisturbSettings()
                  noDisturb.mBleTimeRange1 = BleTimeRange(1, 2, 0, 18, 0)
                  _ = bleConnector.sendObject(bleKey, bleKeyFlag, noDisturb)
              } else {
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          case BleKey.NO_DISTURB_GLOBAL:
              // on
              let isDoNotDisturb = args?["isDoNotDistrub"] as? Bool
              _ = bleConnector.sendBool(bleKey, bleKeyFlag, isDoNotDisturb ?? false)
          case BleKey.WATCHFACE_ID:
              if bleKeyFlag == BleKeyFlag.READ {
                  //READ
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }else if  bleKeyFlag == BleKeyFlag.UPDATE{
                  let watchFaceId : Int32 = 111 //ID >= 100
                  _ = bleConnector.sendInt32(bleKey, bleKeyFlag, Int(watchFaceId))
              }
              break
          case BleKey.IBEACON_SET:
              if bleKeyFlag ==  BleKeyFlag.UPDATE{
                  _ = bleConnector.sendInt8(bleKey, bleKeyFlag, 1)
              }
              break
          case BleKey.WATCH_FACE_SWITCH:
              //设置默认表盘
              if bleKeyFlag ==  BleKeyFlag.UPDATE {
                  let value = 4 //watch face number
                  _ = BleConnector.shared.sendInt8(.WATCH_FACE_SWITCH,  BleKeyFlag.UPDATE, value)
              } else if bleKeyFlag == BleKeyFlag.READ {
                  //READ
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
              break
          case BleKey.GESTURE_WAKE:
              //抬手亮
              let mEnabled = args?["mEnabled"] as? Int
              let mStartHour = args?["mStartHour"] as? Int
              let mStartMinute = args?["mStartMinute"] as? Int
              let mEndHour = args?["mEndHour"] as? Int
              let mEndMinute = args?["mEndMinute"] as? Int
              if bleKeyFlag ==  BleKeyFlag.UPDATE {
                  _ = bleConnector.sendObject(bleKey, bleKeyFlag,
                      BleGestureWake(BleTimeRange(mEnabled!, mStartHour!, mStartMinute!, mEndHour!, mEndMinute!)))
              } else if bleKeyFlag == BleKeyFlag.READ {
                  //READ
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          case BleKey.VIBRATION:
              //震动设置
              let frequency = args?["frequency"] as? Int
              if bleKeyFlag ==  BleKeyFlag.UPDATE {
                  _ = bleConnector.sendInt8(bleKey, bleKeyFlag, frequency ?? 0) // 0~10, 0 is off
              } else if bleKeyFlag ==  BleKeyFlag.READ {
                  //READ
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          case BleKey.HR_ASSIST_SLEEP:
              // on 睡眠辅助设备
              _ = bleConnector.sendBool(bleKey, bleKeyFlag, true)
          case BleKey.HOUR_SYSTEM:
              // 0: 24-hourly; 1: 12-hourly 小时制
              _ = bleConnector.sendInt8(bleKey, bleKeyFlag, 1)
          case BleKey.LANGUAGE:
              //设备语言设置
              _ = bleConnector.sendInt8(bleKey, bleKeyFlag, Languages.languageToCode())
          case BleKey.ALARM:
              let index = args?["index"] as? Int ?? 0
              let mEnabled = args?["mEnabled"] as? Int ?? 0
              let mRepeat = args?["mRepeat"] as? String
              let mYear = args?["mYear"] as? Int ?? 0
              let mMonth = args?["mMonth"] as? Int ?? 0
              let mDay = args?["mDay"] as? Int ?? 0
              let mHour = args?["mHour"] as? Int ?? 0
              let mMinute = args?["mMinute"] as? Int ?? 0
              let mTag = args?["mTag"] as? String ?? ""
              let listRepeat = args?["listRepeat"] as? [String]
    //          var bleRepeat: Int? = nil
//              if let listRepeat = listRepeat {
//                  bleRepeat = 0
//                  for item in listRepeat {
//                      var itemRepeat: Int? = nil
//                      switch item {
//                      case "MONDAY":
//                          itemRepeat = BleRepeat.MONDAY
//                      case "TUESDAY":
//                          itemRepeat = BleRepeat.TUESDAY
//                      case "THURSDAY":
//                          itemRepeat = BleRepeat.THURSDAY
//                      case "FRIDAY":
//                          itemRepeat = BleRepeat.FRIDAY
//                      case "SATURDAY":
//                          itemRepeat = BleRepeat.SATURDAY
//                      case "SUNDAY":
//                          itemRepeat = BleRepeat.SUNDAY
//                      case "ONCE":
//                          itemRepeat = BleRepeat.ONCE
//                      case "WORKDAY":
//                          itemRepeat = BleRepeat.WORKDAY
//                      case "WEEKEND":
//                          itemRepeat = BleRepeat.WEEKEND
//                      case "EVERYDAY":
//                          itemRepeat = BleRepeat.EVERYDAY
//                      default:
//                          break
//                      }
//                      if var bleRepeat = bleRepeat {
//                          bleRepeat = bleRepeat
//                      } else {
//                          bleRepeat = itemRepeat
//                      }
//
//                  }
//
//              }
//
//              if(mRepeat != nil){
//                  switch mRepeat {
//                  case "MONDAY":
//                      bleRepeat = BleRepeat.MONDAY
//                  case "TUESDAY":
//                      bleRepeat = BleRepeat.TUESDAY
//                  case "THURSDAY":
//                      bleRepeat = BleRepeat.THURSDAY
//                  case "FRIDAY":
//                      bleRepeat = BleRepeat.FRIDAY
//                  case "SATURDAY":
//                      bleRepeat = BleRepeat.SATURDAY
//                  case "SUNDAY":
//                      bleRepeat = BleRepeat.SUNDAY
//                  case "ONCE":
//                      bleRepeat = BleRepeat.ONCE
//                  case "WORKDAY":
//                      bleRepeat = BleRepeat.WORKDAY
//                  case "WEEKEND":
//                      bleRepeat = BleRepeat.WEEKEND
//                  case "EVERYDAY":
//                      bleRepeat = BleRepeat.EVERYDAY
//                  default:
//                      break
//                  }
//              }
              if bleKeyFlag ==  BleKeyFlag.CREATE {
                  // 创建一个一分钟后的闹钟

                  _ = bleConnector.sendObject(bleKey, bleKeyFlag, BleAlarm(
                      mEnabled, // mEnabled
                      (mRepeat! as NSString).integerValue, // mRepeat
                      mYear, // mYear
                      mMonth, // mMonth
                      mDay, // mDay
                      mHour, // mHour
                      mMinute, // mMinute
                      mTag // mTag
                  ))
              } else if bleKeyFlag ==  BleKeyFlag.DELETE {
                  // 如果缓存中有闹钟的话，删除第一个
                  let alarms: [BleAlarm] = BleCache.shared.getArray(.ALARM)
                  if !alarms.isEmpty {
                      _ = bleConnector.sendInt8(bleKey, bleKeyFlag, alarms[index].mId)
                  }
              } else if bleKeyFlag ==  BleKeyFlag.UPDATE {
                  // 如果缓存中有闹钟的话，切换第一个闹钟的开启状态
                  let alarms: [BleAlarm] = BleCache.shared.getArray(.ALARM)
                  if !alarms.isEmpty {
                      let alarm = alarms[index]
                      alarm.mEnabled = mEnabled
                      if mRepeat != nil {
                          alarm.mRepeat =  (mRepeat! as NSString).integerValue
                      }
                      alarm.mYear = mYear
                      alarm.mMonth = mMonth
                      alarm.mDay = mDay
                      alarm.mHour = mHour
                      alarm.mMinute = mMinute
                      alarm.mTag = mTag
                      _ = bleConnector.sendObject(bleKey, bleKeyFlag, alarm)
                  }
              } else if bleKeyFlag ==  BleKeyFlag.READ {
                  // 读取设备上所有的闹钟
                  _ = bleConnector.sendInt8(bleKey, bleKeyFlag, ID_ALL)
              } else if bleKeyFlag ==  BleKeyFlag.RESET {
                  // 重置设备上的闹钟
                  let calendar = Calendar.current
                  let date = Date()
                  var alarms = [BleAlarm]()
                  for i in 0..<8 {
                      alarms.append(BleAlarm(
                          i % 2, // mEnabled
                          i, // mRepeat
                          calendar.component(.year, from: date), // mYear
                          calendar.component(.month, from: date), // mMonth
                          calendar.component(.day, from: date), // mDay
                          calendar.component(.hour, from: date), // mHour
                          i, // mMinute
                          "\(i)" // mTag
                      ))
                  }
                  _ = bleConnector.sendArray(bleKey, bleKeyFlag, alarms)
              }
          case BleKey.COACHING:
              //锻炼模式设置
              if bleKeyFlag ==  BleKeyFlag.CREATE {
                  _ = bleConnector.sendObject(bleKey, bleKeyFlag, BleCoaching(
                      "My title", // title
                      "My description", // description
                      3, // repeat
                      [BleCoachingSegment(
                          CompletionCondition.DURATION.rawValue, // completion condition
                          "My name", // name
                          0, // activity
                          Stage.WARM_UP.rawValue, // stage
                          10, // completion value
                          0 // hr zone
                      )]
                  ))
              } else if bleKeyFlag ==  BleKeyFlag.UPDATE {
                  // 如果缓存中有Coaching的话，修改第一个Coaching的标题
                  let coachings: [BleCoaching] = BleCache.shared.getArray(.COACHING)
                  if !coachings.isEmpty {
                      let coaching = coachings[0]
                      coaching.mTitle += " nice"
                      _ = bleConnector.sendObject(bleKey, bleKeyFlag, coaching)
                  }
              } else if bleKeyFlag ==  BleKeyFlag.READ {
                  // 读取所有Coaching
                  _ = bleConnector.sendInt8(bleKey, bleKeyFlag, ID_ALL)
              }
          case BleKey.ANTI_LOST:
              // on 防丢提醒设备
              let isAntiLost = args?["isAntiLost"] as? Bool
              _ = bleConnector.sendBool(bleKey, bleKeyFlag, isAntiLost ?? false)
          case BleKey.HR_MONITORING:
              //定时心率检查设置
              let mEnabled = args?["mEnabled"] as? Int
              let mStartHour = args?["mStartHour"] as? Int
              let mStartMinute = args?["mStartMinute"] as? Int
              let mEndHour = args?["mEndHour"] as? Int
              let mEndMinute = args?["mEndMinute"] as? Int
              let mInterval = args?["mInterval"] as? Int

              if bleKeyFlag ==  BleKeyFlag.UPDATE {
                  let hrMonitoring = BleHrMonitoringSettings()
                  hrMonitoring.mBleTimeRange = BleTimeRange(mEnabled!, mStartHour!, mStartMinute!, mEndHour!, mEndMinute!)
                  hrMonitoring.mInterval = mInterval! // an hour
                  _ = bleConnector.sendObject(bleKey, bleKeyFlag, hrMonitoring)
              } else if bleKeyFlag ==  BleKeyFlag.READ {
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          case BleKey.DRINKWATER:
              if bleKeyFlag ==  BleKeyFlag.UPDATE {
                  let drinkWater = BleDrinkWaterSettings()
                  drinkWater.mEnabled = 1
                  drinkWater.mInterval = 1
                  drinkWater.mRepeat = 63 // Monday ~ Saturday
                  drinkWater.mStartHour = 7
                  drinkWater.mEndHour = 22
                  _ = bleConnector.sendObject(.DRINKWATER,  BleKeyFlag.UPDATE, drinkWater)
              }
              break
          case BleKey.UI_PACK_VERSION:
              //Realtek UI包 版本
              _ = bleConnector.sendData(bleKey, bleKeyFlag)
          case BleKey.LANGUAGE_PACK_VERSION:
              //Realtek 语言包 版本
              _ = bleConnector.sendData(bleKey, bleKeyFlag)
          case BleKey.SLEEP_QUALITY:
              //睡眠总结设置
              _ = bleConnector.sendObject(bleKey, bleKeyFlag,
                  BleSleepQuality(202, 201, 481))
          case BleKey.HEALTH_CARE:
              //生理期设置
              _ = bleConnector.sendObject(bleKey, bleKeyFlag, BleHealthCare(
                  9, 0, // 提醒时间
                  2, // 生理期提醒提前天数
                  2, // 排卵期提醒提前天数
                  2020, // 上次生理期日期
                  1,
                  1,
                  30, // 生理期周期，天
                  1,
                  7 // 生理期持续时间，天
              ))
          case BleKey.TEMPERATURE_DETECTING:
              //定时体温监测
              let detecting = BleTemperatureDetecting()
              detecting.mBleTimeRange = BleTimeRange(1, 8, 0, 22, 0)
              detecting.mInterval = 60 // an hour
              _ = bleConnector.sendObject(bleKey, bleKeyFlag, detecting)

              // BleCommand.CONNECT
          case BleKey.IDENTITY:
              //绑定设备
              if bleKeyFlag ==  BleKeyFlag.CREATE {
                  _ = bleConnector.sendInt32(bleKey, bleKeyFlag, Int.random(in: 1..<0xffffffff))
              } else if bleKeyFlag ==  BleKeyFlag.READ {
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
                  onReadDeviceInfo()
              }
          case BleKey.PAIR:
              //蓝牙配对
              _ = bleConnector.sendData(bleKey, bleKeyFlag)

              // BleCommand.PUSH
          case BleKey.SCHEDULE:
              if bleKeyFlag ==  BleKeyFlag.CREATE {
                  // 创建一个1分钟后的日程
                  let calendar = Calendar.current
                  var date = Date()
                  date.addTimeInterval(60.0)
                  _ = bleConnector.sendObject(bleKey, bleKeyFlag, BleSchedule(
                      calendar.component(.year, from: date), // mYear
                      calendar.component(.month, from: date), // mMonth
                      calendar.component(.day, from: date), // mDay
                      calendar.component(.hour, from: date), // mHour
                      calendar.component(.minute, from: date), // mMinute
                      0, // mAdvance
                      "Title8", // mTitle
                      "Content9" // mContent
                  ))
              } else if bleKeyFlag ==  BleKeyFlag.DELETE {
                  // 如果缓存中有日程的话，删除第一个
                  let schedules: [BleSchedule] = BleCache.shared.getArray(.SCHEDULE)
                  if !schedules.isEmpty {
                      _ = bleConnector.sendInt8(bleKey, bleKeyFlag, schedules[0].mId)
                  }
              } else if bleKeyFlag ==  BleKeyFlag.UPDATE {
                  // 如果缓存中有日程的话，修改第一个日程的时间
                  //mContent -> count<50
                  let schedules: [BleSchedule] = BleCache.shared.getArray(.SCHEDULE)
                  if !schedules.isEmpty {
                      let schedule = schedules[0]
                      schedule.mHour = Int.random(in: 1..<24)
                      _ = bleConnector.sendObject(bleKey, bleKeyFlag, schedule)
                  }
              }
          case BleKey.APP_SPORT_DATA:
              bleLog("-- PHONEWORKOUT --")
              break
          case BleKey.REAL_TIME_HEART_RATE:
              bleLog("-- REALTIMEHR --")
              break
              // BleCommand.DATA
          case BleKey.DATA_ALL, BleKey.ACTIVITY, BleKey.HEART_RATE, BleKey.BLOOD_PRESSURE, BleKey.SLEEP, BleKey.WORKOUT, BleKey.LOCATION, BleKey.TEMPERATURE,
                  BleKey.BLOODOXYGEN, BleKey.HRV, BleKey.WORKOUT2, BleKey.MATCH_RECORD:
              //Exercise data
              _ = bleConnector.sendData(bleKey, bleKeyFlag)

              // BleCommand.CONTROL
          case BleKey.CAMERA:
              //camera 相机拍照、或者退出拍照
              let mCameraEntered = args?["mCameraEntered"] as? Bool
              if mCameraEntered==true {
                  _ = bleConnector.sendInt8(bleKey, bleKeyFlag, CameraState.ENTER)
              } else {
                  _ = bleConnector.sendInt8(bleKey, bleKeyFlag, CameraState.EXIT)
              }
          case BleKey.APP_SPORT_STATE:
              bleLog("PHONE_WORKOUT_SWITCH")
              let mode = BlePhoneWorkOutStatus()
              mode.mMode = PhoneWorkOutStatus.Treadmill
              mode.mStatus = PhoneWorkOutStatus.modeEnd
              let sportStateInt = args?["sportState"] as? Int
              let sportModeInt = args?["sportMode"] as? Int
                  switch sportStateInt {
                  case 1:
                      mode.mStatus = PhoneWorkOutStatus.modeStart
                  case 2:
                      mode.mStatus = PhoneWorkOutStatus.modeContinues
                  case 3:
                      mode.mStatus = PhoneWorkOutStatus.modePause
                  case 4:
                      mode.mStatus = PhoneWorkOutStatus.modeEnd
                  default:
                      mode.mStatus = PhoneWorkOutStatus.modeEnd
                  }

                  switch sportModeInt {
                  case 1:
                      mode.mStatus = PhoneWorkOutStatus.Treadmill
                  case 2:
                      mode.mStatus = PhoneWorkOutStatus.OutdoorRun
                  case 3:
                      mode.mStatus = PhoneWorkOutStatus.Cycling
                  case 4:
                      mode.mStatus = PhoneWorkOutStatus.Climbing
                  default:
                      mode.mStatus = PhoneWorkOutStatus.Treadmill
                  }

              _ = bleConnector.sendObject(bleKey, bleKeyFlag, mode)
              break
          case BleKey.PHONE_GPSSPORT:
              bleLog("PHONE_GPSSPORT")
              let speed = args?["mSpeed"] as? NSString
              let totalDistance = args?["mTotalDistance"] as? NSString
              let altitude = args?["mAltitude"] as? Int

              let mode = BlePhoneGPSSport()
              mode.locationHeight = altitude!
              mode.locationSpeed = speed!.floatValue
              mode.locationDistance = totalDistance!.floatValue

              _ = bleConnector.sendObject(bleKey, bleKeyFlag, mode)
              break
          case BleKey.IBEACON_CONTROL:
              if bleKeyFlag ==  BleKeyFlag.UPDATE {
                  _ = BleConnector.shared.sendInt8(bleKey, bleKeyFlag, 0)
              }
              break
              // BleCommand.IO
          case BleKey.WATCH_FACE:
              if bleKeyFlag ==  BleKeyFlag.DELETE {
                  _ = BleConnector.shared.sendData(bleKey, bleKeyFlag)
                  return
              }
              let fileURL = args?["url"] as! String

              if let url = URL(string: fileURL) {
                print("Valid URL: \(url)")

                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                  if let error = error {
                    print("Error: \(error)")
                  } else if let data = data {
                    print("Received data: \(data)")
                    _ = bleConnector.sendStream(self.bleKey, data)
                  }
                }
                task.resume()
              } else {
                print("Invalid URL: \(String(describing: fileURL))")
              }
 //              _ = bleConnector.sendStream(bleKey, URL.init(fileURLWithPath: fileURL))
//
              break
//          case BleKey.AGPS_FILE, BleKey.FONT_FILE, BleKey.UI_FILE, BleKey.LANGUAGE_FILE:
//              if bleKeyFlag ==  BleKeyFlag.DELETE {
//                  _ = BleConnector.shared.sendData(bleKey, bleKeyFlag)
//                  return
//              }
//              let selectVC = selectOTAFileController()
//              selectVC.reloadBlock = { (fileURL) in
//                  bleLog("\(bleKey) - \(String(describing: fileURL))")
//                  _ = bleConnector.sendStream(bleKey, URL.init(fileURLWithPath: fileURL))
//                  self.proDuration = Int(Date().timeIntervalSince1970)
//                  DispatchQueue.main.asyncAfter(deadline: BleKey.now() + 0.1) { [self] in
//                      progressLab.frame = CGRect(x: 50, y: 60, width: 230, height: 100)
//                      progressLab.numberOfLines = 0
//                      progressLab.backgroundColor = BleKey.black
//                      progressLab.textColor = BleKey.white
//                      progressLab.textAlignment = BleKey.center
//                      self.tableView.addSubview(progressLab)
//                      UIApplication.shared.isIdleTimerDisabled = true
//                  }
//              }
//              self.navigationController?.pushViewController(selectVC, animated: true)
          case BleKey.CONTACT:
              bleLog("Address Book")

              let listContact = args?["listContact"] as? [[String: Any]]

              var sendArray: [BleContactPerson] = []

              do {
                  listContact?.forEach { contact in
                      var userName = contact["displayName"] as! String

                      let phoneString = contact["phone"] as! String

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
          case BleKey.AEROBIC_EXERCISE:
              if bleKeyFlag ==  BleKeyFlag.UPDATE {
                  let aerobic = BleAerobicSettings()
                  aerobic.mHour = 1
                  aerobic.mMin = 30
                  aerobic.mHRMin = 80
                  aerobic.mHRMax = 110
                  aerobic.mHRMinTime = 30
                  aerobic.mHRMinVibration = 4
                  aerobic.mHRMaxTime = 20
                  aerobic.mHRMaxVibration = 4
                  aerobic.mHRIntermediate = 30
                  _ = bleConnector.sendObject(bleKey, bleKeyFlag, aerobic)
              } else if bleKeyFlag ==  BleKeyFlag.READ {
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          case BleKey.TEMPERATURE_UNIT:
              if bleKeyFlag ==  BleKeyFlag.UPDATE {
                  //0 - Celsius ℃ 1 - Fahrenheit ℉
                  _ = bleConnector.sendInt8(bleKey, bleKeyFlag, 1)
              } else if bleKeyFlag ==  BleKeyFlag.READ {
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          case BleKey.DATE_FORMAT:
              let format = args?["format"] as? Int
              if bleKeyFlag ==  BleKeyFlag.UPDATE {
                  /**1
                    0 ->YYYY/MM/dd
                    1 ->dd/MM/YYYY
                    2 ->MM/dd/YYYY
                    */
                  _ = bleConnector.sendInt8(bleKey, bleKeyFlag, format ?? 0)
              } else if bleKeyFlag ==  BleKeyFlag.READ {
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          default:
              print("NO CASE -\(bleKey.mDisplayName)")
          }
      }
      }



    func onBluetoothDisabled() {
        //btnScan.setTitle("Please enable the Bluetooth", for: BleKey.normal)
    }

    func onBluetoothEnabled() {
       // btnScan.setTitle("Scan", for: BleKey.normal)
    }

    func onScan(_ scan: Bool) {
        print("onScan")
        if scan {
           // btnScan.setTitle("Scanning", for: BleKey.normal)
            mDevices.removeAll()
           // tableView.reloadData()
        } else {
           // btnScan.setTitle("Scan", for: BleKey.normal)
        }
    }

    func onDeviceFound(_ device: BleDevice) {
        var item = [String : String]();
        item["deviceName"] = device.name
        item["deviceMacAddress"] = device.address
        item["deviceIdentifier"] = device.identifier
        if !mDevices.contains(item) {
            mDevices.append(item)
//            let newIndexPath = IndexPath(row: mDevices.count - 1, section: 0)
//            tableView.insertRows(at: [newIndexPath], with: BleKey.automatic)
        }
        if let scanSink = scanSink {
            // Use the unwrapped value of `sink` here
            scanSink(mDevices)
        }


    }


    func match(_ device: BleDevice) -> Bool {
        device.mRssi > -82
    }

    func onDeviceConnected(_ peripheral: CBPeripheral) {
        print("onDeviceConnected - \(peripheral)")
        var item = [String: Any]()
//        item["deviceName"] = peripheral.name
//        item["deviceMacAddress"] = peripheral.

        if let onDeviceConnectedSink = onDeviceConnectedSink {
            onDeviceConnectedSink(item)
        }
    }

    func onDeviceConnecting(_ status: Bool) {
        print("onDeviceConnecting - \(status)")
    }

    func onIdentityCreate(_ status: Bool) {
//        if status {
//            _ = mBleConnector.sendData(.PAIR,  BleKeyFlag.UPDATE)
////            dismiss(animated: true)
////            present(storyboard!.instantiateViewController(withIdentifier: "nav"), animated: true)
//        }
        var item = [String: Any]()
        item["status"] = status
        item["deviceInfo"] =    toJSON(mBleCache.mDeviceInfo)

        if let onIdentityCreateSink = onIdentityCreateSink {
            onIdentityCreateSink(item)
        }
    }

    func onReadDeviceInfo() {
        var item = [String: Any]()
        item["deviceInfo"] =   toJSON(mBleCache.mDeviceInfo)

        if let onReadDeviceInfoSink = onReadDeviceInfoSink {
            onReadDeviceInfoSink(item)
        }
    }


    func onOTA(_ status: Bool) {
        print("onOTA \(status)")
    }

    func onReadPower(_ power: Int) {
        print("onReadPower \(power)")
        var item = [String: Any]()
        item["power"] = power

        if let onReadPowerSink = onReadPowerSink {
            onReadPowerSink(item)
        }

    }

    func onReadFirmwareVersion(_ version: String) {
        print("onReadFirmwareVersion \(version)")
        var item = [String: Any]()
        item["version"] = version

        if let onReadFirmwareVersionSink = onReadFirmwareVersionSink {
            onReadFirmwareVersionSink(item)
        }

    }

    func onReadBleAddress(_ address: String) {
        print("onReadBleAddress \(address)")
        var item = [String: Any]()
        item["address"] = address

        if let onReadBleAddressSink = onReadBleAddressSink {
            onReadBleAddressSink(item)
        }

    }

    func onReadSedentariness(_ sedentarinessSettings: BleSedentarinessSettings) {
        print("onReadSedentariness \(sedentarinessSettings)")
        var item = [String: Any]()

        item["sedentarinessSettings"] =   toJSON(sedentarinessSettings)

        if let onReadSedentarinessSink = onReadSedentarinessSink {
            onReadSedentarinessSink(item)
        }
    }

    func onReadNoDisturb(_ noDisturbSettings: BleNoDisturbSettings) {
        print("onReadNoDisturb \(noDisturbSettings)")
        var item = [String: Any]()
        item["noDisturbSettings"] =   toJSON(noDisturbSettings)

        if let onReadNoDisturbSink = onReadNoDisturbSink {
            onReadNoDisturbSink(item)
        }
    }

    func onReadAlarm(_ alarms: Array<BleAlarm>) {
        print("onReadAlarm \(alarms)")
        var item = [String: Any]()
        let i = alarms.map { data -> [String: Any] in
            return data.toDictionary()
        }
        item["alarms"] =   i

        if let onReadAlarmSink = onReadAlarmSink {
            onReadAlarmSink(item)
        }

    }

    func onIdentityDelete(_ status: Bool) {
        print("onIdentityDelete \(status)")
//        if status {
//            unbindCompleted()
//        }
    }

    func onSyncData(_ syncState: Int, _ bleKey: Int) {
        print("onSyncData \(syncState) \(bleKey)")
    }

    func onReadActivity(_ activities: [BleActivity]) {
        print("onReadActivity \(activities)")
        var item = [String: Any]()

        let i = activities.map { data -> [String: Any] in
            return data.toDictionary()
        }

        item["activities"] = i

        if let onReadActivitySink = onReadActivitySink {
            onReadActivitySink(item)
        }
    }

    func onReadHeartRate(_ heartRates: [BleHeartRate]) {
        print("onReadHeartRate \(heartRates)")
        var item = [String: Any]()
        let i = heartRates.map { data -> [String: Any] in
            return data.toDictionary()
        }
        item["heartRates"] =  i

        if let onReadHeartRateSink = onReadHeartRateSink {
            onReadHeartRateSink(item)
        }
    }

    func onReadBloodPressure(_ bloodPressures: [BleBloodPressure]) {
        print("onReadBloodPressure \(bloodPressures)")
        var item = [String: Any]()

        let i = bloodPressures.map { data -> [String: Any] in
            return data.toDictionary()
        }

        item["bloodPressures"] =   i

        if let onReadBloodPressureSink = onReadBloodPressureSink {
            onReadBloodPressureSink(item)
        }

    }

    func onReadSleep(_ sleeps: [BleSleep]) {
//        if BleCache.shared.mSleepAlgorithmType == 1 {
//            for item in sleeps {
//                if item.mMode == 4 {
//                    let time = item.mSoft << 8 + item.mStrong
//                    print("sleep time total length - \(time)min")
//                } else if item.mMode == 5 {
//                    let time = item.mSoft << 8 + item.mStrong
//                    print("deep sleep time length - \(time)min")
//                } else if item.mMode == 6 {
//                    let time = item.mSoft << 8 + item.mStrong
//                    print("light sleep time length - \(time)min")
//                } else if item.mMode == 7 {
//                    let time = item.mSoft << 8 + item.mStrong
//                    print("awake time length - \(time)min")
//                }
//            }
//        } else {
//            print("onReadSleep \(sleeps)")
//        }
        var item = [String: Any]()

        let i = sleeps.map { data -> [String: Any] in
            return data.toDictionary()
        }

        item["sleeps"] =   i

        if let onReadSleepSink = onReadSleepSink {
            onReadSleepSink(item)
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
        var item = [String: Any]()

        let i = locations.map { data -> [String: Any] in
            return data.toDictionary()
        }

        item["locations"] =  i

        if let onReadLocationSink = onReadLocationSink {
            onReadLocationSink(item)
        }

    }

    func onReadTemperature(_ temperatures: [BleTemperature]) {
        print("onReadTemperature \(temperatures)")
        var item = [String: Any]()

        let i = temperatures.map { data -> [String: Any] in
            return data.toDictionary()
        }

        item["temperatures"] =  i

        if let onReadTemperatureSink = onReadTemperatureSink {
            onReadTemperatureSink(item)
        }
    }

    func onCameraStateChange(_ cameraState: Int) {
        print("onCameraStateChange \(CameraState.getState(cameraState))")
//        if cameraState == CameraState.ENTER {
//            mCameraEntered = true
//        } else if cameraState == CameraState.EXIT {
//            mCameraEntered = false
//        }
        var item = [String: Any]()
        item["cameraState"] = cameraState
        item["cameraStateName"] = CameraState.getState(cameraState)
        if let onCameraStateChangeSink = onCameraStateChangeSink {
            onCameraStateChangeSink(item)
        }
    }

    func onCameraResponse(_ status: Bool, _ cameraState: Int) {
        print("onCameraResponse \(status) \(CameraState.getState(cameraState))")
//        if status {
//            if cameraState == CameraState.ENTER {
//                mCameraEntered = true
//            } else if cameraState == CameraState.EXIT {
//                mCameraEntered = false
//            }
//        }
        var item = [String: Any]()
        item["status"] = status
        item["cameraState"] = cameraState
        item["cameraStateName"] = CameraState.getState(cameraState)

        if let onCameraResponseSink = onCameraResponseSink {
            onCameraResponseSink(item)
        }
    }

    func onStreamProgress(_ status: Bool, _ errorCode: Int, _ total: Int, _ completed: Int) {

//        let progressValue = CGFloat(completed) / CGFloat(total)
//        var mSpeed :Double = 0.0
//        let nowTime = Int(Date().timeIntervalSince1970)
//        let sTime = nowTime-proDuration
//        if errorCode == 0 && total == completed {
//            mSpeed = Double(total/1024)/Double(sTime)
//            progressLab.text = "speed:\(String.init(format: "%.3f",mSpeed)) kb/s \n time:"+String.init(format: "%02d:%02d:%02d", sTime/3600,(sTime%3600)/60,sTime%60)+" MTU:\(BleConnector.shared.mBaseBleMessenger.mPacketSize)"
////            self.navigationController?.popToRootViewController(animated: true)
//        }else{
//
//            if completed>0{
//                mSpeed = Double(completed/1024)/Double(sTime)
//            }
//            progressLab.text = "progress:\(String(format: "%.f", progressValue * 100.0))% - \(String.init(format: "%.3f",mSpeed)) kb/s"+"\n"+String.init(format: "%02d:%02d:%02d", sTime/3600,(sTime%3600)/60,sTime%60)
//        }

//        print("onStreamProgress \(status) \(errorCode) \(total) \(completed) - \(String.init(format: "%.3f",mSpeed))")
        var item = [String: Any]()

        item["status"] = status
        item["errorCode"] = errorCode
        item["total"] = total
        item["completed"] = completed

        if let onStreamProgressSink = onStreamProgressSink {
            onStreamProgressSink(item)
        }

    }

    func onReadAerobicSettings(_ AerobicSettings: BleAerobicSettings) {
        print("onReadAerobicSettings - \(AerobicSettings)")
    }

    func onReadTemperatureUnitSettings(_ state: Int) {
        print("onReadTemperatureUnitSettings - \(state)")
        var item = [String: Any]()

        item["value"] = state
        if let onReadTemperatureUnitSink = onReadTemperatureUnitSink {
            onReadTemperatureUnitSink(item)
        }
    }

    func onReadDateFormatSettings(_ status: Int) {
        print("onReadDateFormatSettings - \(status)")

        var item = [String: Any]()

        item["value"] = status
        if let onReadDateFormatSink = onReadDateFormatSink {
            onReadDateFormatSink(item)
        }
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
        //bleWatchFaceID = watchFaceId
    }

    func onWatchFaceIdUpdate(_ status: Bool) {
       // senderBinFile()
    }
        func onSessionStateChange(_ status: Bool) {
            print("onSessionStateChange \(status)")
            if status {
                _ = BleConnector.shared.sendObject(BleKey.TIME_ZONE, BleKeyFlag.UPDATE, BleTimeZone())
                _ = BleConnector.shared.sendObject(BleKey.TIME, BleKeyFlag.UPDATE, BleTime.local())
//                _ = BleConnector.shared.sendData(BleKey.POWER, BleKeyFlag.READ)
//                _ = BleConnector.shared.sendData(BleKey.FIRMWARE_VERSION, BleKeyFlag.READ)
            }
            var item = [String: Any]()

            item["status"] = status
            if let onSessionStateChangeSink = onSessionStateChangeSink {
                onSessionStateChangeSink(item)
            }
        }

        func onNoDisturbUpdate(_ noDisturbSettings: BleNoDisturbSettings) {
            print("onNoDisturbUpdate \(noDisturbSettings)")
            var item = [String: Any]()

            item["noDisturbSettings"] = toJSON(noDisturbSettings)
            if let onNoDisturbUpdateSink = onNoDisturbUpdateSink {
                onNoDisturbUpdateSink(item)
            }
        }

        func onAlarmUpdate(_ alarm: BleAlarm) {
            print("onAlarmUpdate \(alarm)")
            var item = [String: Any]()

            item["alarm"] =  toJSON(alarm)

            if let onAlarmUpdateSink = onAlarmUpdateSink {
                onAlarmUpdateSink(item)
            }
        }

        func onAlarmDelete(_ id: Int) {
            print("onAlarmDelete \(id)")
        }

        func onAlarmAdd(_ alarm: BleAlarm) {
            print("onAlarmAdd \(alarm)")
            var item = [String: Any]()

            item["alarm"] =   toJSON(alarm)

            if let onAlarmAddSink = onAlarmAddSink {
                onAlarmAddSink(item)
            }
        }

        func onFindPhone(_ start: Bool) {
            print("onFindPhone \(start ? "started" : "stopped")")
            var item = [String: Any]()

            item["start"] =  start

            if let onFindPhoneSink = onFindPhoneSink {
                onFindPhoneSink(item)
            }
        }

        func onPhoneGPSSport(_ workoutState: Int) {
            print("onPhoneGPSSport \(WorkoutState.getState(workoutState))")
            var item = [String: Any]()

            item["workoutState"] =  workoutState

            if let onRequestLocationSink = onRequestLocationSink {
                onRequestLocationSink(item)
            }
        }

        func onDeviceRequestAGpsFile(_ url: String) {
            print("onDeviceRequestAGpsFile \(url)")
            // 以下是示例代码，sdk中的文件会过期，只是用于演示
            if BleCache.shared.mAGpsType == 1 {
                _ = BleConnector.shared.sendStream(.AGPS_FILE, forResource: "type1_epo_gr_3_1", ofType: "dat")
            } else if BleCache.shared.mAGpsType == 2 {
                _ = BleConnector.shared.sendStream(.AGPS_FILE, forResource: "type2_current_1d", ofType: "alp")
            } else if BleCache.shared.mAGpsType == 6 {
                _ = BleConnector.shared.sendStream(.AGPS_FILE, forResource: "type6_ble_epo_offline", ofType: "bin")
            }
            // 实际工程要从url下载aGps文件，然后发送该aGps文件
            // let path = download(url)
            // _ = BleConnector.shared.sendStream(.AGPS_FILE, path)
        }



    func onIdentityDeleteByDevice(_ status: Bool) {

    }

    func onCommandReply(_ bleKey: Int, _ keyFlag: Int, _ status: Bool) {

    }

    func onReadMtkOtaMeta() {

    }

    func onXModem(_ status: UInt8) {

    }

    func onReadCoachingIds(_ coachingIds: BleCoachingIds) {

    }

    func onReadUiPackVersion(_ version: String) {

    }

    func onReadLanguagePackVersion(_ version: BleLanguagePackVersion) {

    }

    func onReadWorkOut(_ WorkOut: [BleWorkOut]) {
        print("onReadWorkOut \(WorkOut)")
        var item = [String: Any]()

        let i = WorkOut.map { data -> [String: Any] in
            return ["mStart":data.startTime,
                    "mEnd":data.endTime,
                    "mDuration":data.mDuration,
                    "mAltitude":data.mAltitude,
                    "mAirPressure":data.mAirPressure,
                    "mSpm":data.mSmp,
                    "mMode":data.mModeSport,
                    "mStep":data.mStep,
                    "mDistance":data.mDistance,
                    "mCalorie":data.mCalories,
                    "mSpeed":data.mSpeed,
                    "mPace":data.mPace,
                    "mAvgBpm":data.mAvgBpm,
                    "mMaxBpm":data.mMaxBpm]
        }

        item["workouts"] =  i

        if let onReadWorkoutSink = onReadWorkoutSink {
            onReadWorkoutSink(item)
        }
    }

    func onReadWorkOut2(_ WorkOut: [BleWorkOut2]) {
        print("onReadWorkOut2 \(WorkOut)")
        var item = [String: Any]()

        let i = WorkOut.map { data -> [String: Any] in
            return ["mStart":data.startTime,
                    "mEnd":data.endTime,
                    "mDuration":data.mDuration,
                    "mAltitude":data.mAltitude,
                    "mAirPressure":data.mAirPressure,
                    "mSmp":data.mSmp,
                    "mMode":data.mModeSport,
                    "mStep":data.mStep,
                    "mDistance":data.mDistance,
                    "mCalories":data.mCalories,
                    "mSpeed":data.mSpeed,
                    "mPace":data.mPace,
                    "mAvgBpm":data.mAvgBpm,
                    "mMaxBpm":data.mMaxBpm,
                    "mMinBpm":data.mMinBpm,
                    "mUndefined":data.mUndefined,
                    "mMaxSpm":data.mMaxSpm,
                    "mMinSpm":data.mMinSpm,
                    "mMaxPace":data.mMaxPace,
                    "mMinPace":data.mMinPace]
        }

        item["workouts"] =  i

        if let onReadWorkout2Sink = onReadWorkout2Sink {
            onReadWorkout2Sink(item)
        }
    }

    func onReadMatchRecord(_ matchRecord: [BleMatchRecord]) {
        print("onReadMatchRecord \(matchRecord)")
//        var item = [String: Any]()
//
//        let i = matchRecord.map { data -> [String: Any] in
//            return data.toDictionary()
//        }
//
//        item["matchRecord"] =  i
//
//        if let oonReadMatchRecordSink = onReadMatchRecordSink {
//            oonReadMatchRecordSink(item)
//        }
    }

    func onReadBloodOxygen(_ BloodOxygen: [BleBloodOxygen]) {
        print("onReadBloodOxygen \(BloodOxygen)")
        var item = [String: Any]()

        let i = BloodOxygen.map { data -> [String: Any] in
            //return data.toDictionary()
            return ["mTime":data.mTime,
                    "mValue":data.mBloodOxygenValue]
        }

        item["bloodOxygen"] =  i

        if let onReadBloodOxygenSink = onReadBloodOxygenSink {
            onReadBloodOxygenSink(item)
        }
    }

    func onReadHeartRateVariability(_ HeartRateVariability: [BleHeartRateVariability]) {
        print("onReadHeartRateVariability \(HeartRateVariability)")
//        var item = [String: Any]()
//
//        let i = HeartRateVariability.map { data -> [String: Any] in
//            return data.toDictionary()
//        }
//
//        item["hrv"] =  i
//
//        if let onReadHRVSink = onReadHRVSink {
//            onReadHRVSink(item)
//        }
    }

    func onReadPressures(_ pressures: [BlePressure]) {
        print("onReadPressures \(pressures)")
        var item = [String: Any]()

        let i = pressures.map { data -> [String: Any] in
            //return data.toDictionary()
            return ["mTime":data.mTime,
                    "mValue":data.mPressure]
        }

        item["pressures"] =  i

        if let onReadPressureSink = onReadPressureSink {
            onReadPressureSink(item)
        }
    }

    func onReadMediaFile(_ media: BleFileTransmission) {

    }

    func onFollowSystemLanguage(_ systemLanguage: Bool) {

    }

    func onReadWeatherRealtime(_ update: Bool) {

    }

    func onReadDataLog(_ logs: [BleLogText]) {

    }

    func onRequestAgpsPrerequisite() {

    }

    func onReadDrinkWaterSettings(_ drinkWater: BleDrinkWaterSettings) {

    }

    func onReadBloodOxyGenSettings(_ bloodOxyGenSet: BleBloodOxyGenSettings) {

    }

    func onReadWashSettings(_ washSet: BleWashSettings) {

    }

    func onUpdateRealTimeHR(_ itemHR: ABHRealTimeHR) {

    }

    func onUpdateRealTimeTemperature(_ temperature: BleTemperature) {

    }

    func onUpdateRealTimeBloodPressure(_ bloodPressures: BleBloodPressure) {

    }

    func onUpdatePhoneWorkOutStatus(_ status: BlePhoneWorkOutStatus) {

    }

    func onVibrationUpdate(_ value: Int) {

    }

    func onReadiBeaconStatus(_ value: Int) {

    }

    func onCommandSendTimeout(_ bleKey: Int, _ bleKeyFlag: Int) {

    }

    func onReadWorldClock(_ worldClocks: [BleWorldClock]) {
       // print("onReadWorldClock \(worldClocks)")
        var item = [String: Any]()

        let i = worldClocks.map { data -> [String: Any] in
            return data.toDictionary()
        }

        item["clocks"] =  i

        if let onReadWorldClockSink = onReadWorldClockSink {
            onReadWorldClockSink(item)
        }
    }

    func onWorldClockDelete(_ clockID: Int) {
        var item = [String: Any]()

        item["id"] =  toJSON(clockID)

        if let onWorldClockDeleteSink = onWorldClockDeleteSink {
            onWorldClockDeleteSink(item)
        }
    }

    func onReadStock(_ stocks: [BleStock]) {
        //print("onReadStock \(stocks)")
//        var item = [String: Any]()
//
//        let i = stocks.map { data -> [String: Any] in
//            return data.toDictionary()
//        }
//
//        item["stocks"] =  i
//
//        if let onReadStockSink = onReadStockSink {
//            onReadStockSink(item)
//        }
    }

    func onStockDelete(_ stockID: Int) {

    }

    func onDeviceReadStock(_ status: Bool) {

    }

    func onRealTimeMeasurement(_ measurement: BleRealTimeMeasurement) {

    }

}



func toJSON<T: Encodable>(_ value: T) -> String? {
    let encoder = JSONEncoder()

    do {
        let jsonData = try encoder.encode(value)
        let jsonString = String(data: jsonData, encoding: .utf8)
        return jsonString
    } catch {
        print("Error encoding value to JSON: \(error)")
        return nil
    }
}


extension UIImage {
    func resize(to newSize: CGSize) -> UIImage {
      UIGraphicsBeginImageContextWithOptions(newSize, true, 1)
      draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
      let result = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      return result!
    }
}
