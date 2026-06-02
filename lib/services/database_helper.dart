import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('libdiary_kutuphane.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Book (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        author TEXT,
        coverImage TEXT,
        vibe TEXT,
        status TEXT,
        sayfaSayisi INTEGER,
        hikayePuan REAL,
        karakterPuan REAL,
        yazimDiliPuan REAL,
        summary TEXT,
        review TEXT,
        playlistUrl TEXT,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE Quote (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bookId INTEGER,
        text TEXT,
        page TEXT,
        isFavorite INTEGER DEFAULT 0,
        FOREIGN KEY (bookId) REFERENCES Book (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> insertBook(Map<String, dynamic> row) async {
    final db = await instance.database;
    row['createdAt'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return await db.insert('Book', row);
  }

  // YENİ: Kitabı Güncelleme Fonksiyonu
  Future<int> updateBook(Map<String, dynamic> row) async {
    final db = await instance.database;
    int id = row['id'];
    return await db.update('Book', row, where: 'id = ?', whereArgs: [id]);
  }

  // YENİ: Kitabı Tamamen Silme Fonksiyonu
  Future<int> deleteBook(int id) async {
    final db = await instance.database;
    await db.delete('Quote',
        where: 'bookId = ?', whereArgs: [id]); // Önce alıntılarını sil
    return await db.delete('Book', where: 'id = ?', whereArgs: [id]);
  }

  // YENİ: Bir kitabın eski alıntılarını temizleme (Düzenleme yaparken kullanılır)
  Future<void> deleteQuotesForBook(int bookId) async {
    final db = await instance.database;
    await db.delete('Quote', where: 'bookId = ?', whereArgs: [bookId]);
  }

  Future<int> insertQuote(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('Quote', row);
  }

  Future<List<Map<String, dynamic>>> getBooks() async {
    final db = await instance.database;
    return await db.query('Book', orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> getAllQuotes() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT Quote.*, Book.title AS bookTitle, Book.author AS bookAuthor 
      FROM Quote INNER JOIN Book ON Quote.bookId = Book.id ORDER BY Quote.id DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getQuotesForBook(int bookId) async {
    final db = await instance.database;
    return await db.query('Quote',
        where: 'bookId = ?', whereArgs: [bookId], orderBy: 'id DESC');
  }

  Future<int> toggleQuoteFavorite(int quoteId, int isFavorite) async {
    final db = await instance.database;
    return await db.update('Quote', {'isFavorite': isFavorite},
        where: 'id = ?', whereArgs: [quoteId]);
  }

  Future<Map<String, dynamic>> getOverallStats() async {
    final db = await instance.database;
    var bookCount =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM Book')) ??
            0;
    var readCount = Sqflite.firstIntValue(await db
            .rawQuery('SELECT COUNT(*) FROM Book WHERE status = "Okundu"')) ??
        0;
    var quoteCount = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM Quote')) ??
        0;
    var pageCountData = await db.rawQuery(
        'SELECT SUM(sayfaSayisi) as totalPages FROM Book WHERE status = "Okundu"');
    int totalPages = (pageCountData.first['totalPages'] as int?) ?? 0;
    var avgData = await db.rawQuery(
        'SELECT AVG((hikayePuan + karakterPuan + yazimDiliPuan) / 3.0) as avgScore FROM Book');
    double avgScore = (avgData.first['avgScore'] as double?) ?? 0.0;
    return {
      'totalBooks': bookCount,
      'readBooks': readCount,
      'totalQuotes': quoteCount,
      'totalPages': totalPages,
      'avgScore': avgScore
    };
  }

  Future<List<Map<String, dynamic>>> getVibeDistribution() async {
    final db = await instance.database;
    return await db
        .rawQuery('SELECT vibe, COUNT(*) as count FROM Book GROUP BY vibe');
  }

  Future<List<Map<String, dynamic>>> getMonthlyBooks() async {
    final db = await instance.database;
    String currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    return await db.query('Book',
        where: 'createdAt LIKE ?',
        whereArgs: ['$currentMonth%'],
        orderBy: 'id DESC');
  }

  Future<Map<String, dynamic>?> getDailyQuote() async {
    final db = await instance.database;
    List<Map<String, dynamic>> allQuotes = await db.rawQuery('''
      SELECT Quote.*, Book.title AS bookTitle, Book.author AS bookAuthor 
      FROM Quote INNER JOIN Book ON Quote.bookId = Book.id
    ''');
    if (allQuotes.isEmpty) return null;
    var now = DateTime.now();
    int seed = now.year * 10000 + now.month * 100 + now.day;
    var random = math.Random(seed);
    return allQuotes[random.nextInt(allQuotes.length)];
  }
}
