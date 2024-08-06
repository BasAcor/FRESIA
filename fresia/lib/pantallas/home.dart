import 'package:flutter/material.dart';
import '../widgets/mic_list.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 1;
  BluetoothConnection? conexion; // Variable para almacenar la conexión Bluetooth

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(context, 'estadisticas');
        break;
      case 1:
        Navigator.pushNamed(context, '/');
        break;
      case 2:
        Navigator.pushNamed(context, 'fresia');
        break;
    }
  }

  void setConexion(BluetoothConnection? conn) {
    setState(() {
      conexion = conn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido a Fres IA'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Añade espaciado alrededor del contenido
        child: Column(
          children: <Widget>[
            Expanded(
              child: MicList(conexion: conexion), // Pasar la conexión al widget MicList
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bluetooth_audio),
            label: 'BT análisis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.data_exploration_outlined),
            label: 'Fresia',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
