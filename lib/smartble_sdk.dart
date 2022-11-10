import 'dart:async';

import 'package:flutter/services.dart';
import 'package:smartble_sdk/selected_blekey_flag.dart';

class SmartbleSdk {
  static const MethodChannel _channel = MethodChannel('smartble_sdk');

  ///scan(BluetoothDevice device)
  Future<dynamic> scan() => _channel.invokeMethod('scan');

  ///connect(BluetoothDevice device)
  Future<dynamic> connect({required String bname, required String bmac}) =>
      _channel.invokeMethod('connect', {'bname': bname, 'bmac': bmac});

  Future<dynamic> kOTA({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('OTA', {'flag': flag.name});
  Future<dynamic> kXMODEM({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('XMODEM', {'flag': flag.name});
  Future<dynamic> kTIME({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('TIME', {'flag': flag.name});
  Future<dynamic> kTIME_ZONE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('TIME_ZONE', {'flag': flag.name});
  Future<dynamic> kPOWER({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('POWER', {'flag': flag.name});
  Future<dynamic> kFIRMWARE_VERSION({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('FIRMWARE_VERSION', {'flag': flag.name});
  Future<dynamic> kBLE_ADDRESS({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('BLE_ADDRESS', {'flag': flag.name});
  Future<dynamic> kUSER_PROFILE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('USER_PROFILE', {'flag': flag.name});
  Future<dynamic> kSTEP_GOAL({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('STEP_GOAL', {'flag': flag.name});
  Future<dynamic> kBACK_LIGHT({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('BACK_LIGHT', {'flag': flag.name});
  Future<dynamic> kSEDENTARINESS({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('SEDENTARINESS', {'flag': flag.name});
  Future<dynamic> kNO_DISTURB_RANGE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('NO_DISTURB_RANGE', {'flag': flag.name});
  Future<dynamic> kVIBRATION({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('VIBRATION', {'flag': flag.name});
  Future<dynamic> kGESTURE_WAKE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('GESTURE_WAKE', {'flag': flag.name});
  Future<dynamic> kHR_ASSIST_SLEEP({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('HR_ASSIST_SLEEP', {'flag': flag.name});
  Future<dynamic> kHOUR_SYSTEM({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('HOUR_SYSTEM', {'flag': flag.name});
  Future<dynamic> kLANGUAGE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('LANGUAGE', {'flag': flag.name});
  Future<dynamic> kALARM({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('ALARM', {'flag': flag.name});
  Future<dynamic> kCOACHING({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('COACHING', {'flag': flag.name});
  Future<dynamic> kFIND_PHONE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('FIND_PHONE', {'flag': flag.name});
  Future<dynamic> kNOTIFICATION_REMINDER({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('NOTIFICATION_REMINDER', {'flag': flag.name});
  Future<dynamic> kANTI_LOST({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('ANTI_LOST', {'flag': flag.name});
  Future<dynamic> kHR_MONITORING({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('HR_MONITORING', {'flag': flag.name});
  Future<dynamic> kUI_PACK_VERSION({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('UI_PACK_VERSION', {'flag': flag.name});
  Future<dynamic> kLANGUAGE_PACK_VERSION({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('LANGUAGE_PACK_VERSION', {'flag': flag.name});
  Future<dynamic> kSLEEP_QUALITY({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('SLEEP_QUALITY', {'flag': flag.name});
  Future<dynamic> kGIRL_CARE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('GIRL_CARE', {'flag': flag.name});
  Future<dynamic> kTEMPERATURE_DETECTING({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('TEMPERATURE_DETECTING', {'flag': flag.name});
  Future<dynamic> kAEROBIC_EXERCISE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('AEROBIC_EXERCISE', {'flag': flag.name});
  Future<dynamic> kTEMPERATURE_UNIT({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('TEMPERATURE_UNIT', {'flag': flag.name});
  Future<dynamic> kDATE_FORMAT({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('DATE_FORMAT', {'flag': flag.name});
  Future<dynamic> kWATCH_FACE_SWITCH({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('WATCH_FACE_SWITCH', {'flag': flag.name});
  Future<dynamic> kAGPS_PREREQUISITE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('AGPS_PREREQUISITE', {'flag': flag.name});
  Future<dynamic> kDRINK_WATER({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('DRINK_WATER', {'flag': flag.name});
  Future<dynamic> kSHUTDOWN({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('SHUTDOWN', {'flag': flag.name});
  Future<dynamic> kAPP_SPORT_DATA({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('APP_SPORT_DATA', {'flag': flag.name});
  Future<dynamic> kREAL_TIME_HEART_RATE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('REAL_TIME_HEART_RATE', {'flag': flag.name});
  Future<dynamic> kBLOOD_OXYGEN_SET({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('BLOOD_OXYGEN_SET', {'flag': flag.name});
  Future<dynamic> kWASH_SET({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('WASH_SET', {'flag': flag.name});
  Future<dynamic> kWATCHFACE_ID({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('WATCHFACE_ID', {'flag': flag.name});
  Future<dynamic> kIBEACON_SET({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('IBEACON_SET', {'flag': flag.name});
  Future<dynamic> kMAC_QRCODE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('MAC_QRCODE', {'flag': flag.name});
  Future<dynamic> kREAL_TIME_TEMPERATURE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('REAL_TIME_TEMPERATURE', {'flag': flag.name});
  Future<dynamic> kREAL_TIME_BLOOD_PRESSURE(
          {required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('REAL_TIME_BLOOD_PRESSURE', {'flag': flag.name});
  Future<dynamic> kTEMPERATURE_VALUE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('TEMPERATURE_VALUE', {'flag': flag.name});
  Future<dynamic> kGAME_SET({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('GAME_SET', {'flag': flag.name});
  Future<dynamic> kFIND_WATCH({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('FIND_WATCH', {'flag': flag.name});
  Future<dynamic> kSET_WATCH_PASSWORD({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('SET_WATCH_PASSWORD', {'flag': flag.name});
  Future<dynamic> kREALTIME_MEASUREMENT({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('REALTIME_MEASUREMENT', {'flag': flag.name});
  Future<dynamic> kLOCATION_GSV({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('LOCATION_GSV', {'flag': flag.name});
  Future<dynamic> kHR_RAW({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('HR_RAW', {'flag': flag.name});
  Future<dynamic> kREALTIME_LOG({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('REALTIME_LOG', {'flag': flag.name});
  Future<dynamic> kGSENSOR_OUTPUT({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('GSENSOR_OUTPUT', {'flag': flag.name});
  Future<dynamic> kGSENSOR_RAW({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('GSENSOR_RAW', {'flag': flag.name});
  Future<dynamic> kMOTION_DETECT({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('MOTION_DETECT', {'flag': flag.name});
  Future<dynamic> kLOCATION_GGA({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('LOCATION_GGA', {'flag': flag.name});
  Future<dynamic> kRAW_SLEEP({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('RAW_SLEEP', {'flag': flag.name});
  Future<dynamic> kNO_DISTURB_GLOBAL({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('NO_DISTURB_GLOBAL', {'flag': flag.name});
  Future<dynamic> kIDENTITY({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('IDENTITY', {'flag': flag.name});
  Future<dynamic> kSESSION({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('SESSION', {'flag': flag.name});
  Future<dynamic> kNOTIFICATION({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('NOTIFICATION', {'flag': flag.name});
  Future<dynamic> kMUSIC_CONTROL({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('MUSIC_CONTROL', {'flag': flag.name});
  Future<dynamic> kSCHEDULE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('SCHEDULE', {'flag': flag.name});
  Future<dynamic> kWEATHER_REALTIME({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('WEATHER_REALTIME', {'flag': flag.name});
  Future<dynamic> kWEATHER_FORECAST({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('WEATHER_FORECAST', {'flag': flag.name});
  Future<dynamic> kHID({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('HID', {'flag': flag.name});
  Future<dynamic> kWORLD_CLOCK({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('WORLD_CLOCK', {'flag': flag.name});
  Future<dynamic> kSTOCK({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('STOCK', {'flag': flag.name});
  Future<dynamic> kSMS_QUICK_REPLY_CONTENT(
          {required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('SMS_QUICK_REPLY_CONTENT', {'flag': flag.name});
  Future<dynamic> kNOTIFICATION2({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('NOTIFICATION2', {'flag': flag.name});
  Future<dynamic> kDATA_ALL({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('DATA_ALL', {'flag': flag.name});
  Future<dynamic> kACTIVITY_REALTIME({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('ACTIVITY_REALTIME', {'flag': flag.name});
  Future<dynamic> kACTIVITY({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('ACTIVITY', {'flag': flag.name});
  Future<dynamic> kHEART_RATE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('HEART_RATE', {'flag': flag.name});
  Future<dynamic> kBLOOD_PRESSURE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('BLOOD_PRESSURE', {'flag': flag.name});
  Future<dynamic> kSLEEP({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('SLEEP', {'flag': flag.name});
  Future<dynamic> kWORKOUT({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('WORKOUT', {'flag': flag.name});
  Future<dynamic> kLOCATION({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('LOCATION', {'flag': flag.name});
  Future<dynamic> kTEMPERATURE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('TEMPERATURE', {'flag': flag.name});
  Future<dynamic> kBLOOD_OXYGEN({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('BLOOD_OXYGEN', {'flag': flag.name});
  Future<dynamic> kHRV({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('HRV', {'flag': flag.name});
  Future<dynamic> kLOG({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('LOG', {'flag': flag.name});
  Future<dynamic> kSLEEP_RAW_DATA({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('SLEEP_RAW_DATA', {'flag': flag.name});
  Future<dynamic> kPRESSURE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('PRESSURE', {'flag': flag.name});
  Future<dynamic> kWORKOUT2({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('WORKOUT2', {'flag': flag.name});
  Future<dynamic> kMATCH_RECORD({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('MATCH_RECORD', {'flag': flag.name});
  Future<dynamic> kCAMERA({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('CAMERA', {'flag': flag.name});
  Future<dynamic> kREQUEST_LOCATION({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('REQUEST_LOCATION', {'flag': flag.name});
  Future<dynamic> kINCOMING_CALL({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('INCOMING_CALL', {'flag': flag.name});
  Future<dynamic> kAPP_SPORT_STATE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('APP_SPORT_STATE', {'flag': flag.name});
  Future<dynamic> kCLASSIC_BLUETOOTH_STATE(
          {required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('CLASSIC_BLUETOOTH_STATE', {'flag': flag.name});
  Future<dynamic> kDEVICE_SMS_QUICK_REPLY({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('DEVICE_SMS_QUICK_REPLY', {'flag': flag.name});
  Future<dynamic> kWATCH_FACE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('WATCH_FACE', {'flag': flag.name});
  Future<dynamic> kAGPS_FILE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('AGPS_FILE', {'flag': flag.name});
  Future<dynamic> kFONT_FILE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('FONT_FILE', {'flag': flag.name});
  Future<dynamic> kCONTACT({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('CONTACT', {'flag': flag.name});
  Future<dynamic> kUI_FILE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('UI_FILE', {'flag': flag.name});
  Future<dynamic> kDEVICE_FILE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('DEVICE_FILE', {'flag': flag.name});
  Future<dynamic> kLANGUAGE_FILE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('LANGUAGE_FILE', {'flag': flag.name});
  Future<dynamic> kBRAND_INFO_FILE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('BRAND_INFO_FILE', {'flag': flag.name});

  static const EventChannel _scanChannel = EventChannel('smartble_sdk/scan');
  static Stream<dynamic> get getDeviceListStream {
    return _scanChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onDeviceConnectedChannel =
      EventChannel('onDeviceConnected');
  static Stream<dynamic> get onDeviceConnectedStream {
    return _onDeviceConnectedChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onIdentityCreateChannel =
      EventChannel('onIdentityCreate');
  static Stream<dynamic> get onIdentityCreateStream {
    return _onIdentityCreateChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onCommandReplyChannel =
      EventChannel('onCommandReply');
  static Stream<dynamic> get onCommandReplyStream {
    return _onCommandReplyChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onOTAChannel = EventChannel('onOTA');
  static Stream<dynamic> get onOTAStream {
    return _onOTAChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onReadPowerChannel = EventChannel('onReadPower');
  static Stream<dynamic> get onReadPowerStream {
    return _onReadPowerChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onReadFirmwareVersionChannel =
      EventChannel('onReadFirmwareVersion');
  static Stream<dynamic> get onReadFirmwareVersionStream {
    return _onReadFirmwareVersionChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onReadBleAddressChannel =
      EventChannel('onReadBleAddress');
  static Stream<dynamic> get onReadBleAddressStream {
    return _onReadBleAddressChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onReadSedentarinessChannel =
      EventChannel('onReadSedentariness');
  static Stream<dynamic> get onReadSedentarinessStream {
    return _onReadSedentarinessChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onReadNoDisturbChannel =
      EventChannel('onReadNoDisturb');
  static Stream<dynamic> get onReadNoDisturbStream {
    return _onReadNoDisturbChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onReadAlarmChannel = EventChannel('onReadAlarm');
  static Stream<dynamic> get onReadAlarmStream {
    return _onReadAlarmChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onReadCoachingIdsChannel =
      EventChannel('onReadCoachingIds');
  static Stream<dynamic> get onReadCoachingIdsStream {
    return _onReadCoachingIdsChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onReadUiPackVersionChannel =
      EventChannel('onReadUiPackVersion');
  static Stream<dynamic> get onReadUiPackVersionStream {
    return _onReadUiPackVersionChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onReadLanguagePackVersionChannel =
      EventChannel('onReadLanguagePackVersion');
  static Stream<dynamic> get onReadLanguagePackVersionStream {
    return _onReadLanguagePackVersionChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onIdentityDeleteByDeviceChannel =
      EventChannel('onIdentityDeleteByDevice');
  static Stream<dynamic> get onIdentityDeleteByDeviceStream {
    return _onIdentityDeleteByDeviceChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onCameraStateChangeChannel =
      EventChannel('onCameraStateChange');
  static Stream<dynamic> get onCameraStateChangeStream {
    return _onCameraStateChangeChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onCameraResponseChannel =
      EventChannel('onCameraResponse');
  static Stream<dynamic> get onCameraResponseStream {
    return _onCameraResponseChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onSyncDataChannel = EventChannel('onSyncData');
  static Stream<dynamic> get onSyncDataStream {
    return _onSyncDataChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onReadActivityChannel =
      EventChannel('onReadActivity');
  static Stream<dynamic> get onReadActivityStream {
    return _onReadActivityChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onReadHeartRateChannel =
      EventChannel('onReadHeartRate');
  static Stream<dynamic> get onReadHeartRateStream {
    return _onReadHeartRateChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onUpdateHeartRateChannel =
      EventChannel('onUpdateHeartRate');
  static Stream<dynamic> get onUpdateHeartRateStream {
    return _onUpdateHeartRateChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onReadBloodPressureChannel =
      EventChannel('onReadBloodPressure');
  static Stream<dynamic> get onReadBloodPressureStream {
    return _onReadBloodPressureChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onReadSleepChannel = EventChannel('onReadSleep');
  static Stream<dynamic> get onReadSleepStream {
    return _onReadSleepChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onReadLocationChannel =
      EventChannel('onReadLocation');
  static Stream<dynamic> get onReadLocationStream {
    return _onReadLocationChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onReadTemperatureChannel =
      EventChannel('onReadTemperature');
  static Stream<dynamic> get onReadTemperatureStream {
    return _onReadTemperatureChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onReadWorkout2Channel =
      EventChannel('onReadWorkout2');
  static Stream<dynamic> get onReadWorkout2Stream {
    return _onReadWorkout2Channel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onStreamProgressChannel =
      EventChannel('onStreamProgress');
  static Stream<dynamic> get onStreamProgressStream {
    return _onStreamProgressChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onUpdateAppSportStateChannel =
      EventChannel('onUpdateAppSportState');
  static Stream<dynamic> get onUpdateAppSportStateStream {
    return _onUpdateAppSportStateChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onClassicBluetoothStateChangeChannel =
      EventChannel('onClassicBluetoothStateChange');
  static Stream<dynamic> get onClassicBluetoothStateChangeStream {
    return _onClassicBluetoothStateChangeChannel
        .receiveBroadcastStream()
        .cast();
  }

  static const EventChannel _onDeviceFileUpdateChannel =
      EventChannel('onDeviceFileUpdate');
  static Stream<dynamic> get onDeviceFileUpdateStream {
    return _onDeviceFileUpdateChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onReadDeviceFileChannel =
      EventChannel('onReadDeviceFile');
  static Stream<dynamic> get onReadDeviceFileStream {
    return _onReadDeviceFileChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onReadTemperatureUnitChannel =
      EventChannel('onReadTemperatureUnit');
  static Stream<dynamic> get onReadTemperatureUnitStream {
    return _onReadTemperatureUnitChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onReadDateFormatChannel =
      EventChannel('onReadDateFormat');
  static Stream<dynamic> get onReadDateFormatStream {
    return _onReadDateFormatChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onReadWatchFaceSwitchChannel =
      EventChannel('onReadWatchFaceSwitch');
  static Stream<dynamic> get onReadWatchFaceSwitchStream {
    return _onReadWatchFaceSwitchChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onUpdateWatchFaceSwitchChannel =
      EventChannel('onUpdateWatchFaceSwitch');
  static Stream<dynamic> get onUpdateWatchFaceSwitchStream {
    return _onUpdateWatchFaceSwitchChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onAppSportDataResponseChannel =
      EventChannel('onAppSportDataResponse');
  static Stream<dynamic> get onAppSportDataResponseStream {
    return _onAppSportDataResponseChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onReadWatchFaceIdChannel =
      EventChannel('onReadWatchFaceId');
  static Stream<dynamic> get onReadWatchFaceIdStream {
    return _onReadWatchFaceIdChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onWatchFaceIdUpdateChannel =
      EventChannel('onWatchFaceIdUpdate');
  static Stream<dynamic> get onWatchFaceIdUpdateStream {
    return _onWatchFaceIdUpdateChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onHIDStateChannel = EventChannel('onHIDState');
  static Stream<dynamic> get onHIDStateStream {
    return _onHIDStateChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onHIDValueChangeChannel =
      EventChannel('onHIDValueChange');
  static Stream<dynamic> get onHIDValueChangeStream {
    return _onHIDValueChangeChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onDeviceSMSQuickReplyChannel =
      EventChannel('onDeviceSMSQuickReply');
  static Stream<dynamic> get onDeviceSMSQuickReplyStream {
    return _onDeviceSMSQuickReplyChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onReadDeviceInfoChannel =
      EventChannel('onReadDeviceInfo');
  static Stream<dynamic> get onReadDeviceInfoStream {
    return _onReadDeviceInfoChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onSessionStateChangeChannel =
      EventChannel('onSessionStateChange');
  static Stream<dynamic> get onSessionStateChangeStream {
    return _onSessionStateChangeChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onNoDisturbUpdateChannel =
      EventChannel('onNoDisturbUpdate');
  static Stream<dynamic> get onNoDisturbUpdateStream {
    return _onNoDisturbUpdateChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onAlarmUpdateChannel =
      EventChannel('onAlarmUpdate');
  static Stream<dynamic> get onAlarmUpdateStream {
    return _onAlarmUpdateChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onAlarmDeleteChannel =
      EventChannel('onAlarmDelete');
  static Stream<dynamic> get onAlarmDeleteStream {
    return _onAlarmDeleteChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onAlarmAddChannel = EventChannel('onAlarmAdd');
  static Stream<dynamic> get onAlarmAddStream {
    return _onAlarmAddChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onFindPhoneChannel = EventChannel('onFindPhone');
  static Stream<dynamic> get onFindPhoneStream {
    return _onFindPhoneChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onRequestLocationChannel =
      EventChannel('onRequestLocation');
  static Stream<dynamic> get onRequestLocationStream {
    return _onRequestLocationChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onDeviceRequestAGpsFileChannel =
      EventChannel('onDeviceRequestAGpsFile');
  static Stream<dynamic> get onDeviceRequestAGpsFileStream {
    return _onDeviceRequestAGpsFileChannel.receiveBroadcastStream().cast();
  }
}