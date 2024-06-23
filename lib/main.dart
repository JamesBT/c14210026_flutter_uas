import 'package:flutter/material.dart';
import 'package:flutter_uas/note/note.dart';
import 'package:flutter_uas/pin/buatpin.dart';
import 'package:flutter_uas/pin/loginpin.dart';
import 'package:flutter_uas/pin/pin.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async{
  await Hive.initFlutter();
  
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(PinAdapter());
  await Hive.openBox<Note>('note');
  await Hive.openBox<Pin>('pin');
  
  var pin = Hive.box<Pin>('pin');
  bool pertamajalan = pin.isEmpty;

  runApp(MainApp(pertamaJalan: pertamajalan));
}

class MainApp extends StatelessWidget {
  final bool pertamaJalan;

  const MainApp({super.key, required this.pertamaJalan});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: null,
        body: Center(
          child: pertamaJalan ? const BuatPin() : const LoginPin(),
        ),
      ),
    );
  }
}
