import 'package:flutter/material.dart';

class SourceScreen extends StatefulWidget {
  const SourceScreen({super.key});

  @override
  State<SourceScreen> createState() => _SourceScreenState();
}

class _SourceScreenState extends State<SourceScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Source Screen',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
