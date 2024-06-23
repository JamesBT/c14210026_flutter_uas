import 'package:flutter/material.dart';
import 'package:flutter_uas/pin/pin.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_uas/note/home.dart';

class LoginPin extends StatefulWidget {
  const LoginPin({super.key});

  @override
  LoginPinState createState() => LoginPinState();
}

class LoginPinState extends State<LoginPin> {
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(6, (index) => TextEditingController());
    focusNodes = List.generate(6, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void verifyPin() async {
    String pin = controllers.map((controller) => controller.text).join();
    var pinBox = await Hive.openBox<Pin>('pin');
    Pin? storedPin = pinBox.get('pin');
    await pinBox.close();

    if (!mounted) return;

    if (storedPin != null && pin == storedPin.pin.toString()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      ).then((_) {
        for (var controller in controllers) {
          controller.clear();
        }
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('PIN Salah'),
            content:
                const Text('PIN yang Anda masukkan salah. Silakan coba lagi.'),
            actions: <Widget>[
              OutlinedButton(
                onPressed: () {
                  for (var controller in controllers) {
                    controller.clear();
                  }
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                      color: Colors.black), 
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          );
        },
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
            Text(
              'Login',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                (index) => SizedBox(
                  width: 40,
                  child: TextFormField(
                    controller: controllers[index],
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    obscureText: true,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        if (int.tryParse(value) == null) {
                          controllers[index].clear();
                        }
                        if (index < 5) {
                          FocusScope.of(context).nextFocus();
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
                    focusNode: focusNodes[index],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                verifyPin();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Container(
                width: 200,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
