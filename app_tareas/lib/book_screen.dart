import 'package:app_tareas/controllers/book_controller.dart';
import 'package:app_tareas/utils/date_utils.dart';
import 'package:app_tareas/widgets/bookWidgets/empty_state.dart';
import 'package:app_tareas/widgets/bookWidgets/filter_chips_row.dart';
import 'package:app_tareas/widgets/bookWidgets/filter_menu_button.dart';
import 'package:app_tareas/widgets/bookWidgets/new_book_fab.dart';
import 'package:app_tareas/widgets/bookWidgets/search_field.dart';
import 'package:app_tareas/widgets/bookWidgets/book_list_view.dart';
import 'package:flutter/material.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  late final BookController _ctrl;
  bool _sortByDate = true; // true = fecha, false = nombre

  @override
  void initState() {
    super.initState();
    _ctrl = BookController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.load();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        var items = _ctrl.filtered;

        // Ordenar según opción seleccionada
        if (_sortByDate) {
          items.sort((a, b) {
            if (a.returnDate == null && b.returnDate == null) return 0;
            if (a.returnDate == null) return 1;
            if (b.returnDate == null) return -1;
            return a.returnDate!.compareTo(b.returnDate!);
          });
        } else {
          items.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text("Biblioteca"),
            actions: [
              PopupMenuButton<bool>(
                icon: const Icon(Icons.sort),
                tooltip: "Ordenar",
                onSelected: (value) => setState(() => _sortByDate = value),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: true,
                    child: Text(_sortByDate ? "✓ Por fecha" : "Por fecha"),
                  ),
                  PopupMenuItem(
                    value: false,
                    child: Text(!_sortByDate ? "✓ Por nombre" : "Por nombre"),
                  ),
                ],
              ),
              FilterMenuButton(value: _ctrl.filter, onChanged: _ctrl.setFilter),
            ],
          ),
          floatingActionButton: NewBookFab(
            onSubmit: (title, note, returnDate) =>
                _ctrl.add(title, note: note, returnDate: returnDate),
            onCreated: (ctx) => ScaffoldMessenger.of(
              ctx,
            ).showSnackBar(const SnackBar(content: Text("Libro Agregado"))),
          ),
          body: SafeArea(
            child: Column(
              children: [
                SearchField(onChanged: _ctrl.setQuery),
                FilterChipsRow(
                  value: _ctrl.filter,
                  onChanged: _ctrl.setFilter,
                  color: Colors.red,
                ),
                const Divider(height: 1),
                Expanded(
                  child: items.isEmpty
                      ? const EmptyState()
                      : BookListView(
                          items: items,
                          onStatusChanged: (b, status) => _ctrl.changeStatus(b, status),
                          onDelete: (b) {
                            final deletedBook = b;
                            _ctrl.remove(b);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Libro Eliminado"),
                                action: SnackBarAction(
                                  label: "Deshacer",
                                  onPressed: () {
                                    _ctrl.add(
                                      deletedBook.title,
                                      note: deletedBook.note,
                                      returnDate: deletedBook.returnDate,
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          dateFormatter: formatShortDate,
                          swipeColor: Colors.red,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
