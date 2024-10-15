import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:js/js_util.dart' as js_util;

class FacialRecognitionWeb {
  Future<void> detectFaces(BuildContext context) async {
    try {
      print('Iniciando captura de imagen...');
      final image = await webCaptureImage();
      if (image != null) {
        print('Imagen capturada. Mostrando para confirmación...');
        bool? shouldProceed = await showConfirmationDialog(context, image);
        if (shouldProceed == true) {
          print('Confirmación recibida. Procediendo con la detección...');
          String result = await webFaceDetection(image);
          print('Detección completada. Mostrando resultados...');
          showResultDialog(context, result);
        } else {
          print('Detección cancelada por el usuario.');
        }
      } else {
        print('No se capturó ninguna imagen.');
        showResultDialog(context, 'No se capturó ninguna imagen.');
      }
    } catch (e) {
      print('Error en detectFaces: $e');
      showResultDialog(context, 'Error en la detección facial: $e');
    }
  }

// Implement webCaptureImage, showConfirmationDialog, webFaceDetection, and showResultDialog methods here
// Use the implementations from your original FacialRecognitionWeb class
  Future<bool?> showConfirmationDialog(BuildContext context, XFile image) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar imagen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(image.path),
            Text('¿Desea proceder con el reconocimiento facial?'),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Proceder'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }

  Future<XFile?> webCaptureImage() async {
    final completer = Completer<XFile?>();
    final videoElement = html.VideoElement()
      ..autoplay = true
      ..style.width = '640px'
      ..style.height = '480px';

    final buttonElement = html.ButtonElement()
      ..text = 'Capturar'
      ..style.position = 'absolute'
      ..style.bottom = '20px'
      ..style.left = '50%'
      ..style.transform = 'translateX(-50%)';

    final containerDiv = html.DivElement()
      ..style.position = 'fixed'
      ..style.top = '0'
      ..style.left = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.backgroundColor = 'rgba(0,0,0,0.8)'
      ..style.display = 'flex'
      ..style.justifyContent = 'center'
      ..style.alignItems = 'center';

    containerDiv.children.addAll([videoElement, buttonElement]);
    html.document.body!.append(containerDiv);

    try {
      final stream = await html.window.navigator.mediaDevices?.getUserMedia({'video': true});
      videoElement.srcObject = stream;

      buttonElement.onClick.listen((_) async {
        try {
          print('Botón Capturar pulsado.');
          final canvasElement = html.CanvasElement(
            width: videoElement.videoWidth,
            height: videoElement.videoHeight,
          );
          canvasElement.context2D.drawImage(videoElement, 0, 0);

          stream?.getTracks().forEach((track) => track.stop());
          containerDiv.remove();

          final blob = await canvasElement.toBlob('image/jpeg');
          final reader = html.FileReader()..readAsArrayBuffer(blob);

          reader.onLoadEnd.listen((_) {
            final result = reader.result as Uint8List;
            final xFile = XFile.fromData(result, mimeType: 'image/jpeg');
            print('Imagen capturada y convertida a XFile.');
            completer.complete(xFile);
          });
        } catch (e) {
          print('Error al capturar la imagen: $e');
          completer.completeError('Error al capturar la imagen: $e');
        }
      });
    } catch (e) {
      print('Error al acceder a la cámara: $e');
      containerDiv.remove();
      completer.completeError('Error al acceder a la cámara: $e');
    }

    return completer.future;
  }

  Future<String> webFaceDetection(XFile image) async {
    try {
      print('Iniciando detección facial en la imagen...');
      final bytes = await image.readAsBytes();
      final base64Image = Uri.dataFromBytes(bytes, mimeType: 'image/jpeg').toString();

      print('Llamando a la función JavaScript detectFacesWithTensorFlowJS...');
      final result = await js_util.promiseToFuture(
          js_util.callMethod(js_util.globalThis, 'detectFacesWithTensorFlowJS', [base64Image])
      );

      print('Detección facial completada. Resultado: $result');
      return result as String;
    } catch (e) {
      print('Error en webFaceDetection: $e');
      return 'Error en la detección facial: $e';
    }
  }

  void showResultDialog(BuildContext context, String result) {
    print('Mostrando diálogo de resultado...');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resultado de Detección Facial'),
        content: SingleChildScrollView(
          child: Text(result),
        ),
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







