//ignore_for_file: non_constant_identifier_names
//ignore_for_file: constant_identifier_names
import 'dart:core';

import 'package:flutter/services.dart';

enum SelectedBlekeyFlag {
  UPDATE,
  READ,
  CREATE,
  DELETE,
  READ_CONTINUE,
  RESET,
  NONE,
}

class SmartbleSdk {
  static const MethodChannel _channel = MethodChannel('smartble_sdk');

  ///convert mTime real to DateTime format
  DateTime mTimeRealToDateTime({required int mTimeReal}) {
    return DateTime.fromMillisecondsSinceEpoch(mTimeReal * 1000);
  }

  ///convert mTime(BluetoothDevice device) to DateTime format
  DateTime mTimeDeviceToDateTime({required int mTimeDevice}) {
    int offset = DateTime.now().timeZoneOffset.inSeconds;
    const int dataEpoch = 946684800;
    return DateTime.fromMillisecondsSinceEpoch(
        (mTimeDevice + dataEpoch - offset) * 1000);
  }

  ///convert mTime(BluetoothDevice device) to real timestamp
  int mTimeReal({required int mTime}) {
    int offset = DateTime.now().timeZoneOffset.inSeconds;
    const int dataEpoch = 946684800;
    return mTime + dataEpoch - offset;
  }

  ///scan(BluetoothDevice device)
  Future<dynamic> scan({required bool isScan}) =>
      _channel.invokeMethod('scan', {'isScan': isScan});

  ///setAddress(BluetoothDevice device)
  Future<dynamic> setAddress({required String bname, required String bmac}) =>
      _channel.invokeMethod('setAddress', {'bname': bname, 'bmac': bmac});

  ///connect(BluetoothDevice device)
  Future<dynamic> connect() => _channel.invokeMethod('connect');

  ///isConnecting(BluetoothDevice device)
  Future<dynamic> isConnecting() => _channel.invokeMethod('isConnecting');

  ///isNeedBind(BluetoothDevice device)
  Future<dynamic> isNeedBind() => _channel.invokeMethod('isNeedBind');

  ///connectHID(BluetoothDevice device)
  Future<dynamic> connectHID() => _channel.invokeMethod('connectHID');

  ///connectClassic(BluetoothDevice device)
  Future<dynamic> connectClassic() => _channel.invokeMethod('connectClassic');

  ///closeConnection(BluetoothDevice device)
  Future<dynamic> closeConnection() => _channel.invokeMethod('closeConnection');

  ///unbind(BluetoothDevice device)
  Future<dynamic> unbind() => _channel.invokeMethod('unbind');

  ///analyzeSleep
  Future<dynamic> analyzeSleep({required List listSleep}) {
    List<Map<String, int>> listSleepNew = [];
    for (var element in listSleep) {
      Map<String, int> map = {};
      DateTime epoch = DateTime(2000, 1, 1);
      DateTime dateNote = DateTime.parse("${element["mTime"]}");
      map["mTime"] = dateNote.difference(epoch).inSeconds;
      map["mMode"] = int.parse("${element["mMode"]}");
      map["mStrong"] = int.parse("${element["mStrong"]}");
      map["mSoft"] = int.parse("${element["mSoft"]}");
      map["mDateDur"] = dateNote.difference(epoch).inDays;
      listSleepNew.add(map);
    }
    return _channel
        .invokeMethod('analyzeSleep', {'listSleep': "$listSleepNew"});
  }

  ///customDials
  Future<dynamic> customDials({
    required Uint8List bgPreviewBytes,
    required Uint8List bgBytes,
    required int custom,
    required bool isDigital,
    required bool isRound,
    required int screenWidth,
    required int screenHeight,
    required int screenPreviewWidth,
    required int screenPreviewHeight,
    required bool controlViewStep,
    required int controlViewStepX,
    required int controlViewStepY,
    required bool controlViewCa,
    required int controlViewCaX,
    required int controlViewCaY,
    required bool controlViewDis,
    required int controlViewDisX,
    required int controlViewDisY,
    required bool controlViewHr,
    required int controlViewHrX,
    required int controlViewHrY,
    int? digiLeft,
    int? digiTop,
  }) {
    return _channel.invokeMethod('customDials', {
      'bgPreviewBytes': bgPreviewBytes,
      'bgBytes': bgBytes,
      'custom': custom,
      'isDigital': isDigital,
      'isRound': isRound,
      'screenWidth': screenWidth,
      'screenHeight': screenHeight,
      'screenPreviewWidth': screenPreviewWidth,
      'screenPreviewHeight': screenPreviewHeight,
      'controlViewStep': controlViewStep,
      'controlViewStepX': controlViewStepX,
      'controlViewStepY': controlViewStepY,
      'controlViewCa': controlViewCa,
      'controlViewCaX': controlViewCaX,
      'controlViewCaY': controlViewCaY,
      'controlViewDis': controlViewDis,
      'controlViewDisX': controlViewDisX,
      'controlViewDisY': controlViewDisY,
      'controlViewHr': controlViewHr,
      'controlViewHrX': controlViewHrX,
      'controlViewHrY': controlViewHrY,
      'digiLeft': digiLeft ?? screenWidth ~/ 3.5,
      'digiTop': digiTop ?? screenHeight ~/ 3
    });
  }

  Future<dynamic> kOTA(
          {required SelectedBlekeyFlag flag, String? path, String? url}) =>
      _channel
          .invokeMethod('OTA', {'flag': flag.name, 'path': path, 'url': url});

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

  Future<dynamic> kBACK_LIGHT(
          {required SelectedBlekeyFlag flag, required int times}) =>
      _channel.invokeMethod('BACK_LIGHT', {'flag': flag.name, 'times': times});

  Future<dynamic> kSEDENTARINESS({
    required SelectedBlekeyFlag flag,
    required int mEnabled,
    required int mRepeat,
    required int mStartHour,
    required int mStartMinute,
    required int mEndHour,
    required int mEndMinute,
    required int mInterval,
    List? listRepeat,
  }) =>
      _channel.invokeMethod('SEDENTARINESS', {
        'flag': flag.name,
        'mEnabled': mEnabled,
        'mStartHour': mStartHour,
        'mStartMinute': mStartMinute,
        'mEndHour': mEndHour,
        'mEndMinute': mEndMinute,
        'mRepeat': mRepeat,
        'mInterval': mInterval,
        'listRepeat': listRepeat,
      });

  Future<dynamic> kNO_DISTURB_RANGE(
          {required SelectedBlekeyFlag flag, required int disturbsetting}) =>
      _channel.invokeMethod('NO_DISTURB_RANGE',
          {'flag': flag.name, 'disturbSetting': disturbsetting});

  Future<dynamic> kVIBRATION(
          {required SelectedBlekeyFlag flag, required int frequency}) =>
      _channel.invokeMethod(
          'VIBRATION', {'flag': flag.name, 'frequency': frequency});

  Future<dynamic> kGESTURE_WAKE(
          {required SelectedBlekeyFlag flag,
          required int mEnabled,
          required int mStartHour,
          required int mStartMinute,
          required int mEndHour,
          required int mEndMinute}) =>
      _channel.invokeMethod('GESTURE_WAKE', {
        'flag': flag.name,
        'mEnabled': mEnabled,
        'mStartHour': mStartHour,
        'mStartMinute': mStartMinute,
        'mEndHour': mEndHour,
        'mEndMinute': mEndMinute
      });

  Future<dynamic> kHR_ASSIST_SLEEP({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('HR_ASSIST_SLEEP', {'flag': flag.name});

  Future<dynamic> kHOUR_SYSTEM({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('HOUR_SYSTEM', {'flag': flag.name});

  Future<dynamic> kLANGUAGE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('LANGUAGE', {'flag': flag.name});

  Future<dynamic> kALARM(
          {required SelectedBlekeyFlag flag,
          int? index,
          int? mEnabled,
          String? mRepeat,
          int? mYear,
          int? mMonth,
          int? mDay,
          int? mHour,
          int? mMinute,
          String? mTag,
          List? listRepeat}) =>
      _channel.invokeMethod('ALARM', {
        'flag': flag.name,
        'index': index,
        'mEnabled': mEnabled,
        'mRepeat': mRepeat,
        'mYear': mYear,
        'mMonth': mMonth,
        'mDay': mDay,
        'mHour': mHour,
        'mMinute': mMinute,
        'mTag': mTag,
        'listRepeat': listRepeat
      });

  Future<dynamic> kCOACHING({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('COACHING', {'flag': flag.name});

  Future<dynamic> kFIND_PHONE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('FIND_PHONE', {'flag': flag.name});

  Future<dynamic> kNOTIFICATION_REMINDER({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('NOTIFICATION_REMINDER', {'flag': flag.name});

  Future<dynamic> kANTI_LOST(
          {required SelectedBlekeyFlag flag, required bool isAntiLost}) =>
      _channel.invokeMethod(
          'ANTI_LOST', {'flag': flag.name, 'isAntiLost': isAntiLost});

  Future<dynamic> kHR_MONITORING({
    required SelectedBlekeyFlag flag,
    required int mEnabled,
    required int mStartHour,
    required int mStartMinute,
    required int mEndHour,
    required int mEndMinute,
    required int mInterval,
  }) =>
      _channel.invokeMethod('HR_MONITORING', {
        'flag': flag.name,
        'mEnabled': mEnabled,
        'mStartHour': mStartHour,
        'mStartMinute': mStartMinute,
        'mEndHour': mEndHour,
        'mEndMinute': mEndMinute,
        'mInterval': mInterval,
      });

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

  Future<dynamic> kDATE_FORMAT(
          {required SelectedBlekeyFlag flag, required int format}) =>
      _channel
          .invokeMethod('DATE_FORMAT', {'flag': flag.name, 'format': format});

  Future<dynamic> kWATCH_FACE_SWITCH({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('WATCH_FACE_SWITCH', {'flag': flag.name});

  Future<dynamic> kAGPS_PREREQUISITE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('AGPS_PREREQUISITE', {'flag': flag.name});

  Future<dynamic> kDRINK_WATER({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('DRINK_WATER', {'flag': flag.name});

  Future<dynamic> kSHUTDOWN({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('SHUTDOWN', {'flag': flag.name});

  Future<dynamic> kAPP_SPORT_DATA({
    required SelectedBlekeyFlag flag,
    required int sportMode,
    required int mDuration,
    required int mAltitude,
    required int mAirPressure,
    required int mSpm,
    required int mStep,
    required int mDistance,
    required int mCalorie,
    required int mSpeed,
    required int mPace,
  }) =>
      _channel.invokeMethod('APP_SPORT_DATA', {
        'flag': flag.name,
        'sportMode': sportMode,
        'mDuration': mDuration,
        'mAltitude': mAltitude,
        'mAirPressure': mAirPressure,
        'mSpm': mSpm,
        'mStep': mStep,
        'mDistance': mDistance,
        'mCalorie': mCalorie,
        'mSpeed': mSpeed,
        'mPace': mPace
      });

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

  Future<dynamic> kNO_DISTURB_GLOBAL(
          {required SelectedBlekeyFlag flag, required bool isDoNotDistrub}) =>
      _channel.invokeMethod('NO_DISTURB_GLOBAL',
          {'flag': flag.name, 'isDoNotDistrub': isDoNotDistrub});

  Future<dynamic> kIDENTITY({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('IDENTITY', {'flag': flag.name});

  Future<dynamic> kSESSION({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('SESSION', {'flag': flag.name});

  Future<dynamic> kNOTIFICATION(
          {required SelectedBlekeyFlag flag,
          required String mTitle,
          required String mContent,
          required String mCategory,
          required String mPackage}) =>
      _channel.invokeMethod('NOTIFICATION', {
        'flag': flag.name,
        'mTitle': mTitle,
        'mContent': mContent,
        'mCategory': mCategory,
        'mPackage': mPackage
      });

  Future<dynamic> kNOTIFICATION2(
          {required SelectedBlekeyFlag flag,
          required String mTitle,
          required String mContent,
          required String mPhone,
          required String mCategory,
          required String mPackage}) =>
      _channel.invokeMethod('NOTIFICATION2', {
        'flag': flag.name,
        'mTitle': mTitle,
        'mContent': mContent,
        'mPhone': mPhone,
        'mCategory': mCategory,
        'mPackage': mPackage
      });

  Future<dynamic> kMUSIC_CONTROL(
          {required SelectedBlekeyFlag flag,
          required String mTitle,
          required String mContent}) =>
      _channel.invokeMethod('MUSIC_CONTROL',
          {'flag': flag.name, 'mTitle': mTitle, 'mContent': mContent});

  Future<dynamic> musicNext() {
    return _channel.invokeMethod('musicNext');
  }

  Future<dynamic> musicPrev() {
    return _channel.invokeMethod('musicPrev');
  }

  Future<dynamic> kSCHEDULE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('SCHEDULE', {'flag': flag.name});

  Future<dynamic> kWEATHER_REALTIME({
    required SelectedBlekeyFlag flag,
    required String realTime,
  }) =>
      _channel.invokeMethod(
          'WEATHER_REALTIME', {'flag': flag.name, 'realTime': realTime});

  Future<dynamic> kWEATHER_FORECAST({
    required SelectedBlekeyFlag flag,
    required String forecast1,
    required String forecast2,
    required String forecast3,
  }) =>
      _channel.invokeMethod('WEATHER_FORECAST', {
        'flag': flag.name,
        'forecast1': forecast1,
        'forecast2': forecast2,
        'forecast3': forecast3,
      });

  Future<dynamic> kHID({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('HID', {'flag': flag.name});

  Future<dynamic> kWORLD_CLOCK(
          {required SelectedBlekeyFlag flag,
          int? index,
          int? isLocal,
          int? mTimeZoneOffSet,
          int? reversed,
          String? mCityName}) =>
      _channel.invokeMethod('WORLD_CLOCK', {
        'flag': flag.name,
        'index': index,
        'isLocal': isLocal,
        'reversed': reversed,
        'mTimeZoneOffSet': mTimeZoneOffSet,
        'mCityName': mCityName
      });

  Future<dynamic> kSTOCK(
          {required SelectedBlekeyFlag flag,
          required int index,
          required String stock}) =>
      _channel.invokeMethod(
          'STOCK', {'flag': flag.name, 'index': index, 'stock': stock});

  Future<dynamic> kSMS_QUICK_REPLY_CONTENT(
          {required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('SMS_QUICK_REPLY_CONTENT', {'flag': flag.name});

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

  Future<dynamic> kCAMERA(
          {required SelectedBlekeyFlag flag, required bool mCameraEntered}) =>
      _channel.invokeMethod(
          'CAMERA', {'flag': flag.name, 'mCameraEntered': mCameraEntered});

  Future<dynamic> kREQUEST_LOCATION(
          {required SelectedBlekeyFlag flag,
          required double mSpeed,
          required double mTotalDistance,
          required int mAltitude}) =>
      _channel.invokeMethod('REQUEST_LOCATION', {
        'flag': flag.name,
        'mSpeed': mSpeed.toStringAsFixed(2),
        'mTotalDistance': mTotalDistance.toStringAsFixed(2),
        'mAltitude': mAltitude
      });

  Future<dynamic> kINCOMING_CALL({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('INCOMING_CALL', {'flag': flag.name});

  Future<dynamic> kAPP_SPORT_STATE(
          {required SelectedBlekeyFlag flag,
          required int sportMode,
          required int sportState}) =>
      _channel.invokeMethod('APP_SPORT_STATE', {
        'flag': flag.name,
        'sportMode': sportMode,
        'sportState': sportState
      });

  Future<dynamic> kCLASSIC_BLUETOOTH_STATE(
          {required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('CLASSIC_BLUETOOTH_STATE', {'flag': flag.name});

  Future<dynamic> kDEVICE_SMS_QUICK_REPLY({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('DEVICE_SMS_QUICK_REPLY', {'flag': flag.name});

  Future<dynamic> kWATCH_FACE(
          {required SelectedBlekeyFlag flag, String? path, String? url}) =>
      _channel.invokeMethod(
          'WATCH_FACE', {'flag': flag.name, 'path': path, 'url': url});

  Future<dynamic> kAGPS_FILE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('AGPS_FILE', {'flag': flag.name});

  Future<dynamic> kFONT_FILE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('FONT_FILE', {'flag': flag.name});

  Future<dynamic> kCONTACT(
          {required SelectedBlekeyFlag flag,
          required List<Map<String, String>> listContact}) =>
      _channel.invokeMethod(
          'CONTACT', {'flag': flag.name, 'listContact': listContact});

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

  static const EventChannel _onReadWorkoutChannel =
      EventChannel('onReadWorkout');

  static Stream<dynamic> get onReadWorkoutStream {
    return _onReadWorkoutChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onReadBloodOxygenChannel =
      EventChannel('onReadBloodOxygen');

  static Stream<dynamic> get onReadBloodOxygenStream {
    return _onReadBloodOxygenChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onReadBleHrvChannel = EventChannel('onReadBleHrv');

  static Stream<dynamic> get onReadBleHrvStream {
    return _onReadBleHrvChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onReadPressureChannel =
      EventChannel('onReadPressure');

  static Stream<dynamic> get onReadPressureStream {
    return _onReadPressureChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onDeviceConnectingChannel =
      EventChannel('onDeviceConnecting');

  static Stream<dynamic> get onDeviceConnectingStream {
    return _onDeviceConnectingChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onIncomingCallStatusChannel =
      EventChannel('onIncomingCallStatus');

  static Stream<dynamic> get onIncomingCallStatusStream {
    return _onIncomingCallStatusChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onReceiveMusicCommandChannel =
      EventChannel("onReceiveMusicCommand");

  static Stream<dynamic> get onReceiveMusicCommandStream {
    return _onReceiveMusicCommandChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onReadWorldClockChannel =
      EventChannel("onReadWorldClock");

  static Stream<dynamic> get onReadWorldClockStream {
    return _onReadWorldClockChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onWorldClockDeleteChannel =
      EventChannel("onWorldClockDelete");
  static Stream<dynamic> get onWorldClockDeleteStream {
    return _onWorldClockDeleteChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onStockReadChannel = EventChannel("onStockRead");
  static Stream<dynamic> get onStockReadStream {
    return _onStockReadChannel.receiveBroadcastStream().cast();
  }

  static const EventChannel _onStockDeleteChannel =
      EventChannel("onStockDelete");
  static Stream<dynamic> get onStockDeleteStream {
    return _onStockDeleteChannel.receiveBroadcastStream().cast();
  }
}

class BleNotificationCategory {
  static String categoryIncomingCall = "1";
  static String categoryMessage = "2";
}

class KDateFormat {
  static int yearMonthDay = 0;
  static int dayMonthYear = 1;
  static int monthDayYear = 2;
}

class BleRepeat {
  static String MONDAY = "MONDAY";
  static String TUESDAY = "TUESDAY";
  static String WEDNESDAY = "WEDNESDAY";
  static String THURSDAY = "THURSDAY";
  static String FRIDAY = "FRIDAY";
  static String SATURDAY = "SATURDAY";
  static String SUNDAY = "SUNDAY";
  static String ONCE = "ONCE";
  static String WORKDAY = "WORKDAY";
  static String WEEKEND = "WEEKEND";
  static String EVERYDAY = "EVERYDAY";
}

class BleAppSport {
  static int STATE_START = 1;
  static int STATE_RESUME = 2;
  static int STATE_PAUSE = 3;
  static int STATE_END = 4;

  static int INDOOR = 1;
  static int OUTDOOR = 2;
  static int CYCLING = 3;
  static int CLIMBING = 4;
}
