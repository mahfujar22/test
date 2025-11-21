import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';



// class Strat now
class DbHelper {

  // static (class-level)
  static Database? _db;

 // database initialize return not value
  static Future<void> init() async{
    if(_db!=null) return ;
   // devices application document folder
    Directory dir = await getApplicationDocumentsDirectory();
    // document path or file name
    String path = join(dir.path, "notes.db");

    // device file open or create
    _db = await openDatabase(
      path, // file location
      version: 1, // schema version
      onCreate:(db, version) async{ // file create
        await db.execute('''
       CREATE TABLE notes(
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       title TEXT
       )
       ''');
      }
    );
  }


   // new insert note
  static Future <int> insert(String title) async{

    // _db not null
    return await _db!.insert(
        'notes', // first argument
        {'title':title} // Map
    );
  }


  // get all notes
  static Future<List<Map<String, dynamic>>> getNotes() async {
    return await _db!.query('notes');
  }

// update notes
  static Future<int> update(int id, String title) async {
    return await _db!.update(
      'notes',
      {'title': title},
      where: 'id=?',
      whereArgs: [id],
    );
  }



  // delete note
  static Future<int> delete(int id) async {
    return await _db!.delete('notes',where:'id = ?', whereArgs:[id]);
  }
}