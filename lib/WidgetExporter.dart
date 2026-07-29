import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Exports a widget from the given [GlobalKey] to an image file.
class WidgetExporter {
  /// Extracts the `Uint8List` byte data from the widget with the given [key].
  /// You can specify either [exportWidthValue] or [exportHeightValue] to control the pixel ratio.
  static Future<Uint8List?> getExportImageBytes(
    GlobalKey<State<StatefulWidget>> key, {
    int? exportWidthValue,
    int? exportHeightValue,
  }) async {
    if (key.currentContext == null) {
      throw Exception(
        "Failed to export: render object not found. Ensure widget is mounted and key is valid.",
      );
    }
    RenderObject? renderObject = key.currentContext!.findRenderObject();
    if (renderObject == null ||
        renderObject is! RenderBox ||
        renderObject is! RenderRepaintBoundary) {
      throw Exception("Failed to export: invalid render object type.");
    }

    RenderBox findRenderObject = renderObject as RenderBox;
    RenderRepaintBoundary boundary = renderObject;

    double pixelRatio = 1.0;
    if (exportWidthValue != null) {
      pixelRatio = exportWidthValue / findRenderObject.size.width;
    } else if (exportHeightValue != null) {
      pixelRatio = exportHeightValue / findRenderObject.size.height;
    }

    ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception("Failed to export: unable to generate image bytes.");
    }
    return byteData.buffer.asUint8List();
  }

  /// Prompts the user for a save path and saves the image bytes.
  static Future<String?> getExportPath({
    required String dialogTitle,
    required String fileName,
    Uint8List? imageBytes,
  }) async {
    String? path = await FilePicker.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      type: FileType.image,
      bytes: imageBytes,
      allowedExtensions: ["PNG"],
      lockParentWindow: true,
    );
    return path;
  }

  /// High level utility method to handle the full export flow.
  /// Uses callbacks [onSuccess] and [onError] to decouple from UI.
  static Future<void> exportImage({
    required GlobalKey key,
    required String fileName,
    required bool isBatchExport,
    int? exportWidthValue,
    int? exportHeightValue,
    void Function(String path)? onSuccess,
    void Function(String errorMessage)? onError,
  }) async {
    try {
      Uint8List? imageBytes = await getExportImageBytes(
        key,
        exportWidthValue: exportWidthValue,
        exportHeightValue: exportHeightValue,
      );

      if (imageBytes == null) {
        onError?.call("Image data is null.");
        return;
      }

      String? path;
      if (isBatchExport) {
        path = fileName;
        File imgFile = File(fileName);
        await imgFile.writeAsBytes(imageBytes);
      } else {
        path = await getExportPath(
          dialogTitle: "Save",
          fileName: fileName,
          imageBytes: Platform.isAndroid ? imageBytes : null,
        );

        if (path == null) {
          // User canceled
          return;
        }

        if (!Platform.isAndroid) {
          File imgFile = File(path);
          await imgFile.writeAsBytes(imageBytes);
        }
      }

      onSuccess?.call(path);
    } catch (e) {
      onError?.call(e.toString());
    }
  }
}
