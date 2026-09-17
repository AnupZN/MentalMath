import 'package:flutter/material.dart';
import 'tables_screen.dart';
import 'squares_cubes_screen.dart';
import 'primes_screen.dart';

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
              Tab(icon: Icon(Icons.functions_rounded), text: 'Squares & Cubes'),
              Tab(icon: Icon(Icons.circle_outlined), text: 'Primes'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TablesScreen(),
            SquaresCubesScreen(),
            PrimesScreen(),
          ],
        ),
      ),
    );
  }
}
