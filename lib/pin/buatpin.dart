import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_uas/pin/pin.dart';
import 'package:flutter_uas/note/home.dart';

class BuatPin extends StatefulWidget {
  const BuatPin({super.key});

  @override
  State<BuatPin> createState() => _BuatPinState();
}

class _BuatPinState extends State<BuatPin> {
  late List<TextEditingController> controllers;
  late bool canSave;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(6, (index) => TextEditingController());
    canSave = false;
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void checkCanSave() {
    bool allFilled = true;
    for (var controller in controllers) {
      if (controller.text.isEmpty) {
        allFilled = false;
        break;
      }
    }
    setState(() {
      canSave = allFilled;
    });
  }

  void savePin() async {
    if (canSave) {
      await Hive.initFlutter();
      String pin = controllers.map((controller) => controller.text).join();
      var pinBox = await Hive.openBox<Pin>('pin');
      var isipin = Pin(int.parse(pin));
      await pinBox.put('pin', isipin);
      await pinBox.close();

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Buat Pin',
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
                          checkCanSave();
                        }
                      } else {
                        controllers[index].clear();
                        FocusScope.of(context).previousFocus();
                        checkCanSave();
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
              onPressed: canSave ? savePin : null,
              child: const Text('Simpan PIN'),
            ),
          ],
        ),
      ),
    );
  }
}
