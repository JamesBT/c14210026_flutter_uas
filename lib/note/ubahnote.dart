import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_uas/note/note.dart';

class UbahNote extends StatefulWidget {
  final String noteKey;

  const UbahNote({super.key, required this.noteKey});

  @override
  UbahNoteState createState() => UbahNoteState();
}

class UbahNoteState extends State<UbahNote> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late Box<Note> _noteBox;
  late Future<void> _future;

  @override
  void initState() {
    super.initState();
    _future = _initializeNote();
  }

  Future<void> _initializeNote() async {
    _noteBox = await Hive.openBox<Note>('note');
    _noteBox = Hive.box<Note>('note');
    Note? note;

    for (var i = 0; i < _noteBox.length; i++) {
      var key = _noteBox.keyAt(i);
      var tempnote = _noteBox.get(key);

      if (tempnote?.key == widget.noteKey) {
        note = tempnote;
      }
    }
    if (note != null) {
      setState(() {
        _titleController = TextEditingController(text: note?.title);
        _contentController = TextEditingController(text: note?.content);
      });
    } else {
      throw Exception('Note not found');
    }
  }

  void _updateNote() async {
    final updatedTitle = _titleController.text;
    final updatedContent = _contentController.text;

    if (updatedTitle.isNotEmpty && updatedContent.isNotEmpty) {
      _noteBox = await Hive.openBox<Note>('note');
      _noteBox = Hive.box<Note>('note');
      Note? note;

      var idxUpdate = 0;
      for (var i = 0; i < _noteBox.length; i++) {
        var key = _noteBox.keyAt(i);
        var tempnote = _noteBox.get(key);

        if (tempnote?.key == widget.noteKey) {
          idxUpdate = i;
          note = tempnote;
        }
      }
      final updatedNote = Note(
          key: note!.key,
          title: updatedTitle,
          content: updatedContent,
          createdAt: note.createdAt,
          updatedAt: DateTime.now(),
        );

        await _noteBox.putAt(idxUpdate, updatedNote);

        if (!mounted) return;

        Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Edit Catatan'),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Catatan',
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Isi Catatan',
                      ),
                      maxLines: 10,
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _updateNote,
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(200, 40)),
                      child: const Text(
                        'Simpan',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
