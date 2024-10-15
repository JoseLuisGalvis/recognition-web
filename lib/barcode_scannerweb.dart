import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:js/js_util.dart' as js_util;

class BarcodeScannerWeb {
  Future<void> detectBarcode(BuildContext context) async {
    try {
      print('Iniciando captura de imagen...');
      final image = await webCaptureImage(); // Captura la imagen de la cámara
      if (image != null) {
        print('Imagen capturada. Mostrando para confirmación...');
        bool? shouldProceed = await showConfirmationDialog(context, image); // Confirmación del usuario
        if (shouldProceed == true) {
          print('Confirmación recibida. Procediendo con la detección...');
          String result = await webBarcodeDetection(image); // Lee el código de barras
          print('Detección completada. Mostrando resultados...');
          showResultDialog(context, result); // Muestra los resultados de la detección
        } else {
          print('Detección cancelada por el usuario.');
        }
      } else {
        print('No se capturó ninguna imagen.');
        showResultDialog(context, 'No se capturó ninguna imagen.');
      }
    } catch (e) {
      print('Error en detectBarcode: $e');
      showResultDialog(context, 'Error en la detección de código de barras: $e');
    }
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

  Future<bool?> showConfirmationDialog(BuildContext context, XFile image) async {
    print('Mostrando diálogo de confirmación...');
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar imagen'),
        content: FutureBuilder<Uint8List>(
          future: image.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              print('Cargando imagen para el diálogo...');
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print('Error al cargar la imagen en el diálogo: ${snapshot.error}');
              return Text('Error al cargar la imagen');
            } else {
              print('Imagen cargada correctamente para el diálogo.');
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.memory(snapshot.data!),
                  Text('¿Desea proceder con la lectura del código de barras?'),
                ],
              );
            }
          },
        ),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () {
              print('Detección cancelada.');
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: Text('Proceder'),
            onPressed: () {
              print('Detección aceptada. Procediendo...');
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );
  }

  Future<String> webBarcodeDetection(XFile image) async {
    try {
      print('Iniciando detección de código de barras en la imagen...');
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      final dataUrl = 'data:image/jpeg;base64,$base64Image';

      final result = await js_util.promiseToFuture(
          js_util.callMethod(js_util.globalThis, 'detectBarcodeWithQuagga', [dataUrl])
      );

      if (result == null || result.isEmpty) {
        print('No se pudo detectar ningún código de barras.');
        return 'No se detectó ningún código de barras.';
      }

      print('Detección de código de barras completada. Resultado: $result');
      return result as String;
    } catch (e) {
      print('Error en webBarcodeDetection: $e');
      return 'Error en la detección de código de barras: $e';
    }
  }
  
  void showResultDialog(BuildContext context, String result) {
    print('Mostrando diálogo de resultado...');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resultado de Detección de Código de Barras'),
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
