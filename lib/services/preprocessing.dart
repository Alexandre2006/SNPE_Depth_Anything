import 'dart:typed_data';
import 'package:image/image.dart' as img;

// Convert YUV420 to RGB
(ByteBuffer, ByteBuffer, ByteBuffer) yuv420ToRGB(
    ByteBuffer y, ByteBuffer u, ByteBuffer v) {
  Uint8List yList = y.asUint8List();
  Uint8List uList = u.asUint8List();
  Uint8List vList = v.asUint8List();

  int length = yList.length;
  Uint8List rList = Uint8List(length);
  Uint8List gList = Uint8List(length);
  Uint8List bList = Uint8List(length);

  for (int i = 0; i < length; i++) {
    int yValue = yList[i];
    int uvIndex = (i ~/ 4); // U and V are subsampled by 2 in both dimensions
    int uValue = uList[uvIndex];
    int vValue = vList[uvIndex];

    int rValue = (yValue + 1.402 * (vValue - 128)).toInt();
    int gValue =
        (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128))
            .toInt();
    int bValue = (yValue + 1.772 * (uValue - 128)).toInt();

    rList[i] = rValue.clamp(0, 255);
    gList[i] = gValue.clamp(0, 255);
    bList[i] = bValue.clamp(0, 255);
  }

  return (rList.buffer, gList.buffer, bList.buffer);
}

// Convert RGB to Bitmap
img.Image rgbToBitmap(
    ByteBuffer r, ByteBuffer g, ByteBuffer b, int width, int height) {
  Uint8List rList = r.asUint8List();
  Uint8List gList = g.asUint8List();
  Uint8List bList = b.asUint8List();

  int length = rList.length;
  img.Image bitmap = img.Image(width: width, height: height);

  for (int i = 0; i < length; i++) {
    int x = i % 640;
    int y = i ~/ 640;

    bitmap.setPixelRgb(x, y, rList[i], gList[i], bList[i]);
  }

  return bitmap;
}

// Resize Bitmap
img.Image resizeBitmap(img.Image bitmap, int width, int height) {
  return img.copyResize(bitmap, width: width, height: height);
}

// Convert bitmap to rgb channels
(ByteBuffer, ByteBuffer, ByteBuffer) bitmapToRGB(img.Image bitmap) {
  int length = bitmap.width * bitmap.height;
  Uint8List rList = Uint8List(length);
  Uint8List gList = Uint8List(length);
  Uint8List bList = Uint8List(length);

  for (int i = 0; i < length; i++) {
    rList[i] = bitmap.getPixel(i % bitmap.width, i ~/ bitmap.width).r.toInt();
    gList[i] = bitmap.getPixel(i % bitmap.width, i ~/ bitmap.width).g.toInt();
    bList[i] = bitmap.getPixel(i % bitmap.width, i ~/ bitmap.width).b.toInt();
  }

  return (rList.buffer, gList.buffer, bList.buffer);
}

// Convert black and white channel to bitmap
img.Image bwToBitmap(ByteBuffer bw, int width, int height) {
  Uint8List bwList = bw.asUint8List();
  int length = bwList.length;
  img.Image bitmap = img.Image(width: width, height: height);

  for (int i = 0; i < length; i++) {
    int x = i % 640;
    int y = i ~/ 640;

    bitmap.setPixelRgb(x, y, bwList[i], bwList[i], bwList[i]);
  }

  return bitmap;
}
