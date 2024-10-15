import 'package:flutter/material.dart';
import 'global_key.dart';
import 'homepage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Prototipo Multiplataforma',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: MainScreen(), // Establecer la pantalla principal
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text(
          'Prototipo Plataforma Web',
          style: TextStyle(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.apps, size: 64, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Recognition Web App',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            // Espacio entre el texto y el botón
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue, // Fondo verde claro
                foregroundColor: Colors.white, // Color del texto
                textStyle: TextStyle(
                  fontWeight: FontWeight.w600, // Peso de la fuente
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Borde redondeado (0.5em ≈ 8px)
                ),
                shadowColor: Colors.black.withOpacity(0.5), // Color de sombra
                elevation: 5, // Elevación de la sombra
              ),
              child: Text('Opciones',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
