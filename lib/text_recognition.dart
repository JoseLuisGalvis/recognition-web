import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'global_key.dart';

class TextRecognition {
  Future<void> recognizeText() async {
    final ImagePicker _picker = ImagePicker();

    // Aquí puedes permitir al usuario seleccionar entre la cámara y la galería
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      String result = '';

      if (kIsWeb) {
        result = await _webTextRecognition(image);
      } else if (Platform.isWindows) {
        result = await _windowsTextRecognition(image);
      } else {
        result = await _mobileTextRecognition(image);
      }

      // Mostrar el texto reconocido en un cuadro de diálogo
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          title: Text('Texto Reconocido'),
          content: Text(result),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  Future<String> _webTextRecognition(XFile image) async {
    // Implementación futura para la web
    return 'Reconocimiento de texto en web (no implementado)';
  }

  Future<String> _windowsTextRecognition(XFile image) async {
    // Implementación futura para Windows
    return 'Reconocimiento de texto en Windows (no implementado)';
  }

  Future<String> _mobileTextRecognition(XFile image) async {
    // Aquí usamos Google ML Kit para el reconocimiento de texto en móviles
    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    String result = '';

    // Recorremos los bloques de texto detectados
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        result += line.text + '\n';  // Añadimos el texto reconocido línea por línea
      }
    }

    // Liberar el recognizer
    textRecognizer.close();

    return result.isNotEmpty ? result : 'No se ha reconocido texto en la imagen.';
  }
}

