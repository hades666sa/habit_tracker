import 'package:flutter/material.dart';
import '../data/models/journal.dart';
import '../data/repositories/journal_repository.dart';

class JournalProvider with ChangeNotifier {
  final JournalRepository _repository = JournalRepository();
  List<Journal> _journals = [];
  bool _isLoading = false;

  List<Journal> get journals => _journals;
  bool get isLoading => _isLoading;

  Future<void> fetchJournals() async {
    _isLoading = true;
    notifyListeners();
    _journals = await _repository.getAllJournals();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addJournal(String content, {String? title}) async {
    final now = DateTime.now();
    final newJournal = Journal(
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.insertJournal(newJournal);
    await fetchJournals();
  }

  Future<void> updateJournal(Journal journal) async {
    await _repository.updateJournal(journal.copyWith(updatedAt: DateTime.now()));
    await fetchJournals();
  }

  Future<void> deleteJournal(int id) async {
    await _repository.deleteJournal(id);
    await fetchJournals();
  }
}
