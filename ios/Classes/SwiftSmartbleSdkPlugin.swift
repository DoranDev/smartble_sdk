import Flutter
import UIKit
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
                  //READ
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
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
                  bleSedentariness.mEnabled = 1
                  bleSedentariness.mRepeat = 63 // Monday ~ Saturday
                  bleSedentariness.mStartHour = 1
                  bleSedentariness.mEndHour = 22
                  bleSedentariness.mInterval = 60
                  _ = bleConnector.sendObject(bleKey,  BleKeyFlag.UPDATE, bleSedentariness)
              } else if bleKeyFlag ==  BleKeyFlag.READ {
                  //READ
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          case BleKey.NOTIFICATION_REMINDER:
              //消息提醒CALL
              if bleKeyFlag ==  BleKeyFlag.UPDATE {
                  let bleNotificationSettings = BleNotificationSettings()
                  bleNotificationSettings.enable(BleNotificationSettings.MIRROR_PHONE)
                  bleNotificationSettings.enable(BleNotificationSettings.WE_CHAT)
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
              _ = bleConnector.sendBool(bleKey, bleKeyFlag, true)
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
              if bleKeyFlag ==  BleKeyFlag.UPDATE {
                  _ = bleConnector.sendObject(bleKey, bleKeyFlag,
                      BleGestureWake(BleTimeRange(1, 8, 0, 22, 0)))
              } else if bleKeyFlag == BleKeyFlag.READ {
                  //READ
                  _ = bleConnector.sendData(bleKey, bleKeyFlag)
              }
          case BleKey.VIBRATION:
              //震动设置
              if bleKeyFlag ==  BleKeyFlag.UPDATE {
                  _ = bleConnector.sendInt8(bleKey, bleKeyFlag, 3) // 0~10, 0 is off
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
              if bleKeyFlag ==  BleKeyFlag.CREATE {
                  // 创建一个一分钟后的闹钟
                  let calendar = Calendar.current
                  var date = Date()
                  date.addTimeInterval(60.0)
                  _ = bleConnector.sendObject(bleKey, bleKeyFlag, BleAlarm(
                      1, // mEnabled
                      BleRepeat.EVERYDAY, // mRepeat
                      calendar.component(.year, from: date), // mYear
                      calendar.component(.month, from: date), // mMonth
                      calendar.component(.day, from: date), // mDay
                      calendar.component(.hour, from: date), // mHour
                      calendar.component(.minute, from: date), // mMinute
                      "tag" // mTag
                  ))
              } else if bleKeyFlag ==  BleKeyFlag.DELETE {
                  // 如果缓存中有闹钟的话，删除第一个
                  let alarms: [BleAlarm] = BleCache.shared.getArray(.ALARM)
                  if !alarms.isEmpty {
                      _ = bleConnector.sendInt8(bleKey, bleKeyFlag, alarms[0].mId)
                  }
              } else if bleKeyFlag ==  BleKeyFlag.UPDATE {
                  // 如果缓存中有闹钟的话，切换第一个闹钟的开启状态
                  let alarms: [BleAlarm] = BleCache.shared.getArray(.ALARM)
                  if !alarms.isEmpty {
                      let alarm = alarms[0]
                      alarm.mEnabled ^= 1
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
              _ = bleConnector.sendBool(bleKey, bleKeyFlag, true)
          case BleKey.HR_MONITORING:
              //定时心率检查设置
              if bleKeyFlag ==  BleKeyFlag.UPDATE {
                  let hrMonitoring = BleHrMonitoringSettings()
                  hrMonitoring.mBleTimeRange = BleTimeRange(1, 8, 0, 22, 0)
                  hrMonitoring.mInterval = 60 // an hour
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
          case BleKey.WEATHER_REALTIME:
              //实时天气
              if bleKeyFlag ==  BleKeyFlag.UPDATE {
                  // let weatherRealtime: BleWeatherRealtime? = BleCache.shared.getObject(.WEATHER_REALTIME)
                  _ = bleConnector.sendObject(BleKey.WEATHER_REALTIME, bleKeyFlag, BleWeatherRealtime(
                      time: Int(Date().timeIntervalSince1970),
                      weather: BleWeather(
                          currentTemperature: 1,
                          maxTemperature: 1,
                          minTemperature: 1,
                          weatherType: BleWeather.SUNNY,
                          windSpeed: 1,
                          humidity: 1,
                          visibility: 1,
                          ultraVioletIntensity: 1,
                          precipitation: 1
                      )
                  ))
              }
          case BleKey.WEATHER_FORECAST:
              //天气预报
              if bleKeyFlag ==  BleKeyFlag.UPDATE {
                  // let weatherForecast: BleWeatherForecast? = BleCache.shared.getObject(.WEATHER_FORECAST)
                  _ = bleConnector.sendObject(BleKey.WEATHER_FORECAST, bleKeyFlag, BleWeatherForecast(
                      time: Int(Date().timeIntervalSince1970),
                      weather1: BleWeather(
                          currentTemperature: 2,
                          maxTemperature: 2,
                          minTemperature: 2,
                          weatherType: BleWeather.CLOUDY,
                          windSpeed: 2,
                          humidity: 2,
                          visibility: 2,
                          ultraVioletIntensity: 2,
                          precipitation: 2),
                      weather2: BleWeather(
                          currentTemperature: 3,
                          maxTemperature: 3,
                          minTemperature: 3,
                          weatherType: BleWeather.OVERCAST,
                          windSpeed: 3,
                          humidity: 3,
                          visibility: 3,
                          ultraVioletIntensity: 3,
                          precipitation: 3),
                      weather3: BleWeather(
                          currentTemperature: 4,
                          maxTemperature: 4,
                          minTemperature: 4,
                          weatherType: BleWeather.RAINY,
                          windSpeed: 4,
                          humidity: 4,
                          visibility: 4,
                          ultraVioletIntensity: 4,
                          precipitation: 4)
                  ))
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
                  _ = bleConnector.sendInt8(bleKey, bleKeyFlag, CameraState.EXIT)
              } else {
                  _ = bleConnector.sendInt8(bleKey, bleKeyFlag, CameraState.ENTER)
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
             // selectWatchType()
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
//          case BleKey.CONTACT:
//              //address book 同步通讯录到设备
//             if addressBookAuthorization() {
//               selectAddressBook()
//            }
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
              if bleKeyFlag ==  BleKeyFlag.UPDATE {
                  /**
                    0 ->YYYY/MM/dd
                    1 ->dd/MM/YYYY
                    2 ->MM/dd/YYYY
                    */
                  _ = bleConnector.sendInt8(bleKey, bleKeyFlag, 2)
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
       // item["deviceInfo"] = gson.toJson(deviceInfo)

        if let onIdentityCreateSink = onIdentityCreateSink {
            onIdentityCreateSink(item)
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
    }

    func onReadNoDisturb(_ noDisturbSettings: BleNoDisturbSettings) {
        print("onReadNoDisturb \(noDisturbSettings)")
        var item = [String: Any]()
        item["noDisturbSettings"] = noDisturbSettings.toDictionary()

        if let onReadNoDisturbSink = onReadNoDisturbSink {
            onReadNoDisturbSink(item)
        }
    }

    func onReadAlarm(_ alarms: Array<BleAlarm>) {
        print("onReadAlarm \(alarms)")
        var item = [String: Any]()
        item["alarms"] = try!toJSON(alarms)

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

        item["activities"] = try!toJSON(activities)

        if let onReadActivitySink = onReadActivitySink {
            onReadActivitySink(item)
        }
    }

    func onReadHeartRate(_ heartRates: [BleHeartRate]) {
        print("onReadHeartRate \(heartRates)")
        var item = [String: Any]()

        item["heartRates"] = try!toJSON(heartRates)

        if let onReadHeartRateSink = onReadHeartRateSink {
            onReadHeartRateSink(item)
        }
    }

    func onReadBloodPressure(_ bloodPressures: [BleBloodPressure]) {
        print("onReadBloodPressure \(bloodPressures)")
        var item = [String: Any]()

        item["bloodPressures"] = try!toJSON(bloodPressures)

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

        item["sleeps"] = try!toJSON(sleeps)

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

        item["locations"] = try!toJSON(locations)

        if let onReadLocationSink = onReadLocationSink {
            onReadLocationSink(item)
        }

    }

    func onReadTemperature(_ temperatures: [BleTemperature]) {
        print("onReadTemperature \(temperatures)")
        var item = [String: Any]()

        item["temperatures"] = try!toJSON(temperatures)

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
            var item = [String: Any]()

            item["status"] = status
            if let onSessionStateChangeSink = onSessionStateChangeSink {
                onSessionStateChangeSink(item)
            }
        }
    
        func onNoDisturbUpdate(_ noDisturbSettings: BleNoDisturbSettings) {
            print("onNoDisturbUpdate \(noDisturbSettings)")
            var item = [String: Any]()

            item["noDisturbSettings"] = try!toJSON(noDisturbSettings)
            if let onNoDisturbUpdateSink = onNoDisturbUpdateSink {
                onNoDisturbUpdateSink(item)
            }
        }
    
        func onAlarmUpdate(_ alarm: BleAlarm) {
            print("onAlarmUpdate \(alarm)")
        }
    
        func onAlarmDelete(_ id: Int) {
            print("onAlarmDelete \(id)")
        }
    
        func onAlarmAdd(_ alarm: BleAlarm) {
            print("onAlarmAdd \(alarm)")
        }
    
        func onFindPhone(_ start: Bool) {
            print("onFindPhone \(start ? "started" : "stopped")")
        }
    
        func onPhoneGPSSport(_ workoutState: Int) {
            print("onPhoneGPSSport \(WorkoutState.getState(workoutState))")
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
    
}



func toJSON<T>(_ value: T) throws -> Data where T: Encodable {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    return try encoder.encode(value)
}




