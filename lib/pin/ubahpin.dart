import 'package:flutter/material.dart';
import 'package:flutter_uas/pin/pin.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_uas/note/home.dart';

class UbahPin extends StatefulWidget {
  const UbahPin({super.key});

  @override
  UbahPinState createState() => UbahPinState();
}

class UbahPinState extends State<UbahPin> {
  late List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(6, (index) => TextEditingController());
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void savePin() async {
    bool allFilled = true;
    for (var controller in controllers) {
      if (controller.text.isEmpty) {
        allFilled = false;
        break;
      }
    }

    if (!allFilled) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('PIN Tidak Lengkap'),
            content: const Text('Silakan lengkapi semua kotak PIN.'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
      return;
    }

    String newPin = controllers.map((controller) => controller.text).join();

    var pinBox = await Hive.openBox<Pin>('pin');
    var newPinObject = Pin(int.parse(newPin));
    await pinBox.put('pin', newPinObject);
    await pinBox.close();

    if (!mounted) return;

    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah PIN'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ubah Pin',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    )),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                (index) => SizedBox(
                  width: 40,
                  child: TextField(
                    controller: controllers[index],
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        if (int.tryParse(value) == null) {
                          controllers[index].clear();
                        }
                        if (index < 5) {
                          FocusScope.of(context).nextFocus();
                        } else {
                          FocusScope.of(context).unfocus();
                        }
                      } else {
                        controllers[index].clear();
                        FocusScope.of(context).previousFocus();
                      }
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: savePin,
              child: const Text('Simpan PIN',
                  style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
