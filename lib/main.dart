import 'package:flutter/material.dart';
import 'db_helper.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DbHelper.init();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SQLite App',
      home: const HomePage(),
    );
  }
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});


  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  List notes = [];


  @override
  void initState() {
    super.initState();
    loadNotes();
  }


  void loadNotes() async {
    final data = await DbHelper.getNotes();
    setState(() {
      notes = data;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SQLite Notes")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddNotePage()),
          );
          loadNotes();
        },
      ),
      body: notes.isEmpty
          ? const Center(child: Text("No Notes Found"))
          : ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final item = notes[index];
          return ListTile(
            title: Text(item['title']),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await DbHelper.delete(item['id']);
                loadNotes();
              },
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddNotePage(
                    isEdit: true,
                    id: item['id'],
                    oldText: item['title'],
                  ),
                ),
              );
              loadNotes();
            },
          );
        },
      ),
    );
  }
}


class AddNotePage extends StatefulWidget {
  final bool isEdit;
  final int? id;
  final String? oldText;


  const AddNotePage({super.key, this.isEdit = false, this.id, this.oldText});


  @override
  State<AddNotePage> createState() => _AddNotePageState();
}


class _AddNotePageState extends State<AddNotePage> {
  TextEditingController noteCtrl = TextEditingController();


  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      noteCtrl.text = widget.oldText!;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? "Edit Note" : "Add Note"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(hintText: "Enter note"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String text = noteCtrl.text.trim();


                if (text.isEmpty) return;


                if (widget.isEdit) {
                  await DbHelper.update(widget.id!, text);
                } else {
                  await DbHelper.insert(text);
                }


                Navigator.pop(context);
              },
              child: Text(widget.isEdit ? "Update" : "Save"),
            )
          ],
        ),
      ),
    );
  }
}

