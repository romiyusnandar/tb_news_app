import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkBloc {
  final BehaviorSubject<List<String>> _subject = BehaviorSubject<List<String>>.seeded([]);

  BookmarkBloc() {
    loadBookmarks();
  }

  Stream<List<String>> get stream => _subject.stream;
  List<String> get currentIds => _subject.value;

  Future<void> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarkedIds = prefs.getStringList('bookmarked_articles') ?? [];
    _subject.sink.add(bookmarkedIds);
  }

  Future<void> toggleBookmark(String articleId) async {
    final updatedBookmarks = List<String>.from(currentIds);

    if (updatedBookmarks.contains(articleId)) {
      updatedBookmarks.remove(articleId);
    } else {
      updatedBookmarks.add(articleId);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bookmarked_articles', updatedBookmarks);

    _subject.sink.add(updatedBookmarks);
  }

  void dispose() {
    _subject.close();
  }
}

final bookmarkBloc = BookmarkBloc();