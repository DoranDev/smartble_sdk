import 'dart:typed_data';

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
  bool is2D = true;
  SmartbleSdk ble = SmartbleSdk();

  void init(int custom) async {
    isSupport2DAcceleration = await ble.isSupport2DAcceleration();
    isTo8565 = await ble.isTo8565();
    fileFormat = (isSupport2DAcceleration || isTo8565) ? "png" : "bmp";
    is2D = (isSupport2DAcceleration || isTo8565) ? true : false;
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

  Future<Map<String, Uint8List>> processAssets(
      Color toColor, int idColor) async {
    Map<String, Uint8List> result = {};
    final amDir = "$digitalDir/$digitalValueColor/$digitalAmDir/am.$fileFormat";
    final amDirBmp = "$digitalDir/$idColor/$digitalAmDir/am.$fileFormat";
    result[amDir] = is2D
        ? (await changeColor(amDir, toColor))!
        : (await changeColorBmp(amDirBmp, toColor))!;

    final pmDir = "$digitalDir/$digitalValueColor/$digitalAmDir/pm.$fileFormat";
    final pmDirBmp = "$digitalDir/$idColor/$digitalAmDir/pm.$fileFormat";
    result[pmDir] = is2D
        ? (await changeColor(pmDir, toColor))!
        : (await changeColorBmp(pmDirBmp, toColor))!;

    final hourMinuteDirInit =
        "$digitalDir/$digitalValueColor/$digitalHourMinuteDir/";
    final hourMinuteDirInitBmp = "$digitalDir/$idColor/$digitalHourMinuteDir/";
    for (var i = 0; i <= 9; i++) {
      final filename = "$hourMinuteDirInit$i.$fileFormat";
      result[filename] = is2D
          ? (await changeColor(filename, toColor))!
          : (await changeColorBmp(
              "$hourMinuteDirInitBmp$i.$fileFormat", toColor))!;
    }

    final dateDirInit = "$digitalDir/$digitalValueColor/$digitalDateDir/";
    final dateDirInitBmp = "$digitalDir/$idColor/$digitalDateDir/";
    for (var i = 0; i <= 9; i++) {
      final filename = "$dateDirInit$i.$fileFormat";
      result[filename] = is2D
          ? (await changeColor(filename, toColor))!
          : (await changeColorBmp("$dateDirInitBmp$i.$fileFormat", toColor))!;
    }

    final weekDirInit = "$digitalDir/$digitalValueColor/$digitalWeekDir/";
    final weekDirInitBmp = "$digitalDir/$idColor/$digitalWeekDir/";
    for (var i = 0; i <= 6; i++) {
      final filename = "$weekDirInit$i.$fileFormat";
      result[filename] = is2D
          ? (await changeColor(filename, toColor))!
          : (await changeColorBmp("$weekDirInitBmp$i.$fileFormat", toColor))!;
    }

    final divHourDir =
        "$digitalDir/$digitalValueColor/$digitalHourMinuteDir/symbol.png";

    result[divHourDir] = (await changeColor(divHourDir, toColor))!;

    final divDateDir =
        "$digitalDir/$digitalValueColor/$digitalDateDir/symbol.png";

    result[divDateDir] = (await changeColor(divDateDir, toColor))!;

    return result;
  }

  // Future<Map<String, Uint8List>> processAssets(Color toColor) async {
  //   Map<String, Uint8List> result = {};
  //   final amDir = "$digitalDir/$digitalValueColor/$digitalAmDir/am.$fileFormat";
  //   result[amDir] = is2D
  //       ? (await changeColor(amDir, toColor))!
  //       : (await changeColorBmp(amDir, toColor))!;
  //
  //   final pmDir = "$digitalDir/$digitalValueColor/$digitalAmDir/pm.$fileFormat";
  //   result[pmDir] = is2D
  //       ? (await changeColor(pmDir, toColor))!
  //       : (await changeColorBmp(pmDir, toColor))!;
  //
  //   final hourMinuteDirInit =
  //       "$digitalDir/$digitalValueColor/$digitalHourMinuteDir/";
  //   for (var i = 0; i <= 9; i++) {
  //     final filename = "$hourMinuteDirInit$i.$fileFormat";
  //     result[filename] = is2D
  //         ? (await changeColor(filename, toColor))!
  //         : (await changeColorBmp(filename, toColor))!;
  //   }
  //
  //   final dateDirInit = "$digitalDir/$digitalValueColor/$digitalDateDir/";
  //   for (var i = 0; i <= 9; i++) {
  //     final filename = "$dateDirInit$i.$fileFormat";
  //     result[filename] = is2D
  //         ? (await changeColor(filename, toColor))!
  //         : (await changeColorBmp(filename, toColor))!;
  //   }
  //
  //   final weekDirInit = "$digitalDir/$digitalValueColor/$digitalWeekDir/";
  //   for (var i = 0; i <= 6; i++) {
  //     final filename = "$weekDirInit$i.$fileFormat";
  //     result[filename] = is2D
  //         ? (await changeColor(filename, toColor))!
  //         : (await changeColorBmp(filename, toColor))!;
  //   }
  //
  //   final divHourDir =
  //       "$digitalDir/$digitalValueColor/$digitalHourMinuteDir/symbol.png";
  //
  //   result[divHourDir] = (await changeColor(divHourDir, toColor))!;
  //
  //   final divDateDir =
  //       "$digitalDir/$digitalValueColor/$digitalDateDir/symbol.png";
  //
  //   result[divDateDir] = (await changeColor(divDateDir, toColor))!;
  //
  //   return result;
  // }

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

  // Future<img.Image?> decodeAssetBmp(String path) async {
  //   final data = await rootBundle.load("assets/$path");
  //   final image = img.decodeBmp(data.buffer.asUint8List());
  //   return image;
  // }

  Future<Uint8List?> decodeAssetBmp(String path) async {
    final data = await rootBundle.load("assets/$path");
    return data.buffer.asUint8List();
  }

  // Future<img.Image?> decodeAssetBmp(String path) async {
  //   final data = await rootBundle.load("assets/$path");
  //   final image = img.decodeBmp(data.buffer.asUint8List());
  //   return image;
  // }

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
      return Uint8List.fromList(img.encodePng(image));
    }
    return null;
  }

  Future<Uint8List?> changeColorBmp(String assets, Color toColor) async {
    final image = await decodeAssetBmp(assets);
    return image;
  }

  // Future<Uint8List?> changeColorBmp(String assets, Color toColor) async {
  //   final image = await decodeAssetBmp(assets);
  //   if (image != null) {
  //     for (img.Pixel pixel in image) {
  //       // print("numChannels");
  //       // print(pixel.image.numChannels);
  //       if (pixel.r > 150) {
  //         pixel.r = toColor.red;
  //       }
  //       if (pixel.g > 150) {
  //         pixel.g = toColor.green;
  //       }
  //       if (pixel.b > 150) {
  //         pixel.b = toColor.blue;
  //       }
  //     }
  //     // return Uint8List.fromList(img.encodeBmp(image));
  //     return encodeR5G6B5Pixels(image);
  //   }
  //   return null;
  // }

  // Uint8List encodeR5G6B5Pixels(img.Image image) {
  //   final width = image.width;
  //   final height = image.height;
  //   final pixelData = image.getBytes();
  //
  //   final encodedPixels = Uint8List(width * height * 2); // 2 bytes per pixel
  //   final encodedPixelsUint16 = encodedPixels.buffer.asUint16List();
  //
  //   for (int i = 0; i < width * height; i++) {
  //     final r = pixelData[4 * i]; // Red component
  //     final g = pixelData[4 * i + 1]; // Green component
  //     final b = pixelData[4 * i + 2]; // Blue component
  //
  //     final r5 = (r >> 3) & 0x1F; // Shift right 3 bits, mask for 5 bits
  //     final g6 = (g >> 2) & 0x3F; // Shift right 2 bits, mask for 6 bits
  //     final b5 = b & 0x1F; // Mask for 5 bits
  //
  //     final rgb565 = (r5 << 11) | (g6 << 5) | b5; // Combine into 16-bit value
  //     encodedPixelsUint16[i] = rgb565;
  //   }
  //
  //   return encodedPixels;
  // }

  Uint8List encodeImageTo16BitBmp(img.Image image) {
    const headerSize = 54; // BMP header size
    final imageSize = image.length ~/ 2; // 16-bit image size

    final output = Uint8List(headerSize + imageSize);

    // BMP File Header
    output[0] = 0x42; // 'B'
    output[1] = 0x4D; // 'M'

    // File Size
    output.buffer
        .asByteData()
        .setUint32(2, headerSize + imageSize, Endian.little);

    // Reserved
    output.buffer.asByteData().setUint16(6, 0, Endian.little);
    output.buffer.asByteData().setUint16(8, 0, Endian.little);

    // Offset to image data
    output.buffer.asByteData().setUint32(10, headerSize, Endian.little);

    // DIB Header
    output.buffer
        .asByteData()
        .setUint32(14, 40, Endian.little); // DIB header size
    output.buffer.asByteData().setUint32(18, image.width, Endian.little);
    output.buffer.asByteData().setUint32(22, image.height, Endian.little);
    output.buffer.asByteData().setUint16(26, 1, Endian.little); // Color planes
    output.buffer
        .asByteData()
        .setUint16(28, 16, Endian.little); // Bits per pixel (16-bit)
    output.buffer
        .asByteData()
        .setUint32(30, 0, Endian.little); // Compression method
    output.buffer
        .asByteData()
        .setUint32(34, imageSize, Endian.little); // Image size
    output.buffer.asByteData().setUint32(
        38, 0, Endian.little); // Horizontal resolution (pixels per meter)
    output.buffer.asByteData().setUint32(
        42, 0, Endian.little); // Vertical resolution (pixels per meter)
    output.buffer
        .asByteData()
        .setUint32(46, 0, Endian.little); // Number of colors in the palette
    output.buffer
        .asByteData()
        .setUint32(50, 0, Endian.little); // Number of important colors

    // BMP uses BGRA order, so we need to convert the image to this format
    // final convertedImage = img.copyRotate(image, angle: 180);
    final convertedImage = image;
    // Image Data (16-bit, R5 G6 B5)
    var index = headerSize;
    for (var y = convertedImage.height - 1; y >= 0; y--) {
      for (var x = 0; x < convertedImage.width; x++) {
        final pixel = convertedImage.getPixel(x, y);

        // Pack RGB values into a 16-bit pixel
        final packedPixel = (((pixel.r.toInt() >> 3) & 0x1F) << 11) |
            (((pixel.g.toInt() >> 2) & 0x3F) << 5) |
            ((pixel.b.toInt() >> 3) & 0x1F);

        // Write the 16-bit pixel data (Little Endian order)
        output.buffer.asByteData().setUint16(index, packedPixel, Endian.little);
        index += 2;
      }
    }

    return output;
  }
}
