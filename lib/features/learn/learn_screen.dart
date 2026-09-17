import 'package:flutter/material.dart';
import 'tables_screen.dart';
import 'squares_screen.dart';
import 'cubes_screen.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Learn'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.table_chart_outlined), text: 'Tables'),
              Tab(icon: Icon(Icons.superscript_rounded), text: 'Squares'),
              Tab(icon: Icon(Icons.category_outlined), text: 'Cubes'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TablesScreen(),
            SquaresScreen(),
            CubesScreen(),
          ],
        ),
      ),
    );
  }
}
