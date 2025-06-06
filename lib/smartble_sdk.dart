//ignore_for_file: non_constant_identifier_names
//ignore_for_file: constant_identifier_names
import 'dart:core';

import 'package:flutter/services.dart';
import 'package:smartble_sdk/model/prayer_time.dart';

export 'digital_dial.dart';
export 'model/ble_app_sport.dart';
export 'model/ble_notification_category.dart';
export 'model/ble_repeat.dart';
export 'model/kdate_format.dart';
export 'model/prayer_time.dart';

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

  ///stop scan(BluetoothDevice device)
  Future<dynamic> stopScan({required bool isScan}) =>
      _channel.invokeMethod('stopScan');

  ///setAddress(BluetoothDevice device)
  Future<dynamic> setAddress({required String bname, required String bmac}) =>
      _channel.invokeMethod('setAddress', {'bname': bname, 'bmac': bmac});

  ///connect(BluetoothDevice device)
  Future<dynamic> connect() => _channel.invokeMethod('connect');

  ///isConnecting(BluetoothDevice device)
  Future<dynamic> isConnecting() => _channel.invokeMethod('isConnecting');

  ///isNeedBind(BluetoothDevice device)
  Future<dynamic> isNeedBind() => _channel.invokeMethod('isNeedBind');

  ///isBound(BluetoothDevice device)
  Future<dynamic> isBound() => _channel.invokeMethod('isBound');

  ///connectHID(BluetoothDevice device)
  Future<dynamic> connectHID() => _channel.invokeMethod('connectHID');

  ///connectClassic(BluetoothDevice device)
  Future<dynamic> connectClassic() => _channel.invokeMethod('connectClassic');

  ///closeConnection(BluetoothDevice device)
  Future<dynamic> closeConnection() => _channel.invokeMethod('closeConnection');

  ///unbind(BluetoothDevice device)
  Future<dynamic> unbind() => _channel.invokeMethod('unbind');

  ///isAvailable(BluetoothDevice device)
  Future<dynamic> isAvailable() => _channel.invokeMethod('isAvailable');

  ///disconnect(BluetoothDevice device)
  Future<dynamic> disconnect() => _channel.invokeMethod('disconnect');

  ///launch(BluetoothDevice device)
  Future<dynamic> launch() => _channel.invokeMethod('launch');

  ///check apakah device sudah di pair
  Future<dynamic> checkIsPaired() => _channel.invokeMethod('isPaired');

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
  Future<dynamic> customDials(
      {required Uint8List bgPreviewBytes,
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
      int? digiDateLeft,
      int? digiDateTop,
      required bool isColor,
      required Color pickedColor,
      required int pointerModel,
      required int pointerNumberModel,
      required Map<String, Uint8List> assets}) {
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
      'digiTop': digiTop ?? screenHeight ~/ 3,
      'digiDateLeft': digiDateLeft ?? screenWidth ~/ 3.5,
      'digiDateTop': digiDateTop ?? screenHeight ~/ 3 + 70,
      'isColor': isColor,
      'pickedColor': {
        "red": pickedColor.red,
        "green": pickedColor.green,
        "blue": pickedColor.blue
      },
      'pointerModel': pointerModel,
      'pointerNumberModel': pointerNumberModel,
      'assets': assets
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

  Future<dynamic> kSTEP_GOAL({required SelectedBlekeyFlag flag, int? goal}) =>
      _channel.invokeMethod('STEP_GOAL', {'flag': flag.name, 'goal': goal});

  Future<dynamic> kBACK_LIGHT(
          {required SelectedBlekeyFlag flag, required int times}) =>
      _channel.invokeMethod('BACK_LIGHT', {'flag': flag.name, 'times': times});

  Future<bool> isSupport2DAcceleration() async {
    bool result =
        await _channel.invokeMethod('isSupport2DAcceleration') ?? false;
    return result;
  }

  Future<bool> isTo8565() async {
    bool result = await _channel.invokeMethod('isTo8565') ?? false;
    return result;
  }

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

  Future<dynamic> kNOTIFICATION_REMINDER(
          {required SelectedBlekeyFlag flag,
          required List<Map<String, dynamic>> listApp}) =>
      _channel.invokeMethod(
          'NOTIFICATION_REMINDER', {'flag': flag.name, 'listApp': listApp});

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

  Future<dynamic> kHR_WARNING({
    required SelectedBlekeyFlag flag,
    required int mEnabled,
  }) =>
      _channel.invokeMethod('HR_WARNING', {
        'flag': flag.name,
        'mEnabled': mEnabled,
      });

  Future<dynamic> kUI_PACK_VERSION({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('UI_PACK_VERSION', {'flag': flag.name});

  Future<dynamic> kLANGUAGE_PACK_VERSION({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('LANGUAGE_PACK_VERSION', {'flag': flag.name});

  Future<dynamic> kSLEEP_QUALITY({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('SLEEP_QUALITY', {'flag': flag.name});

  Future<dynamic> kGIRL_CARE({
    required SelectedBlekeyFlag flag,
    required int mEnabled,
    required int mReminderHour,
    required int mReminderMinute,
    required int mMenstruationReminderAdvance,
    required int mOvulationReminderAdvance,
    required int mLatestYear,
    required int mLatestMonth,
    required int mLatestDay,
    required int mMenstruationDuration,
    required int mMenstruationPeriod,
  }) =>
      _channel.invokeMethod('GIRL_CARE', {
        'flag': flag.name,
        'mEnabled': mEnabled,
        'mReminderHour': mReminderHour,
        'mReminderMinute': mReminderMinute,
        'mMenstruationReminderAdvance': mMenstruationReminderAdvance,
        'mOvulationReminderAdvance': mOvulationReminderAdvance,
        'mLatestYear': mLatestYear,
        'mLatestMonth': mLatestMonth,
        'mLatestDay': mLatestDay,
        'mMenstruationDuration': mMenstruationDuration,
        'mMenstruationPeriod': mMenstruationPeriod
      });

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

  Future<dynamic> kAGPS_PREREQUISITE({
    required SelectedBlekeyFlag flag,
    required double mLongitude,
    required double mLatitude,
    required int mAltitude,
  }) =>
      _channel.invokeMethod('AGPS_PREREQUISITE', {
        'flag': flag.name,
        'mLongitude': mLongitude,
        'mLatitude': mLatitude,
        'mAltitude': mAltitude,
      });

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

  ///musicNext()
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
    required String type,
  }) =>
      _channel.invokeMethod('WEATHER_REALTIME',
          {'flag': flag.name, 'realTime': realTime, 'type': type});

  Future<dynamic> kWEATHER_FORECAST(
          {required SelectedBlekeyFlag flag,
          required String forecast1,
          required String forecast2,
          required String forecast3,
          required String forecast4,
          required String forecast5,
          required String forecast6,
          required String forecast7,
          required String type}) =>
      _channel.invokeMethod('WEATHER_FORECAST', {
        'flag': flag.name,
        'forecast1': forecast1,
        'forecast2': forecast2,
        'forecast3': forecast3,
        'forecast4': forecast4,
        'forecast5': forecast5,
        'forecast6': forecast6,
        'forecast7': forecast7,
        'type': type,
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

  Future<dynamic> kGPS_FIRMWARE_FILE(
          {required SelectedBlekeyFlag flag, String? path, String? url}) =>
      _channel.invokeMethod(
          'GPS_FIRMWARE_FILE', {'flag': flag.name, 'path': path, 'url': url});

  Future<dynamic> kFONT_FILE(
          {required SelectedBlekeyFlag flag, String? path, String? url}) =>
      _channel.invokeMethod(
          'FONT_FILE', {'flag': flag.name, 'path': path, 'url': url});

  Future<dynamic> kCONTACT(
          {required SelectedBlekeyFlag flag,
          required List<Map<String, String>> listContact}) =>
      _channel.invokeMethod(
          'CONTACT', {'flag': flag.name, 'listContact': listContact});

  Future<dynamic> kUI_FILE(
          {required SelectedBlekeyFlag flag, String? path, String? url}) =>
      _channel.invokeMethod(
          'UI_FILE', {'flag': flag.name, 'path': path, 'url': url});

  Future<dynamic> kDEVICE_FILE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('DEVICE_FILE', {'flag': flag.name});

  Future<dynamic> kLANGUAGE_FILE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('LANGUAGE_FILE', {'flag': flag.name});

  Future<dynamic> kBRAND_INFO_FILE({required SelectedBlekeyFlag flag}) =>
      _channel.invokeMethod('BRAND_INFO_FILE', {'flag': flag.name});

  Future<dynamic> kQIBLA_SET({
    required SelectedBlekeyFlag flag,
    required int mEnabled,
    required int mReminderMinute,
    required int mStartTime,
    required int mHijriYear,
    required int mHijriMonth,
    required int mHijriDay,
    required List<PrayerTime> mPrayerTimes,
  }) =>
      _channel.invokeMethod('QIBLA_SET', {
        'flag': flag.name,
        'mEnabled': mEnabled,
        'mReminderMinute': mReminderMinute,
        'mStartTime': mStartTime,
        'mHijriYear': mHijriYear,
        'mHijriMonth': mHijriMonth,
        'mHijriDay': mHijriDay,
        'mPrayerTimes': mPrayerTimes.map((e) => e.toMap()).toList(),
      });

  static const EventChannel _scanChannel = EventChannel('smartble_sdk/scan');

  static Stream<dynamic> get getDeviceListStream {
    return _scanChannel.receiveBroadcastStream(_scanChannel.name).cast();
  }

  static const EventChannel _onDeviceConnectedChannel =
      EventChannel('onDeviceConnected');

  static Stream<dynamic> get onDeviceConnectedStream {
    return _onDeviceConnectedChannel
        .receiveBroadcastStream(_onDeviceConnectedChannel.name)
        .cast();
  }

  static const EventChannel _onIdentityCreateChannel =
      EventChannel('onIdentityCreate');

  static Stream<dynamic> get onIdentityCreateStream {
    return _onIdentityCreateChannel
        .receiveBroadcastStream(_onIdentityCreateChannel.name)
        .cast();
  }

  static const EventChannel _onCommandReplyChannel =
      EventChannel('onCommandReply');

  static Stream<dynamic> get onCommandReplyStream {
    return _onCommandReplyChannel
        .receiveBroadcastStream(_onCommandReplyChannel.name)
        .cast();
  }

  static const EventChannel _onOTAChannel = EventChannel('onOTA');

  static Stream<dynamic> get onOTAStream {
    return _onOTAChannel.receiveBroadcastStream(_onOTAChannel.name).cast();
  }

  static const EventChannel _onReadPowerChannel = EventChannel('onReadPower');

  static Stream<dynamic> get onReadPowerStream {
    return _onReadPowerChannel
        .receiveBroadcastStream(_onReadPowerChannel.name)
        .cast();
  }

  static const EventChannel _onReadFirmwareVersionChannel =
      EventChannel('onReadFirmwareVersion');

  static Stream<dynamic> get onReadFirmwareVersionStream {
    return _onReadFirmwareVersionChannel
        .receiveBroadcastStream(_onReadFirmwareVersionChannel.name)
        .cast();
  }

  static const EventChannel _onReadBleAddressChannel =
      EventChannel('onReadBleAddress');

  static Stream<dynamic> get onReadBleAddressStream {
    return _onReadBleAddressChannel
        .receiveBroadcastStream(_onReadBleAddressChannel.name)
        .cast();
  }

  static const EventChannel _onReadSedentarinessChannel =
      EventChannel('onReadSedentariness');

  static Stream<dynamic> get onReadSedentarinessStream {
    return _onReadSedentarinessChannel
        .receiveBroadcastStream(_onReadSedentarinessChannel.name)
        .cast();
  }

  static const EventChannel _onReadNoDisturbChannel =
      EventChannel('onReadNoDisturb');

  static Stream<dynamic> get onReadNoDisturbStream {
    return _onReadNoDisturbChannel
        .receiveBroadcastStream(_onReadNoDisturbChannel.name)
        .cast();
  }

  static const EventChannel _onReadAlarmChannel = EventChannel('onReadAlarm');

  static Stream<dynamic> get onReadAlarmStream {
    return _onReadAlarmChannel
        .receiveBroadcastStream(_onReadAlarmChannel.name)
        .cast();
  }

  static const EventChannel _onReadCoachingIdsChannel =
      EventChannel('onReadCoachingIds');

  static Stream<dynamic> get onReadCoachingIdsStream {
    return _onReadCoachingIdsChannel
        .receiveBroadcastStream(_onReadCoachingIdsChannel.name)
        .cast();
  }

  static const EventChannel _onReadUiPackVersionChannel =
      EventChannel('onReadUiPackVersion');

  static Stream<dynamic> get onReadUiPackVersionStream {
    return _onReadUiPackVersionChannel
        .receiveBroadcastStream(_onReadUiPackVersionChannel.name)
        .cast();
  }

  static const EventChannel _onReadLanguagePackVersionChannel =
      EventChannel('onReadLanguagePackVersion');

  static Stream<dynamic> get onReadLanguagePackVersionStream {
    return _onReadLanguagePackVersionChannel
        .receiveBroadcastStream(_onReadLanguagePackVersionChannel.name)
        .cast();
  }

  static const EventChannel _onIdentityDeleteByDeviceChannel =
      EventChannel('onIdentityDeleteByDevice');

  static Stream<dynamic> get onIdentityDeleteByDeviceStream {
    return _onIdentityDeleteByDeviceChannel
        .receiveBroadcastStream(_onIdentityDeleteByDeviceChannel.name)
        .cast();
  }

  static const EventChannel _onCameraStateChangeChannel =
      EventChannel('onCameraStateChange');

  static Stream<dynamic> get onCameraStateChangeStream {
    return _onCameraStateChangeChannel
        .receiveBroadcastStream(_onCameraStateChangeChannel.name)
        .cast();
  }

  static const EventChannel _onCameraResponseChannel =
      EventChannel('onCameraResponse');

  static Stream<dynamic> get onCameraResponseStream {
    return _onCameraResponseChannel
        .receiveBroadcastStream(_onCameraResponseChannel.name)
        .cast();
  }

  static const EventChannel _onSyncDataChannel = EventChannel('onSyncData');

  static Stream<dynamic> get onSyncDataStream {
    return _onSyncDataChannel
        .receiveBroadcastStream(_onSyncDataChannel.name)
        .cast();
  }

  static const EventChannel _onReadActivityChannel =
      EventChannel('onReadActivity');

  static Stream<dynamic> get onReadActivityStream {
    return _onReadActivityChannel
        .receiveBroadcastStream(_onReadActivityChannel.name)
        .cast();
  }

  static const EventChannel _onReadHeartRateChannel =
      EventChannel('onReadHeartRate');

  static Stream<dynamic> get onReadHeartRateStream {
    return _onReadHeartRateChannel
        .receiveBroadcastStream(_onReadHeartRateChannel.name)
        .cast();
  }

  static const EventChannel _onUpdateHeartRateChannel =
      EventChannel('onUpdateHeartRate');

  static Stream<dynamic> get onUpdateHeartRateStream {
    return _onUpdateHeartRateChannel
        .receiveBroadcastStream(_onUpdateHeartRateChannel.name)
        .cast();
  }

  static const EventChannel _onReadBloodPressureChannel =
      EventChannel('onReadBloodPressure');

  static Stream<dynamic> get onReadBloodPressureStream {
    return _onReadBloodPressureChannel
        .receiveBroadcastStream(_onReadBloodPressureChannel.name)
        .cast();
  }

  static const EventChannel _onReadSleepChannel = EventChannel('onReadSleep');

  static Stream<dynamic> get onReadSleepStream {
    return _onReadSleepChannel
        .receiveBroadcastStream(_onReadSleepChannel.name)
        .cast();
  }

  static const EventChannel _onReadLocationChannel =
      EventChannel('onReadLocation');

  static Stream<dynamic> get onReadLocationStream {
    return _onReadLocationChannel
        .receiveBroadcastStream(_onReadLocationChannel.name)
        .cast();
  }

  static const EventChannel _onReadTemperatureChannel =
      EventChannel('onReadTemperature');

  static Stream<dynamic> get onReadTemperatureStream {
    return _onReadTemperatureChannel
        .receiveBroadcastStream(_onReadTemperatureChannel.name)
        .cast();
  }

  static const EventChannel _onReadWorkout2Channel =
      EventChannel('onReadWorkout2');

  static Stream<dynamic> get onReadWorkout2Stream {
    return _onReadWorkout2Channel
        .receiveBroadcastStream(_onReadWorkout2Channel.name)
        .cast();
  }

  static const EventChannel _onStreamProgressChannel =
      EventChannel('onStreamProgress');

  static Stream<dynamic> get onStreamProgressStream {
    return _onStreamProgressChannel
        .receiveBroadcastStream(_onStreamProgressChannel.name)
        .cast();
  }

  static const EventChannel _onUpdateAppSportStateChannel =
      EventChannel('onUpdateAppSportState');

  static Stream<dynamic> get onUpdateAppSportStateStream {
    return _onUpdateAppSportStateChannel
        .receiveBroadcastStream(_onUpdateAppSportStateChannel.name)
        .cast();
  }

  static const EventChannel _onClassicBluetoothStateChangeChannel =
      EventChannel('onClassicBluetoothStateChange');

  static Stream<dynamic> get onClassicBluetoothStateChangeStream {
    return _onClassicBluetoothStateChangeChannel
        .receiveBroadcastStream(_onClassicBluetoothStateChangeChannel.name)
        .cast();
  }

  static const EventChannel _onDeviceFileUpdateChannel =
      EventChannel('onDeviceFileUpdate');

  static Stream<dynamic> get onDeviceFileUpdateStream {
    return _onDeviceFileUpdateChannel
        .receiveBroadcastStream(_onDeviceFileUpdateChannel.name)
        .cast();
  }

  static const EventChannel _onReadDeviceFileChannel =
      EventChannel('onReadDeviceFile');

  static Stream<dynamic> get onReadDeviceFileStream {
    return _onReadDeviceFileChannel
        .receiveBroadcastStream(_onReadDeviceFileChannel.name)
        .cast();
  }

  static const EventChannel _onReadTemperatureUnitChannel =
      EventChannel('onReadTemperatureUnit');

  static Stream<dynamic> get onReadTemperatureUnitStream {
    return _onReadTemperatureUnitChannel
        .receiveBroadcastStream(_onReadTemperatureUnitChannel.name)
        .cast();
  }

  static const EventChannel _onReadDateFormatChannel =
      EventChannel('onReadDateFormat');

  static Stream<dynamic> get onReadDateFormatStream {
    return _onReadDateFormatChannel
        .receiveBroadcastStream(_onReadDateFormatChannel.name)
        .cast();
  }

  static const EventChannel _onReadWatchFaceSwitchChannel =
      EventChannel('onReadWatchFaceSwitch');

  static Stream<dynamic> get onReadWatchFaceSwitchStream {
    return _onReadWatchFaceSwitchChannel
        .receiveBroadcastStream(_onReadWatchFaceSwitchChannel.name)
        .cast();
  }

  static const EventChannel _onUpdateWatchFaceSwitchChannel =
      EventChannel('onUpdateWatchFaceSwitch');

  static Stream<dynamic> get onUpdateWatchFaceSwitchStream {
    return _onUpdateWatchFaceSwitchChannel
        .receiveBroadcastStream(_onUpdateWatchFaceSwitchChannel.name)
        .cast();
  }

  static const EventChannel _onAppSportDataResponseChannel =
      EventChannel('onAppSportDataResponse');

  static Stream<dynamic> get onAppSportDataResponseStream {
    return _onAppSportDataResponseChannel
        .receiveBroadcastStream(_onAppSportDataResponseChannel.name)
        .cast();
  }

  static const EventChannel _onReadWatchFaceIdChannel =
      EventChannel('onReadWatchFaceId');

  static Stream<dynamic> get onReadWatchFaceIdStream {
    return _onReadWatchFaceIdChannel
        .receiveBroadcastStream(_onReadWatchFaceIdChannel.name)
        .cast();
  }

  static const EventChannel _onWatchFaceIdUpdateChannel =
      EventChannel('onWatchFaceIdUpdate');

  static Stream<dynamic> get onWatchFaceIdUpdateStream {
    return _onWatchFaceIdUpdateChannel
        .receiveBroadcastStream(_onWatchFaceIdUpdateChannel.name)
        .cast();
  }

  static const EventChannel _onHIDStateChannel = EventChannel('onHIDState');

  static Stream<dynamic> get onHIDStateStream {
    return _onHIDStateChannel
        .receiveBroadcastStream(_onHIDStateChannel.name)
        .cast();
  }

  static const EventChannel _onHIDValueChangeChannel =
      EventChannel('onHIDValueChange');

  static Stream<dynamic> get onHIDValueChangeStream {
    return _onHIDValueChangeChannel
        .receiveBroadcastStream(_onHIDValueChangeChannel.name)
        .cast();
  }

  static const EventChannel _onDeviceSMSQuickReplyChannel =
      EventChannel('onDeviceSMSQuickReply');

  static Stream<dynamic> get onDeviceSMSQuickReplyStream {
    return _onDeviceSMSQuickReplyChannel
        .receiveBroadcastStream(_onDeviceSMSQuickReplyChannel.name)
        .cast();
  }

  static const EventChannel _onReadDeviceInfoChannel =
      EventChannel('onReadDeviceInfo');

  static Stream<dynamic> get onReadDeviceInfoStream {
    return _onReadDeviceInfoChannel
        .receiveBroadcastStream(_onReadDeviceInfoChannel.name)
        .cast();
  }

  static const EventChannel _onSessionStateChangeChannel =
      EventChannel('onSessionStateChange');

  static Stream<dynamic> get onSessionStateChangeStream {
    return _onSessionStateChangeChannel
        .receiveBroadcastStream(_onSessionStateChangeChannel.name)
        .cast();
  }

  static const EventChannel _onNoDisturbUpdateChannel =
      EventChannel('onNoDisturbUpdate');

  static Stream<dynamic> get onNoDisturbUpdateStream {
    return _onNoDisturbUpdateChannel
        .receiveBroadcastStream(_onNoDisturbUpdateChannel.name)
        .cast();
  }

  static const EventChannel _onAlarmUpdateChannel =
      EventChannel('onAlarmUpdate');

  static Stream<dynamic> get onAlarmUpdateStream {
    return _onAlarmUpdateChannel
        .receiveBroadcastStream(_onAlarmUpdateChannel.name)
        .cast();
  }

  static const EventChannel _onAlarmDeleteChannel =
      EventChannel('onAlarmDelete');

  static Stream<dynamic> get onAlarmDeleteStream {
    return _onAlarmDeleteChannel
        .receiveBroadcastStream(_onAlarmDeleteChannel.name)
        .cast();
  }

  static const EventChannel _onAlarmAddChannel = EventChannel('onAlarmAdd');

  static Stream<dynamic> get onAlarmAddStream {
    return _onAlarmAddChannel
        .receiveBroadcastStream(_onAlarmAddChannel.name)
        .cast();
  }

  static const EventChannel _onFindPhoneChannel = EventChannel('onFindPhone');

  static Stream<dynamic> get onFindPhoneStream {
    return _onFindPhoneChannel
        .receiveBroadcastStream(_onFindPhoneChannel.name)
        .cast();
  }

  static const EventChannel _onRequestLocationChannel =
      EventChannel('onRequestLocation');

  static Stream<dynamic> get onRequestLocationStream {
    return _onRequestLocationChannel
        .receiveBroadcastStream(_onRequestLocationChannel.name)
        .cast();
  }

  static const EventChannel _onDeviceRequestAGpsFileChannel =
      EventChannel('onDeviceRequestAGpsFile');

  static Stream<dynamic> get onDeviceRequestAGpsFileStream {
    return _onDeviceRequestAGpsFileChannel
        .receiveBroadcastStream(_onDeviceRequestAGpsFileChannel.name)
        .cast();
  }

  static const EventChannel _onReadWorkoutChannel =
      EventChannel('onReadWorkout');

  static Stream<dynamic> get onReadWorkoutStream {
    return _onReadWorkoutChannel
        .receiveBroadcastStream(_onReadWorkoutChannel.name)
        .cast();
  }

  static const EventChannel _onReadBloodOxygenChannel =
      EventChannel('onReadBloodOxygen');

  static Stream<dynamic> get onReadBloodOxygenStream {
    return _onReadBloodOxygenChannel
        .receiveBroadcastStream(_onReadBloodOxygenChannel.name)
        .cast();
  }

  static const EventChannel _onReadBleHrvChannel = EventChannel('onReadBleHrv');

  static Stream<dynamic> get onReadBleHrvStream {
    return _onReadBleHrvChannel
        .receiveBroadcastStream(_onReadBleHrvChannel.name)
        .cast();
  }

  static const EventChannel _onReadPressureChannel =
      EventChannel('onReadPressure');

  static Stream<dynamic> get onReadPressureStream {
    return _onReadPressureChannel
        .receiveBroadcastStream(_onReadPressureChannel.name)
        .cast();
  }

  static const EventChannel _onDeviceConnectingChannel =
      EventChannel('onDeviceConnecting');

  static Stream<dynamic> get onDeviceConnectingStream {
    return _onDeviceConnectingChannel
        .receiveBroadcastStream(_onDeviceConnectingChannel.name)
        .cast();
  }

  static const EventChannel _onIncomingCallStatusChannel =
      EventChannel('onIncomingCallStatus');

  static Stream<dynamic> get onIncomingCallStatusStream {
    return _onIncomingCallStatusChannel
        .receiveBroadcastStream(_onIncomingCallStatusChannel.name)
        .cast();
  }

  static const EventChannel _onReceiveMusicCommandChannel =
      EventChannel("onReceiveMusicCommand");

  static Stream<dynamic> get onReceiveMusicCommandStream {
    return _onReceiveMusicCommandChannel
        .receiveBroadcastStream(_onReceiveMusicCommandChannel.name)
        .cast();
  }

  static const EventChannel _onReadWorldClockChannel =
      EventChannel("onReadWorldClock");

  static Stream<dynamic> get onReadWorldClockStream {
    return _onReadWorldClockChannel
        .receiveBroadcastStream(_onReadWorldClockChannel.name)
        .cast();
  }

  static const EventChannel _onWorldClockDeleteChannel =
      EventChannel("onWorldClockDelete");

  static Stream<dynamic> get onWorldClockDeleteStream {
    return _onWorldClockDeleteChannel
        .receiveBroadcastStream(_onWorldClockDeleteChannel.name)
        .cast();
  }

  static const EventChannel _onStockReadChannel = EventChannel("onStockRead");

  static Stream<dynamic> get onStockReadStream {
    return _onStockReadChannel
        .receiveBroadcastStream(_onStockReadChannel.name)
        .cast();
  }

  static const EventChannel _onStockDeleteChannel =
      EventChannel("onStockDelete");

  static Stream<dynamic> get onStockDeleteStream {
    return _onStockDeleteChannel
        .receiveBroadcastStream(_onStockDeleteChannel.name)
        .cast();
  }

  static const EventChannel _onBleErrorChannel = EventChannel("onBleError");

  static Stream<dynamic> get onBleErrorStream {
    return _onBleErrorChannel
        .receiveBroadcastStream(_onBleErrorChannel.name)
        .cast();
  }

  static const EventChannel _onBluetoothPairingStatus =
      EventChannel("onBluetoothPairingStatus");

  static Stream<dynamic> get onBluetoothPairingStatus {
    return _onBluetoothPairingStatus
        .receiveBroadcastStream(_onBluetoothPairingStatus.name)
        .cast();
  }

  static const EventChannel _onReadGpsFirmwareVersion =
      EventChannel("onReadGpsFirmwareVersion");

  static Stream<dynamic> get onReadGpsFirmwareVersion {
    return _onReadGpsFirmwareVersion
        .receiveBroadcastStream(_onReadGpsFirmwareVersion.name)
        .cast();
  }

  static const EventChannel _onReadQiblaSettings =
      EventChannel("onReadQiblaSettings");

  static Stream<dynamic> get onReadQiblaSettings {
    return _onReadQiblaSettings
        .receiveBroadcastStream(_onReadQiblaSettings.name)
        .cast();
  }
}
