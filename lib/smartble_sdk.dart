import 'dart:async';

import 'package:flutter/services.dart';

class SmartbleSdk {
  static const MethodChannel _channel = MethodChannel('smartble_sdk');

  ///scan(BluetoothDevice device)
  Future<dynamic> scan() => _channel.invokeMethod('scan');

  ///connect(BluetoothDevice device)
  Future<dynamic> connect({required String bname, required String bmac}) =>
      _channel.invokeMethod('connect', {'bname': bname, 'bmac': bmac});

  Future<dynamic> kOTA() => _channel.invokeMethod('OTA');
  Future<dynamic> kXMODEM() => _channel.invokeMethod('XMODEM');
  Future<dynamic> kTIME() => _channel.invokeMethod('TIME');
  Future<dynamic> kTIME_ZONE() => _channel.invokeMethod('TIME_ZONE');
  Future<dynamic> kPOWER() => _channel.invokeMethod('POWER');
  Future<dynamic> kFIRMWARE_VERSION() =>
      _channel.invokeMethod('FIRMWARE_VERSION');
  Future<dynamic> kBLE_ADDRESS() => _channel.invokeMethod('BLE_ADDRESS');
  Future<dynamic> kUSER_PROFILE() => _channel.invokeMethod('USER_PROFILE');
  Future<dynamic> kSTEP_GOAL() => _channel.invokeMethod('STEP_GOAL');
  Future<dynamic> kBACK_LIGHT() => _channel.invokeMethod('BACK_LIGHT');
  Future<dynamic> kSEDENTARINESS() => _channel.invokeMethod('SEDENTARINESS');
  Future<dynamic> kNO_DISTURB_RANGE() =>
      _channel.invokeMethod('NO_DISTURB_RANGE');
  Future<dynamic> kVIBRATION() => _channel.invokeMethod('VIBRATION');
  Future<dynamic> kGESTURE_WAKE() => _channel.invokeMethod('GESTURE_WAKE');
  Future<dynamic> kHR_ASSIST_SLEEP() =>
      _channel.invokeMethod('HR_ASSIST_SLEEP');
  Future<dynamic> kHOUR_SYSTEM() => _channel.invokeMethod('HOUR_SYSTEM');
  Future<dynamic> kLANGUAGE() => _channel.invokeMethod('LANGUAGE');
  Future<dynamic> kALARM() => _channel.invokeMethod('ALARM');
  Future<dynamic> kCOACHING() => _channel.invokeMethod('COACHING');
  Future<dynamic> kFIND_PHONE() => _channel.invokeMethod('FIND_PHONE');
  Future<dynamic> kNOTIFICATION_REMINDER() =>
      _channel.invokeMethod('NOTIFICATION_REMINDER');
  Future<dynamic> kANTI_LOST() => _channel.invokeMethod('ANTI_LOST');
  Future<dynamic> kHR_MONITORING() => _channel.invokeMethod('HR_MONITORING');
  Future<dynamic> kUI_PACK_VERSION() =>
      _channel.invokeMethod('UI_PACK_VERSION');
  Future<dynamic> kLANGUAGE_PACK_VERSION() =>
      _channel.invokeMethod('LANGUAGE_PACK_VERSION');
  Future<dynamic> kSLEEP_QUALITY() => _channel.invokeMethod('SLEEP_QUALITY');
  Future<dynamic> kGIRL_CARE() => _channel.invokeMethod('GIRL_CARE');
  Future<dynamic> kTEMPERATURE_DETECTING() =>
      _channel.invokeMethod('TEMPERATURE_DETECTING');
  Future<dynamic> kAEROBIC_EXERCISE() =>
      _channel.invokeMethod('AEROBIC_EXERCISE');
  Future<dynamic> kTEMPERATURE_UNIT() =>
      _channel.invokeMethod('TEMPERATURE_UNIT');
  Future<dynamic> kDATE_FORMAT() => _channel.invokeMethod('DATE_FORMAT');
  Future<dynamic> kWATCH_FACE_SWITCH() =>
      _channel.invokeMethod('WATCH_FACE_SWITCH');
  Future<dynamic> kAGPS_PREREQUISITE() =>
      _channel.invokeMethod('AGPS_PREREQUISITE');
  Future<dynamic> kDRINK_WATER() => _channel.invokeMethod('DRINK_WATER');
  Future<dynamic> kSHUTDOWN() => _channel.invokeMethod('SHUTDOWN');
  Future<dynamic> kAPP_SPORT_DATA() => _channel.invokeMethod('APP_SPORT_DATA');
  Future<dynamic> kREAL_TIME_HEART_RATE() =>
      _channel.invokeMethod('REAL_TIME_HEART_RATE');
  Future<dynamic> kBLOOD_OXYGEN_SET() =>
      _channel.invokeMethod('BLOOD_OXYGEN_SET');
  Future<dynamic> kWASH_SET() => _channel.invokeMethod('WASH_SET');
  Future<dynamic> kWATCHFACE_ID() => _channel.invokeMethod('WATCHFACE_ID');
  Future<dynamic> kIBEACON_SET() => _channel.invokeMethod('IBEACON_SET');
  Future<dynamic> kMAC_QRCODE() => _channel.invokeMethod('MAC_QRCODE');
  Future<dynamic> kREAL_TIME_TEMPERATURE() =>
      _channel.invokeMethod('REAL_TIME_TEMPERATURE');
  Future<dynamic> kREAL_TIME_BLOOD_PRESSURE() =>
      _channel.invokeMethod('REAL_TIME_BLOOD_PRESSURE');
  Future<dynamic> kTEMPERATURE_VALUE() =>
      _channel.invokeMethod('TEMPERATURE_VALUE');
  Future<dynamic> kGAME_SET() => _channel.invokeMethod('GAME_SET');
  Future<dynamic> kFIND_WATCH() => _channel.invokeMethod('FIND_WATCH');
  Future<dynamic> kSET_WATCH_PASSWORD() =>
      _channel.invokeMethod('SET_WATCH_PASSWORD');
  Future<dynamic> kREALTIME_MEASUREMENT() =>
      _channel.invokeMethod('REALTIME_MEASUREMENT');
  Future<dynamic> kLOCATION_GSV() => _channel.invokeMethod('LOCATION_GSV');
  Future<dynamic> kHR_RAW() => _channel.invokeMethod('HR_RAW');
  Future<dynamic> kREALTIME_LOG() => _channel.invokeMethod('REALTIME_LOG');
  Future<dynamic> kGSENSOR_OUTPUT() => _channel.invokeMethod('GSENSOR_OUTPUT');
  Future<dynamic> kGSENSOR_RAW() => _channel.invokeMethod('GSENSOR_RAW');
  Future<dynamic> kMOTION_DETECT() => _channel.invokeMethod('MOTION_DETECT');
  Future<dynamic> kLOCATION_GGA() => _channel.invokeMethod('LOCATION_GGA');
  Future<dynamic> kRAW_SLEEP() => _channel.invokeMethod('RAW_SLEEP');
  Future<dynamic> kNO_DISTURB_GLOBAL() =>
      _channel.invokeMethod('NO_DISTURB_GLOBAL');
  Future<dynamic> kIDENTITY() => _channel.invokeMethod('IDENTITY');
  Future<dynamic> kSESSION() => _channel.invokeMethod('SESSION');
  Future<dynamic> kNOTIFICATION() => _channel.invokeMethod('NOTIFICATION');
  Future<dynamic> kMUSIC_CONTROL() => _channel.invokeMethod('MUSIC_CONTROL');
  Future<dynamic> kSCHEDULE() => _channel.invokeMethod('SCHEDULE');
  Future<dynamic> kWEATHER_REALTIME() =>
      _channel.invokeMethod('WEATHER_REALTIME');
  Future<dynamic> kWEATHER_FORECAST() =>
      _channel.invokeMethod('WEATHER_FORECAST');
  Future<dynamic> kHID() => _channel.invokeMethod('HID');
  Future<dynamic> kWORLD_CLOCK() => _channel.invokeMethod('WORLD_CLOCK');
  Future<dynamic> kSTOCK() => _channel.invokeMethod('STOCK');
  Future<dynamic> kSMS_QUICK_REPLY_CONTENT() =>
      _channel.invokeMethod('SMS_QUICK_REPLY_CONTENT');
  Future<dynamic> kNOTIFICATION2() => _channel.invokeMethod('NOTIFICATION2');
  Future<dynamic> kDATA_ALL() => _channel.invokeMethod('DATA_ALL');
  Future<dynamic> kACTIVITY_REALTIME() =>
      _channel.invokeMethod('ACTIVITY_REALTIME');
  Future<dynamic> kACTIVITY() => _channel.invokeMethod('ACTIVITY');
  Future<dynamic> kHEART_RATE() => _channel.invokeMethod('HEART_RATE');
  Future<dynamic> kBLOOD_PRESSURE() => _channel.invokeMethod('BLOOD_PRESSURE');
  Future<dynamic> kSLEEP() => _channel.invokeMethod('SLEEP');
  Future<dynamic> kWORKOUT() => _channel.invokeMethod('WORKOUT');
  Future<dynamic> kLOCATION() => _channel.invokeMethod('LOCATION');
  Future<dynamic> kTEMPERATURE() => _channel.invokeMethod('TEMPERATURE');
  Future<dynamic> kBLOOD_OXYGEN() => _channel.invokeMethod('BLOOD_OXYGEN');
  Future<dynamic> kHRV() => _channel.invokeMethod('HRV');
  Future<dynamic> kLOG() => _channel.invokeMethod('LOG');
  Future<dynamic> kSLEEP_RAW_DATA() => _channel.invokeMethod('SLEEP_RAW_DATA');
  Future<dynamic> kPRESSURE() => _channel.invokeMethod('PRESSURE');
  Future<dynamic> kWORKOUT2() => _channel.invokeMethod('WORKOUT2');
  Future<dynamic> kMATCH_RECORD() => _channel.invokeMethod('MATCH_RECORD');
  Future<dynamic> kCAMERA() => _channel.invokeMethod('CAMERA');
  Future<dynamic> kREQUEST_LOCATION() =>
      _channel.invokeMethod('REQUEST_LOCATION');
  Future<dynamic> kINCOMING_CALL() => _channel.invokeMethod('INCOMING_CALL');
  Future<dynamic> kAPP_SPORT_STATE() =>
      _channel.invokeMethod('APP_SPORT_STATE');
  Future<dynamic> kCLASSIC_BLUETOOTH_STATE() =>
      _channel.invokeMethod('CLASSIC_BLUETOOTH_STATE');
  Future<dynamic> kDEVICE_SMS_QUICK_REPLY() =>
      _channel.invokeMethod('DEVICE_SMS_QUICK_REPLY');
  Future<dynamic> kWATCH_FACE() => _channel.invokeMethod('WATCH_FACE');
  Future<dynamic> kAGPS_FILE() => _channel.invokeMethod('AGPS_FILE');
  Future<dynamic> kFONT_FILE() => _channel.invokeMethod('FONT_FILE');
  Future<dynamic> kCONTACT() => _channel.invokeMethod('CONTACT');
  Future<dynamic> kUI_FILE() => _channel.invokeMethod('UI_FILE');
  Future<dynamic> kDEVICE_FILE() => _channel.invokeMethod('DEVICE_FILE');
  Future<dynamic> kLANGUAGE_FILE() => _channel.invokeMethod('LANGUAGE_FILE');
  Future<dynamic> kBRAND_INFO_FILE() =>
      _channel.invokeMethod('BRAND_INFO_FILE');

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
