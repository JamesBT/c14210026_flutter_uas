import 'package:flutter/material.dart';
import 'package:flutter_uas/note/buatnote.dart';
import 'package:flutter_uas/note/notelist.dart';
import 'package:flutter_uas/pin/loginpin.dart';
import 'package:flutter_uas/pin/ubahpin.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_uas/note/note.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<int> _noteCountNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _refreshNotes(); // Initialize note count
  }

  Future<void> _refreshNotes() async {
    final noteBox = await Hive.openBox<Note>('note');
    _noteCountNotifier.value = noteBox.length;
    await noteBox.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPin()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UbahPin()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          bottom: 16.0,
        ),
        child: Column(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'All Notes',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  ValueListenableBuilder<int>(
                    valueListenable: _noteCountNotifier,
                    builder: (context, noteCount, child) {
                      return Text(
                        '$noteCount Notes',
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: NoteList(
                  onNoteChanged: _refreshNotes,
                  key: ValueKey(DateTime.now()), // Force rebuild
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BuatNote()),
          );
          await _refreshNotes();
        },
        backgroundColor: const Color(0xFFF7F2F9),
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}
