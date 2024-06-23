import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_uas/note/note.dart';
import 'package:flutter_uas/note/ubahnote.dart';

class NoteList extends StatefulWidget {
  final VoidCallback onNoteChanged;

  const NoteList({super.key, required this.onNoteChanged});

  @override
  NoteListState createState() => NoteListState();
}

class NoteListState extends State<NoteList> {
  late Box<Note> _noteBox;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _openNoteBox().then((_) {
      setState(() {});
    });
  }

  Future<void> _openNoteBox() async {
    try {
      _noteBox = await Hive.openBox<Note>('note');
      _noteBox = Hive.box<Note>('note');
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteNote(String key) async {
    try {
      final noteBox = await Hive.openBox<Note>('note');
      var keyHapus = key;
      var idxDelete = 0;
      for (var i = 0; i < noteBox.length; i++) {
        var key = noteBox.keyAt(i);
        if (key == keyHapus) {
          idxDelete = i;
        }
      }
      await noteBox.deleteAt(idxDelete);

      widget.onNoteChanged();
    } catch (e) {
      print('Error deleting note: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    _openNoteBox();
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_noteBox.isOpen) {
      return const Center(child: Text('Box is closed.'));
    }

    final notes = _noteBox.values.toList();

    if (notes.isEmpty) {
      return const Center(child: Text('No notes available.'));
    }

    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UbahNote(
                  noteKey: note.key,
                ),
              ),
            ).then((_) => widget.onNoteChanged());
          },
          child: Dismissible(
            key: ValueKey<String>(note.key),
            background: Container(
              color: Colors.blue,
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit, color: Colors.white),
                      SizedBox(height: 4),
                      Text('Edit', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              child: const Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete, color: Colors.white),
                      SizedBox(height: 4),
                      Text('Delete', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UbahNote(
                      noteKey: note.key,
                    ),
                  ),
                ).then((_) => widget.onNoteChanged());
                return false;
              } else if (direction == DismissDirection.endToStart) {
                final confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: const Text(
                        'Are you sure you want to delete this note?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await _deleteNote(note.key);
                          if (!mounted) return;

                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                return confirm ?? false;
              }
              return false;
            },
            child: Card(
              elevation: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 150,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color(0xFFF3EDF6),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        note.content,
                        style: const TextStyle(fontSize: 14.0),
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          note.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Created: ${note.createdAt.toLocal()}',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Last edited: ${note.updatedAt.toLocal()}',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
