import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;
import 'package:smartble_sdk/smartble_sdk.dart';

class DigitalDial {
  String dialCustomizeDir = "";
  String digitalAmDir = "am_pm";
  String digitalDateDir = "date";
  String digitalHourMinuteDir = "hour_minute";
  String digitalWeekDir = "week";
  String fileFormat = "";
  String digitalValueColor = "0";
  //time
  String timeDir = "";
  //digital
  String digitalDir = "";
  bool isSupport2DAcceleration = false;
  bool isTo8565 = false;
  SmartbleSdk ble = SmartbleSdk();

  void init(int custom) async {
    isSupport2DAcceleration = await ble.isSupport2DAcceleration();
    isTo8565 = await ble.isTo8565();
    fileFormat = (isSupport2DAcceleration || isTo8565) ? "png" : "bmp";
    if (custom == 2) {
      dialCustomizeDir = "dial_customize_454";
    } else if (custom == 3) {
      dialCustomizeDir = "dial_customize_240";
    } else {
      dialCustomizeDir = "dial_customize_240";
    }
    //time
    timeDir = "$dialCustomizeDir/time";
    //digital
    digitalDir = "$timeDir/digital";
  }

  Future<Map<String, Uint8List>> processAssets(Color toColor) async {
    Map<String, Uint8List> result = {};
    final amDir = "$digitalDir/$digitalValueColor/$digitalAmDir/am.$fileFormat";
    result[amDir] = (await changeColor(amDir, toColor))!;

    final pmDir = "$digitalDir/$digitalValueColor/$digitalAmDir/pm.$fileFormat";
    result[pmDir] = (await changeColor(pmDir, toColor))!;

    final hourMinuteDirInit =
        "$digitalDir/$digitalValueColor/$digitalHourMinuteDir/";
    for (var i = 0; i <= 9; i++) {
      final filename = "$hourMinuteDirInit$i.$fileFormat";
      result[filename] = (await changeColor(filename, toColor))!;
    }

    final dateDirInit = "$digitalDir/$digitalValueColor/$digitalDateDir/";
    for (var i = 0; i <= 9; i++) {
      final filename = "$dateDirInit$i.$fileFormat";
      result[filename] = (await changeColor(filename, toColor))!;
    }

    final weekDirInit = "$digitalDir/$digitalValueColor/$digitalWeekDir/";
    for (var i = 0; i <= 6; i++) {
      final filename = "$weekDirInit$i.$fileFormat";
      result[filename] = (await changeColor(filename, toColor))!;
    }

    final divHourDir =
        "$digitalDir/$digitalValueColor/$digitalHourMinuteDir/symbol.$fileFormat";

    result[divHourDir] = (await changeColor(divHourDir, toColor))!;

    final divDateDir =
        "$digitalDir/$digitalValueColor/$digitalDateDir/symbol.$fileFormat";

    result[divDateDir] = (await changeColor(divDateDir, toColor))!;

    return result;
  }

  Future<img.Image?> decodeAsset(String path) async {
    final data = await rootBundle.load("assets/$path");

    final buffer =
        await ui.ImmutableBuffer.fromUint8List(data.buffer.asUint8List());

    final id = await ui.ImageDescriptor.encoded(buffer);
    final codec = await id.instantiateCodec(
        targetHeight: id.height, targetWidth: id.width);

    final fi = await codec.getNextFrame();

    final uiImage = fi.image;
    final uiBytes = await uiImage.toByteData();

    final image = img.Image.fromBytes(
        width: id.width,
        height: id.height,
        bytes: uiBytes!.buffer,
        numChannels: 4);

    return image;
  }

  Future<Uint8List?> changeColor(String assets, Color toColor) async {
    final image = await decodeAsset(assets);
    if (image != null) {
      for (var pixel in image) {
        if (pixel.r > 150) {
          pixel.r = toColor.red;
        }
        if (pixel.g > 150) {
          pixel.g = toColor.green;
        }
        if (pixel.b > 150) {
          pixel.b = toColor.blue;
        }
      }
      return Uint8List.fromList((isSupport2DAcceleration || isTo8565)
          ? img.encodePng(image)
          : img.encodeBmp(image));
    }
    return null;
  }
}
