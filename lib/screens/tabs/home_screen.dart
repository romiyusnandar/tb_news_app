import 'package:flutter/material.dart';
import 'package:my_berita/widgets/home_widgets/headline_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView(children: [HeadlineSliderWidget()],);
  }
}
