// Importa utilidades de Flutter (como ChangeNotifier)
import 'package:app_tareas/repositories/book_repository.dart';
import 'package:flutter/foundation.dart';
// Importa el modelo de datos de libros
import '../models/book.dart';

// Controlador que maneja la lista de libros y la lógica
class BookController extends ChangeNotifier {
  BookController({BookRepository? repo}) : _repo = repo ?? BookRepository();
  final BookRepository _repo;

  // Mapa para rastrear ID de libros (necesario para actualizar/eliminar)
  final Map<Book, String> _bookIds = {};

  // Lista privada de libros
  final List<Book> _books = [];

  // Texto para búsqueda
  String _query = '';
  // Filtro actual (todos, almacenados, prestados o retrasados)
  BookFilter _filter = BookFilter.all;

  // ----- Lecturas (getters) -----

  // Devuelve la lista de libros, pero como lista de solo lectura
  List<Book> get books => List.unmodifiable(_books);

  // Devuelve el texto de búsqueda actual
  String get query => _query;

  // Devuelve el filtro actual
  BookFilter get filter => _filter;

  // Devuelve la lista de libros filtrados por búsqueda y filtro
  List<Book> get filtered {
    final q = _query.trim().toLowerCase(); // texto de búsqueda en minúsculas
    return _books.where((b) {
      // Filtra por estado
      final byFilter = switch (_filter) {
        BookFilter.all => true, // todos
        BookFilter.stored => b.status == BookStatus.stored, // solo almacenados
        BookFilter.borrowed => b.status == BookStatus.borrowed, // solo prestados
        BookFilter.overdue => b.status == BookStatus.overdue, // solo retrasados
      };
      // Filtra por coincidencia con el texto
      final byQuery =
          q.isEmpty ||
          b.title.toLowerCase().contains(q) ||
          (b.note?.toLowerCase().contains(q) ?? false);

      // El libro pasa si cumple ambos filtros
      return byFilter && byQuery;
    }).toList();
  }

  Future<void> load() => _reloadFromRepository();

  Future<void> _reloadFromRepository() async {
    final rows = await _repo.findFiltered(filter: filter, query: query);
    _books.clear();
    _bookIds.clear();

    for (final row in rows) {
      _books.add(row.book);
      _bookIds[row.book] = row.id;
    }

    notifyListeners();
  }

  // Cambia el texto de búsqueda
  void setQuery(String value) {
    _query = value;
    _reloadFromRepository();
  }

  // Cambia el filtro de libros
  void setFilter(BookFilter f) {
    _filter = f;
    _reloadFromRepository();
  }

  // Cambia el estado del libro (permite los 3 estados: Almacenado, Prestado, Retrasado)
  void changeStatus(Book b, BookStatus newStatus) async {
    b.status = newStatus;

    // Actualizar en el repositorio
    final id = _bookIds[b];
    if (id != null) {
      await _repo.updateStatus(id, newStatus);
    }

    notifyListeners();
  }

  // Agrega un nuevo libro al inicio de la lista
  void add(String title, {String? note, DateTime? returnDate}) async {
    final book = Book(title: title, note: note, returnDate: returnDate);
    final id = await _repo.create(book);

    // Agregar a la lista local
    _books.insert(0, book);
    _bookIds[book] = id;

    notifyListeners();
  }

  // Elimina un libro de la lista
  void remove(Book b) async {
    final id = _bookIds[b];
    if (id != null) {
      await _repo.delete(id);
      _bookIds.remove(b);
    }

    _books.remove(b);
    notifyListeners();
  }
}
