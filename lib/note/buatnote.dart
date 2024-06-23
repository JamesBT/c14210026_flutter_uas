import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_uas/note/note.dart';

class BuatNote extends StatefulWidget {
  const BuatNote({super.key});

  @override
  BuatNoteState createState() => BuatNoteState();
}

class BuatNoteState extends State<BuatNote> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  void _saveNote() async {
    final title = _titleController.text;
    final content = _contentController.text;
    final now = DateTime.now();

    if (title.isNotEmpty && content.isNotEmpty) {
      final noteBox = await Hive.openBox<Note>('note');

      final key =
          (noteBox.isNotEmpty ? (noteBox.keys.last + 1).toString() : '0');

      final note = Note(
        key: key,
        title: title,
        content: content,
        createdAt: now,
        updatedAt: now,
      );
      await noteBox.add(note);
      await noteBox.close();

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Catatan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Isi Catatan',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveNote,
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
