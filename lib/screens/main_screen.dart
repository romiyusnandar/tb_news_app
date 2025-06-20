import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:my_berita/bloc/bottom_navbar.dart';
import 'package:my_berita/screens/tabs/bookmark_screen.dart';
import 'package:my_berita/screens/tabs/home_screen.dart';
import 'package:my_berita/screens/tabs/profile_screen.dart';
import 'package:my_berita/utils/theme.dart' as theme;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  late BottomNavBarBloc _bottomNavBarBloc;

  final List<Widget> _screens = [
    const HomeScreen(),
    const BookmarkScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _bottomNavBarBloc = BottomNavBarBloc();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("1C2833"),
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: AppBar(
            backgroundColor: HexColor("1A1A2E"),
            title: Text("MyBerita App", style: TextStyle(color: Colors.white)),
          )
      ),
      body: SafeArea(
        child: StreamBuilder<NavBarItem>(
          stream: _bottomNavBarBloc.navBarItemStream,
          initialData: _bottomNavBarBloc.defaultItem,
          builder: (BuildContext context, AsyncSnapshot<NavBarItem> snapshot) {
            return IndexedStack(
              index: snapshot.data!.index,
              children: _screens,
            );
          },
        ),
      ),
      bottomNavigationBar: StreamBuilder<NavBarItem>(
        stream: _bottomNavBarBloc.navBarItemStream,
        initialData: _bottomNavBarBloc.defaultItem,
        builder: (BuildContext context, AsyncSnapshot<NavBarItem> snapshot) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
              boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.1), spreadRadius: 0, blurRadius: 10.0)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
              child: BottomNavigationBar(
                backgroundColor: HexColor("1A1A2E"),
                iconSize: 20,
                unselectedItemColor: theme.Colors.grey,
                unselectedFontSize: 9.5,
                selectedFontSize: 10,
                type: BottomNavigationBarType.fixed,
                fixedColor: Colors.blueAccent,
                currentIndex: snapshot.data!.index,
                onTap: _bottomNavBarBloc.pickItem,
                items: const [
                  BottomNavigationBarItem(
                      label: "Beranda",
                      icon: Icon(EvaIcons.homeOutline),
                      activeIcon: Icon(EvaIcons.home)
                  ),
                  BottomNavigationBarItem(
                    label: "Penanda",
                    icon: Icon(EvaIcons.bookmarkOutline),
                    activeIcon: Icon(EvaIcons.bookmark),
                  ),
                  BottomNavigationBarItem(
                    label: "Profil",
                    icon: Icon(EvaIcons.personOutline),
                    activeIcon: Icon(EvaIcons.person),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}