import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class MicList extends StatefulWidget {
  final BluetoothConnection? conexion;

  const MicList({super.key, required this.conexion}); // Constructor

  @override
  MicListState createState() => MicListState();
}

class MicListState extends State<MicList> {
  List<String> micLabels = ["Etiqueta el microfono 1", "Etiqueta el microfono 2", "Etiqueta el microfono 3", "Etiqueta el microfono 4"];
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  String tempAudioFilePath = '';
  late StreamSubscription<Uint8List> audioStreamSubscription;

  @override
  void initState() {
    super.initState();
    setupTempFile();
    listenForAudio(); // Inicia la escucha para recibir datos de audio
  }

  Future<void> setupTempFile() async {
    Directory tempDir = await getTemporaryDirectory();
    tempAudioFilePath = '${tempDir.path}/temp_audio.wav';
  }

  Future<void> playAudio() async {
    if (!isPlaying) {
      isPlaying = true;
      await audioPlayer.setSource(DeviceFileSource(tempAudioFilePath));
      await audioPlayer.resume();

      // Escuchar el final de la reproducción
      audioPlayer.onPlayerComplete.listen((event) {
        setState(() {
          isPlaying = false;
        });
      });
    }
  }

  void changeMic(int micNumber) {
    if (widget.conexion != null && widget.conexion!.isConnected) {
      widget.conexion!.output.add(Uint8List.fromList([micNumber + 48]));
      widget.conexion!.output.allSent;
      print('Cambiando a micrófono $micNumber');
    }
  }

  void listenForAudio() {
    if (widget.conexion != null && widget.conexion!.isConnected) {
      audioStreamSubscription = widget.conexion!.input!.listen((Uint8List data) {
        if (data.isNotEmpty) {
          // Guarda los datos en el archivo temporal
          File tempFile = File(tempAudioFilePath);
          tempFile.writeAsBytesSync(data, mode: FileMode.append);
          // Opcionalmente, podrías llamar a playAudio aquí si deseas reproducir en tiempo real
          playAudio(); // Reproduce el audio si es necesario
        }
      }, onError: (error) {
        print('Error al recibir audio: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: micLabels.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextFormField(
                  initialValue: micLabels[index],
                  decoration: InputDecoration(
                    labelText: 'canal ${index + 1}',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      micLabels[index] = value;
                    });
                  },
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        changeMic(index + 1); // Cambia al micrófono correspondiente
                      },
                      child: const Text('Cambiar Micrófono'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        playAudio(); // Llama a la función para reproducir el audio
                      },
                      child: const Text('Analizar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    audioStreamSubscription.cancel(); // Cancela la suscripción al flujo de audio
    widget.conexion?.finish();
    audioPlayer.dispose();
    super.dispose();
  }
}
