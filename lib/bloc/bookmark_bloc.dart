import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkBloc {
  final BehaviorSubject<List<String>> _subject = BehaviorSubject<List<String>>.seeded([]);
  final String _bookmarkKey = 'bookmarked_article_slugs';

  BookmarkBloc() {
    loadBookmarks();
  }

  Stream<List<String>> get stream => _subject.stream;
  List<String> get currentSlugs => _subject.value;

  Future<void> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarkedSlugs = prefs.getStringList(_bookmarkKey) ?? [];
    if (!_subject.isClosed) {
      _subject.sink.add(bookmarkedSlugs);
    }
  }

  Future<void> toggleBookmark(String articleSlug) async {
    final updatedBookmarks = List<String>.from(currentSlugs);

    if (updatedBookmarks.contains(articleSlug)) {
      updatedBookmarks.remove(articleSlug);
    } else {
      updatedBookmarks.add(articleSlug);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_bookmarkKey, updatedBookmarks);

    if (!_subject.isClosed) {
      _subject.sink.add(updatedBookmarks);
    }
  }

  void dispose() {
    _subject.close();
  }
}

final bookmarkBloc = BookmarkBloc();