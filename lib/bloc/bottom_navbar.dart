import "dart:async";

enum NavBarItem {
  home,
  bookmark,
  profile,
}

class BottomNavBarBloc {
  final StreamController<NavBarItem> _navBarItemController = StreamController<NavBarItem>.broadcast();

  NavBarItem defaultItem = NavBarItem.home;

  Stream<NavBarItem> get navBarItemStream => _navBarItemController.stream;

  void pickItem(int i) {
    switch (i) {
      case 0:
        _navBarItemController.sink.add(NavBarItem.home);
        break;
      case 1:
        _navBarItemController.sink.add(NavBarItem.bookmark);
        break;
      case 2:
        _navBarItemController.sink.add(NavBarItem.profile);
        break;
      default:
        _navBarItemController.sink.add(defaultItem);
    }
  }

  void close() {
    _navBarItemController.close();
  }
}